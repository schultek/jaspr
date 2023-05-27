import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

import '../utils.dart';

/// Builds web entrypoints for components annotated with @client
class ClientComponentBuilder implements Builder {
  ClientComponentBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateComponentOutputs(buildStep);
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
        'lib/{{file}}.dart': ['lib/{{file}}.g.dart', 'web/{{file}}.client.dart'],
      };

  String get generationHeader => "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_builder\n";

  Future<void> generateComponentOutputs(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }

    var library = await buildStep.inputLibrary;
    var reader = LibraryReader(library);

    var clients = reader.annotatedWithExact(clientChecker).map((e) => e.element);

    var annotated = clients.toSet();

    if (annotated.isEmpty) {
      return;
    }

    if (annotated.length > 1) {
      log.warning("Cannot have multiple components annotated with @client in a single library.");
    }

    var part = '${path.url.basenameWithoutExtension(buildStep.inputId.path)}.g.dart';

    final libraryUnit = await buildStep.resolver.compilationUnitFor(buildStep.inputId);
    final hasPartDirective = libraryUnit.directives.whereType<PartDirective>().any((e) => e.uri.stringValue == part);

    if (!hasPartDirective) {
      log.warning(
        '$part must be included as a part directive in '
        'the input library with:\n    part \'$part\';',
      );
    }

    var element = annotated.first;

    if (element is! ClassElement) {
      log.warning('@client can only be applied on classes. Failing element: ${element.name}');
      return;
    }

    if (!componentChecker.isAssignableFrom(element)) {
      log.warning('@client can only be applied on classes extending Component. Failing element: ${element.name}');
      return;
    }

    var mixinName = '_\$${element.name}';
    var usesMixin =
        // ignore: deprecated_member_use
        (element.node as ClassDeclaration).withClause?.mixinTypes.any((type) => type.name.name == mixinName) ?? false;

    if (!usesMixin) {
      log.warning('Your class ${element.name} must mixin the generated \'$mixinName\' mixin.');
    }

    var params = getParamsFor(element);

    var uri = (await buildStep.inputLibrary).source.uri;

    var isApp = clientChecker.hasAnnotationOfExact(element);

    var partId = buildStep.inputId.changeExtension('.g.dart');
    var partSource = DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      part of '${path.url.basename(buildStep.inputId.path)}';
      
      mixin $mixinName implements ComponentEntryMixin<${element.name}> {
        @override
        ComponentEntry<${element.name}> get entry {
          ${params.isNotEmpty ? 'var self = this as ${element.name};' : ''}
          return ComponentEntry.client(
            '${path.url.relative(path.url.withoutExtension(buildStep.inputId.path), from: 'lib')}'
            ${params.isNotEmpty ? ', params: {${params.map((p) => "'${p.name}': self.${p.name}").join(', ')}},' : ''}
          );
        }
      }
    ''');

    await buildStep.writeAsString(partId, partSource);

    var webId = AssetId(buildStep.inputId.package,
        buildStep.inputId.path.replaceFirst('lib/', 'web/').replaceFirst('.dart', '.client.dart'));
    var webSource = DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/browser.dart';
      import '$uri' as a;
      
      ${isApp ? '''
      void main() {
        runAppWithParams(getComponentForParams);
      }
      ''' : ''}
      
      Component getComponentForParams(ConfigParams p) {
        return a.${element.thisType.getDisplayString(withNullability: false)}(${params.where((p) => p.isPositional).map((p) => 'p.get(\'${p.name}\')').followedBy(params.where((p) => p.isNamed).map((p) => '${p.name}: p.get(\'${p.name}\')')).join(', ')});
      }
    ''');

    await buildStep.writeAsString(webId, webSource);
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
