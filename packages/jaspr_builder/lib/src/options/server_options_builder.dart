import 'dart:async';

import 'package:build/build.dart';
import 'package:collection/collection.dart';

import '../client/client_bundle_builder.dart';
import '../client/client_module_builder.dart';
import '../styles/styles_bundle_builder.dart';
import '../styles/styles_module_builder.dart';
import '../utils.dart';

/// Builds the server options file for jaspr projects.
class ServerOptionsBuilder implements Builder {
  ServerOptionsBuilder(this.options);

  final BuilderOptions options;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateServerOptions(buildStep);
    } catch (e, st) {
      print(
        'An unexpected error occurred.\n'
        'This is probably a bug in jaspr_builder.\n'
        'Please report this here: '
        'https://github.com/schultek/jaspr/issues\n\n'
        'The error was:\n$e\n\n$st',
      );
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    r'lib/{{file}}.server.dart': ['lib/{{file}}.server.options.dart'],
  };

  String get generationHeader =>
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n';

  Future<void> generateServerOptions(BuildStep buildStep) async {
    final (mode, _, stylesMode) = await buildStep.loadProjectMode();
    if (mode == null || mode == JasprMode.client) {
      return;
    }

    final rootPath = options.config['root_path'] as String?;

    var (clients, styles, sources) = await (
      buildStep.loadClients(),
      stylesMode == StylesMode.standalone ? Future.value(<StylesModule>[]) : buildStep.loadStyles(),
      rootPath != null
          ? buildStep.loadTransitiveSourcesFor(AssetId(buildStep.inputId.package, rootPath))
          : buildStep.loadTransitiveSources(),
    ).wait;

    final package = buildStep.inputId.package;

    if (sources.isNotEmpty) {
      clients = clients.filterBySources(sources);
      styles = styles.filterBySources(sources, buildStep.inputId);
    }

    clients.sortByCompare((c) => '${c.import}/${c.name}', comparePaths);

    final optionsId = buildStep.inputId.changeExtension('.options.dart');

    var source =
        '''
      import 'package:jaspr/server.dart';
      [[/]]
      
      /// Default [ServerOptions] for use with your Jaspr project.
      ///
      /// Use this to initialize Jaspr **before** calling [runApp].
      ///
      /// Example:
      /// ```dart
      /// import '${optionsId.path.split('/').last}';
      /// 
      /// void main() {
      ///   Jaspr.initializeApp(
      ///     options: defaultServerOptions,
      ///   );
      ///   
      ///   runApp(...);
      /// }
      /// ```
    ''';
    source += 'ServerOptions get defaultServerOptions => ServerOptions(';
    source += await buildClientIdEntry(buildStep);
    source += buildClientEntries(clients, package);
    if (stylesMode == StylesMode.standalone) {
      final stylesId = buildStep.inputId.path.replaceFirst('lib/', '').replaceFirst('.server.dart', '.css');
      source += "stylesId: '$stylesId',";
    } else if (styles.toOutputString() case final stylesOutput when stylesOutput.isNotEmpty) {
      source += 'styles: () => $stylesOutput,';
    }
    source += ');\n\n';
    source += buildClientParamGetters(clients);

    source = ImportsWriter().resolve(source);
    await buildStep.writeAsFormattedDart(optionsId, source);
  }

  Future<String> buildClientIdEntry(BuildStep buildStep) async {
    final clientId = buildStep.inputId.path.replaceFirst('.server.dart', '.client.dart');
    if (!(await buildStep.canRead(AssetId(buildStep.inputId.package, clientId)))) {
      return '';
    }
    return "clientId: '${clientId.replaceFirst('lib/', '')}.js',";
  }

  String buildClientEntries(List<ClientModule> clients, String package) {
    if (clients.isEmpty) return '';

    final compressed = compressPaths(clients.map((c) => c.id.path).toList());

    return 'clients: {${clients.map((c) {
      final id = compressed[c.id.path]!;
      final fullId = c.id.package != package ? '${c.id.package}:$id' : id;

      return '''
        [[${c.import}]].${c.name}: ClientTarget<[[${c.import}]].${c.name}>(
          '$fullId'${c.params.isNotEmpty ? ', params: _[[${c.import}]]${c.name}' : ''}
        ),
      ''';
    }).join()}},';
  }

  String buildClientParamGetters(List<ClientModule> clients) {
    return clients
        .where((c) => c.params.isNotEmpty)
        .map((c) {
          return 'Map<String, Object?> _[[${c.import}]]${c.name}([[${c.import}]].${c.name} c) => {${c.params.map((p) => "'${p.name}': ${p.encoder}").join(', ')}};';
        })
        .join('\n');
  }

  String buildStylesIdEntry(StylesMode? stylesOption, BuildStep buildStep) {
    if (stylesOption != StylesMode.standalone) return '';
    final stylesId = buildStep.inputId.path.replaceFirst('lib/', '').replaceFirst('.server.dart', '.css');
    return "stylesId: '$stylesId',";
  }
}
