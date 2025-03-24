import 'dart:async';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';

import 'package:yaml/yaml.dart' as yaml;

import '../client/client_bundle_builder.dart';
import '../client/client_module_builder.dart';
import '../styles/styles_bundle_builder.dart';
import '../styles/styles_module_builder.dart';
import '../utils.dart';

/// Builds part files and web entrypoints for components annotated with @app
class JasprOptionsBuilder implements Builder {
  JasprOptionsBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateOptionsOutput(buildStep);
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
        r'lib/$lib$': ['lib/jaspr_options.dart'],
      };

  String get generationHeader => "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_builder\n";

  Future<void> generateOptionsOutput(BuildStep buildStep) async {
    final pubspecYaml = await buildStep.readAsString(AssetId(buildStep.inputId.package, 'pubspec.yaml'));
    final mode = yaml.loadYaml(pubspecYaml)?['jaspr']?['mode'];

    if (mode != 'static' && mode != 'server') {
      return;
    }

    var (clients, styles, sources) = await (
      buildStep.loadClients(),
      buildStep.loadStyles(),
      buildStep.loadTransitiveSources(),
    ).wait;

    final package = buildStep.inputId.package;

    clients = clients.where((c) => sources.contains(c.id)).toList()
      ..sortByCompare((c) => '${c.import}/${c.name}', ImportsWriter.compareImports);
    styles = styles
        .map((s) => sources.contains(s.id)
            ? s
            : StylesModule(
                id: s.id,
                elements: s.elements.where((e) => !e.contains('.')).toList(),
              ))
        .toList()
      ..sortByCompare((s) => s.id.toImportUrl(), ImportsWriter.compareImports);

    var source = '''
      $generationHeader
      
      import 'package:jaspr/jaspr.dart';
      [[/]]
      
      /// Default [JasprOptions] for use with your jaspr project.
      ///
      /// Use this to initialize jaspr **before** calling [runApp].
      ///
      /// Example:
      /// ```dart
      /// import 'jaspr_options.dart';
      /// 
      /// void main() {
      ///   Jaspr.initializeApp(
      ///     options: defaultJasprOptions,
      ///   );
      ///   
      ///   runApp(...);
      /// }
      /// ```
      JasprOptions get defaultJasprOptions => JasprOptions(
        ${buildClientEntries(clients, package)}
        ${buildStylesEntries(styles)}
      );
      
      ${buildClientParamGetters(clients)}  
    ''';
    source = ImportsWriter().resolve(source);
    source = DartFormatter(
      languageVersion: DartFormatter.latestShortStyleLanguageVersion,
      pageWidth: 120,
    ).format(source);

    final optionsId = AssetId(buildStep.inputId.package, 'lib/jaspr_options.dart');
    await buildStep.writeAsString(optionsId, source);
  }

  String buildClientEntries(List<ClientModule> clients, String package) {
    if (clients.isEmpty) return '';
    return 'clients: {${clients.map((c) {
      return '''
        [[${c.import}]].${c.name}: ClientTarget<[[${c.import}]].${c.name}>(
          '${c.resolveId(package)}'${c.params.isNotEmpty ? ', params: _[[${c.import}]]${c.name}' : ''}
        ),
      ''';
    }).join('\n')}},';
  }

  String buildClientParamGetters(List<ClientModule> clients) {
    return clients.where((c) => c.params.isNotEmpty).map((c) {
      return 'Map<String, dynamic> _[[${c.import}]]${c.name}([[${c.import}]].${c.name} c) => {${c.params.map((p) => "'${p.name}': ${p.encoder}").join(', ')}};';
    }).join('\n');
  }

  String buildStylesEntries(List<StylesModule> styles) {
    if (styles.isEmpty) return '';

    return 'styles: () => [${styles.map((s) {
      return s.elements.map((e) => '...[[${s.id.toImportUrl()}]].$e,').join('\n');
    }).join('\n')}],';
  }
}
