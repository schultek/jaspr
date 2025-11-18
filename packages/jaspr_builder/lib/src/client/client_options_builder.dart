import 'dart:async';

import 'package:build/build.dart';

import '../utils.dart';
import 'client_bundle_builder.dart';
import 'client_module_builder.dart';

/// Builds the options file for client components.
class ClientOptionsBuilder implements Builder {
  ClientOptionsBuilder(this.options);

  final BuilderOptions options;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      var source = await generateClients(buildStep);
      if (source != null) {
        var outputId = AssetId(buildStep.inputId.package, 'lib/options.client.g.dart');
        await buildStep.writeAsFormattedDart(outputId, source);
      }
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
    'lib/\$lib\$': ['lib/options.client.g.dart'],
  };

  Future<String?> generateClients(BuildStep buildStep) async {
    final (:mode, :target) = await buildStep.loadProjectConfig(options, buildStep);

    if (mode != 'static' && mode != 'server') {
      return null;
    }

    var (clients, sources) = await (
      buildStep.loadClients(),
      buildStep.loadTransitiveSources(target),
    ).wait;

    clients = clients.where((c) => sources.contains(c.id)).toList();

    final package = buildStep.inputId.package;

    var source =
        '''
      import 'package:jaspr/browser.dart';
      [[/]]

      /// Default [ClientOptions] for use with your Jaspr project.
      ///
      /// Pass this to [ClientApp].
      ///
      /// Example:
      /// ```dart
      /// import 'options.client.g.dart';
      /// 
      /// void main() {
      ///   runApp(ClientApp(
      ///     options: defaultClientOptions,
      ///   ));
      /// }
      /// ```
      ClientOptions get defaultClientOptions => ClientOptions(
        ${buildClientEntries(clients, package)}
      );
    ''';

    source = ImportsWriter(deferred: true).resolve(source);
    return source;
  }

  String buildClientEntries(List<ClientModule> clients, String package) {
    if (clients.isEmpty) return '';
    return 'clients: {${clients.map((c) {
      final id = c.resolveId(package);
      return '''
        '$id': ClientLoader([[${c.import}]].loadLibrary, (p) => ${c.componentFactory()}),
      ''';
    }).join()}},';
  }
}
