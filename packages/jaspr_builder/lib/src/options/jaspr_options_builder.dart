import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:yaml/yaml.dart' as yaml;

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
      loadClientModules(buildStep),
      loadStylesModules(buildStep),
      loadTransitiveSources(buildStep),
    ).wait;

    clients.sortByCompare((c) => '${c.import}/${c.name}', ImportsWriter.compareImports);
    styles = [
      for (var s in styles)
        sources.contains(s.id)
            ? s
            : StylesModule(id: s.id, elements: s.elements.where((e) => !e.contains('.')).toList())
    ]..sortByCompare((s) => s.id.toImportUrl(), ImportsWriter.compareImports);

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
      final defaultJasprOptions = JasprOptions(
        ${buildClientEntries(clients)}
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

  Future<List<ClientModule>> loadClientModules(BuildStep buildStep) async {
    return buildStep
        .findAssets(Glob('lib/**.client.json'))
        .asyncMap((id) => buildStep.readAsString(id))
        .map((c) => ClientModule.deserialize(jsonDecode(c)))
        .toList();
  }

  Future<List<StylesModule>> loadStylesModules(BuildStep buildStep) async {
    return await buildStep.loadStyles();
  }

  Future<Set<AssetId>> loadTransitiveSources(BuildStep buildStep) async {
    final main = AssetId(buildStep.inputId.package, 'lib/main.dart');
    if (!await buildStep.canRead(main)) {
      return {};
    }
    await buildStep.resolver.libraryFor(main);
    return buildStep.resolver.libraries.expand<AssetId>((lib) {
      try {
        return [AssetId.resolve(lib.source.uri)];
      } catch (_) {
        return [];
      }
    }).toSet();
  }

  String buildClientEntries(List<ClientModule> clients) {
    if (clients.isEmpty) return '';
    return 'clients: {${clients.map((c) {
      return '''
        [[${c.import}]].${c.name}: ClientTarget<[[${c.import}]].${c.name}>(
          '${c.id}'
          ${c.params.isNotEmpty ? ', params: _[[${c.import}]]${c.name}' : ''}
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
