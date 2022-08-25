import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:jaspr/jaspr.dart' hide Builder;
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

var appChecker = TypeChecker.fromRuntime(AppAnnotation);
var componentChecker = TypeChecker.fromRuntime(Component);

/// The main builder used for code generation
class EntrypointBuilder implements Builder {
  EntrypointBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;
    var outputId = inputId.changeExtension('.g.dart');

    try {
      var entrypointSource = await generateEntrypoint(buildStep);
      if (entrypointSource != null) {
        await buildStep.writeAsString(
          outputId,
          entrypointSource,
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
        '.dart': ['.g.dart']
      };

  String get generationHeader => "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_builder\n";

  Future<String?> generateEntrypoint(BuildStep buildStep) async {

    var name = path.basenameWithoutExtension(buildStep.inputId.path);

    var appComponents = <ClassElement>{};

    await for (var lib in buildStep.resolver.libraries) {
      if (lib.isInSdk) continue;

      var reader = LibraryReader(lib);

      for (var e in reader.annotatedWithExact(appChecker)) {
        var c = e.element;
        if (c is ClassElement && componentChecker.isAssignableFrom(c)) {
          appComponents.add(c);
        }
      }
    }

    if (appComponents.isEmpty) {
      return null;
    }

    return DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/server.dart';
      import '$name.dart' as e;
      ${appComponents.mapIndexed((index, c) => "import '${c.librarySource.uri}' as c$index;").join('\n')}
      
      void main() {
        ComponentRegistry.initialize(components: {
          ${appComponents.mapIndexed((index, c) => 'c$index.${c.thisType.getDisplayString(withNullability: false)}: ComponentEntry(\'${c.librarySource.uri.path.split('/').skip(1).join('/').replaceFirst('.dart', '')}\'),').join('\n')}
        });
        e.main();
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

    var uri = (await buildStep.inputLibrary).source.uri;

    return DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/browser.dart';
      import '$uri' as a;
      
      void main() {
        runApp(a.${c.thisType.getDisplayString(withNullability: false)}());
      }
    ''');
  }
}
