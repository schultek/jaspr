import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:glob/glob.dart';

import '../utils.dart';
import 'client_module_builder.dart';

/// Builds bundle for all client modules.
class ClientsBundleBuilder implements Builder {
  ClientsBundleBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateClientsBundle(buildStep);
    } on SyntaxErrorInAssetException {
      rethrow;
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
    r'lib/$lib$': ['lib/clients.bundle.json'],
  };

  Future<void> generateClientsBundle(BuildStep buildStep) async {
    final modules = await buildStep
        .findAssets(Glob('lib/**.client.module.json'))
        .asyncMap((id) => buildStep.readAsString(id))
        .map((c) => jsonDecode(c))
        .toList();

    if (modules.isEmpty) return;

    final outputId = AssetId(buildStep.inputId.package, 'lib/clients.bundle.json');
    await buildStep.writeAsString(outputId, jsonEncode(modules));
  }
}

extension ClientsLoader on BuildStep {
  Future<List<ClientModule>> loadClients() async {
    final bundle = await loadBundle<ClientModule>('clients', ClientModule.deserialize).toList();
    return bundle;
  }
}
