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
      await generateOptionsOutput(buildStep);
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
    r'lib/$lib$': ['lib/options.server.g.dart'],
  };

  String get generationHeader =>
      "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_builder\n";

  Future<void> generateOptionsOutput(BuildStep buildStep) async {
    final (:mode, :target) = await buildStep.loadProjectConfig(options, buildStep);

    if (mode != 'static' && mode != 'server') {
      return;
    }

    var (clients, styles, sources) = await (
      buildStep.loadClients(),
      buildStep.loadStyles(),
      buildStep.loadTransitiveSources(target),
    ).wait;

    final package = buildStep.inputId.package;

    if (sources.isNotEmpty) {
      clients = clients.where((c) => sources.contains(c.id)).toList();
      styles = styles.map((s) {
        if (sources.contains(s.id)) {
          // For imported libraries include all styles.
          return s;
        } else if (s.id.package == buildStep.inputId.package) {
          // For unimported libraries from the same package, include only global styles.
          return StylesModule(id: s.id, elements: s.elements.where((e) => !e.contains('.')).toList());
        } else {
          // For unimported libraries from other packages, exclude all styles.
          return StylesModule(id: s.id, elements: []);
        }
      }).toList();
    }

    clients.sortByCompare((c) => '${c.import}/${c.name}', ImportsWriter.compareImports);
    styles.sortByCompare((s) => s.id.toImportUrl(), ImportsWriter.compareImports);

    var source =
        '''
      import 'package:jaspr/jaspr.dart';
      [[/]]
      
      /// Default [ServerOptions] for use with your Jaspr project.
      ///
      /// Use this to initialize Jaspr **before** calling [runApp].
      ///
      /// Example:
      /// ```dart
      /// import 'options.server.g.dart';
      /// 
      /// void main() {
      ///   Jaspr.initializeApp(
      ///     options: defaultServerOptions,
      ///   );
      ///   
      ///   runApp(...);
      /// }
      /// ```
      ServerOptions get defaultServerOptions => ServerOptions(
        ${buildClientEntries(clients, package)}
        ${buildStylesEntries(styles)}
      );
      
      ${buildClientParamGetters(clients)}  
    ''';
    source = ImportsWriter().resolve(source);
    final optionsId = AssetId(buildStep.inputId.package, 'lib/options.server.g.dart');
    await buildStep.writeAsFormattedDart(optionsId, source);
  }

  String buildClientEntries(List<ClientModule> clients, String package) {
    if (clients.isEmpty) return '';
    return 'clients: {${clients.map((c) {
      return '''
        [[${c.import}]].${c.name}: ClientTarget<[[${c.import}]].${c.name}>(
          '${c.resolveId(package)}'${c.params.isNotEmpty ? ', params: _[[${c.import}]]${c.name}' : ''}
        ),
      ''';
    }).join()}},';
  }

  String buildClientParamGetters(List<ClientModule> clients) {
    return clients
        .where((c) => c.params.isNotEmpty)
        .map((c) {
          return 'Map<String, dynamic> _[[${c.import}]]${c.name}([[${c.import}]].${c.name} c) => {${c.params.map((p) => "'${p.name}': ${p.encoder}").join(', ')}};';
        })
        .join('\n');
  }

  String buildStylesEntries(List<StylesModule> styles) {
    final filteredStyles = styles.where((s) => s.elements.isNotEmpty).toList();
    if (filteredStyles.isEmpty) return '';

    return 'styles: () => [${filteredStyles.map((s) {
      return s.elements.map((e) => '...[[${s.id.toImportUrl()}]].$e,').join('\n');
    }).join('\n')}],';
  }
}
