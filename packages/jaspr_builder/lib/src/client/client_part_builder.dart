import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;

import 'client_module_builder.dart';

/// Builds part files and web entrypoints for components annotated with @client
class ClientPartBuilder implements Builder {
  ClientPartBuilder(BuilderOptions options);

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
        'lib/{{file}}.client.json': ['lib/{{file}}.g.dart'],
      };

  String get generationHeader => "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_builder\n";

  Future<void> generateComponentOutputs(BuildStep buildStep) async {
    var moduleJson = await buildStep.readAsString(buildStep.inputId);
    var module = ClientModule.deserialize(jsonDecode(moduleJson));

    var part = '${path.url.basenameWithoutExtension(module.id.path)}.g.dart';

    final libraryUnit = await buildStep.resolver.compilationUnitFor(module.id);
    final hasPartDirective = libraryUnit.directives.whereType<PartDirective>().any((e) => e.uri.stringValue == part);

    if (!hasPartDirective) {
      log.warning(
        '$part must be included as a part directive in '
        'the input library with:\n    part \'$part\';',
      );
    }

    var partId = module.id.changeExtension('.g.dart');
    var partSource = DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      part of '${path.url.basename(module.id.path)}';
      
      mixin _\$${module.name} implements ComponentEntryMixin<${module.name}> {
        @override
        ComponentEntry<${module.name}> get entry {
          ${module.params.isNotEmpty ? 'var self = this as ${module.name};' : ''}
          return ComponentEntry.client(
            '${path.url.relative(path.url.withoutExtension(module.id.path), from: 'lib')}'
            ${module.params.isNotEmpty ? ', params: {${module.params.map((p) => "'${p.name}': self.${p.name}").join(', ')}},' : ''}
          );
        }
      }
    ''');

    await buildStep.writeAsString(partId, partSource);
  }
}
