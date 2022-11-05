import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:jaspr/jaspr.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

var appChecker = TypeChecker.fromRuntime(AppAnnotation);
var islandChecker = TypeChecker.fromRuntime(IslandAnnotation);
var componentChecker = TypeChecker.fromRuntime(Component);
final keyChecker = TypeChecker.fromRuntime(Key);

/// The main builder used for code generation
class EntrypointBuilder implements Builder {
  EntrypointBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;
    var outputId = inputId.changeExtension('.g.dart');
    var islandsId = AssetId(inputId.package, inputId.path.replaceFirst('lib/', 'web/').replaceFirst('.dart', '.islands.dart'));


    try {
      var targets = await generateTargets(buildStep);

      var entrypointSource = await generateEntrypoint(targets, buildStep);
      if (entrypointSource != null) {
        await buildStep.writeAsString(
          outputId,
          entrypointSource,
        );
      }

      var islandsSource = await generateIslands(targets, buildStep);
      if (islandsSource != null) {
        await buildStep.writeAsString(
          islandsId,
          islandsSource,
        );
      }
    } catch (e, st) {
      print('An unexpected error occurred.\n'
          'This is probably a bug in jaspr_builder.\n'
          'Please report this here: '
          'https://github.com/schultek/jaspr/issues\n\n'
          'The error was:\n$e\n\n$st');
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '^lib/{{file}}.dart': ['lib/{{file}}.g.dart', 'web/{{file}}.islands.dart']
      };

  String get generationHeader => "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_builder\n";

  Future<Map<ClassElement, int>> generateTargets(BuildStep buildStep) async {

    var targets = <ClassElement, int>{};

    await for (var lib in buildStep.resolver.libraries) {
      if (lib.isInSdk) continue;

      var reader = LibraryReader(lib);

      for (var e in reader.allElements) {
        if (e is ClassElement && componentChecker.isAssignableFrom(e)) {
          var a = 0;
          if (appChecker.hasAnnotationOf(e)) {
            a |= 1;
          }
          if (islandChecker.hasAnnotationOf(e)) {
            a |= 2;
          }
          if (a != 0) {
            targets[e] = a;
          }
        }
      }
    }

    return targets;
  }

  Future<String?> generateEntrypoint(Map<ClassElement, int> targets, BuildStep buildStep) async {

    if (targets.isEmpty) {
      return null;
    }

    var name = path.basenameWithoutExtension(buildStep.inputId.path);

    return DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/server.dart';
      import '$name.dart' as e;
      ${targets.entries.mapIndexed((index, c) => "import '${c.key.librarySource.uri}' as c$index;").join('\n')}
      
      void main() {
        ComponentRegistry.initialize('$name', components: {
          ${targets.entries.mapIndexed((index, c) {
            var className = 'c$index.${c.key.thisType.getDisplayString(withNullability: false)}';
            var params = getParamsFor(c.key);
            return '''
              $className: ComponentEntry${params.isNotEmpty ? '<$className>' : ''}.${c.value == 1 ? 'app' : c.value == 2 ? 'island' : 'appAndIsland'}(
                '${c.key.librarySource.uri.path.split('/').skip(1).join('/').replaceFirst('.dart', '')}'
                ${params.isNotEmpty ? ', getParams: (c) { return {${params.map((p) => "'${p.name}': c.${p.name}").join(', ')}}; }' : ''}
              ),
            ''';
          }).join('\n')}
        });
        e.main();
      }
    ''');
  }

  Future<String?> generateIslands(Map<ClassElement, int> targets, BuildStep buildStep) async {

    if (targets.isEmpty) {
      return null;
    }

    var islands = targets.entries.where((e) => e.value & 2 != 0).map((e) => e.key);

    if (islands.isEmpty) {
      return null;
    }

    return DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/browser.dart';
      ${islands.mapIndexed((index, c) => "import '${c.librarySource.uri}' deferred as c$index;").join('\n')}
      
      void main() {
        runIslandsDeferred({
          ${islands.mapIndexed((index, c) {
            var params = getParamsFor(c);
            return '''
              '${c.librarySource.uri.path.split('/').skip(1).join('/').replaceFirst('.dart', '')}': loadIsland(c$index.loadLibrary, (p) { 
                return c$index.${c.thisType.getDisplayString(withNullability: false)}(${params.where((p) => p.isPositional).map((p) => 'p.get(\'${p.name}\')').followedBy(params.where((p) => p.isNamed).map((p) => '${p.name}: p.get(\'${p.name}\')')).join(', ')}); 
              }),
            ''';
          }).join('\n')}
        });
      }
    ''');
  }
}


/// Builds web entrypoints for components annotated with @app
class AppsBuilder implements Builder {
  AppsBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;

    var outputId = AssetId(inputId.package, inputId.path.replaceFirst('lib/', 'web/').replaceFirst('.dart', '.g.dart'));

    try {
      var webSource = await generateWebEntrypoint(buildStep);
      if (webSource == null) return;
      await buildStep.writeAsString(
        outputId,
        webSource,
      );
    } catch (e, st) {
      print('An unexpected error occurred.\n'
          'This is probably a bug in jaspr_builder.\n'
          'Please report this here: '
          'https://github.com/schultek/jaspr/issues\n\n'
          'The error was:\n$e\n\n$st');
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    'lib/{{file}}.dart': ['web/{{file}}.g.dart']
  };

  String get generationHeader => "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_builder\n";

  Future<String?> generateWebEntrypoint(BuildStep buildStep) async {

    var reader = LibraryReader(await buildStep.inputLibrary);

    var annotated = reader.annotatedWithExact(appChecker).map((e) => e.element).whereType<ClassElement>().where((c) =>componentChecker.isAssignableFrom(c));

    if (annotated.isEmpty) {
      return null;
    }

    if (annotated.length > 1) {
      print("[WARNING] Cannot have multiple components annotated with @app in a single library.");
    }

    var c = annotated.first;
    var params = getParamsFor(c);

    var uri = (await buildStep.inputLibrary).source.uri;

    return DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/browser.dart';
      import '$uri' as a;
      
      void main() {
        runAppWithParams((p) {
          return a.${c.thisType.getDisplayString(withNullability: false)}(${params.where((p) => p.isPositional).map((p) => 'p.get(\'${p.name}\')').followedBy(params.where((p) => p.isNamed).map((p) => '${p.name}: p.get(\'${p.name}\')')).join(', ')});
        });
      }
    ''');
  }
}


List<ParameterElement> getParamsFor(ClassElement e) {
  var params = e.constructors.first.parameters.where((e) => !keyChecker.isAssignableFromType(e.type)).toList();

  for (var param in params) {
    if (!param.isInitializingFormal) {
      throw UnsupportedError('Island components only support initializing formal constructor parameters.');
    }
  }

  return params;
}