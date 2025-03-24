import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:glob/glob.dart';

import '../utils.dart';
import 'client_module_builder.dart';

/// Builds the registry for client components.
class ClientRegistryBuilder implements Builder {
  ClientRegistryBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      var source = await generateClients(buildStep);
      if (source != null) {
        var outputId = AssetId(buildStep.inputId.package, 'web/main.clients.dart');
        await buildStep.writeAsFormattedDart(outputId, source);
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
        'lib/\$lib\$': ['web/main.clients.dart']
      };

  Future<String?> generateClients(BuildStep buildStep) async {
    var modules = buildStep
        .findAssets(Glob('lib/**.client.json'))
        .asyncMap((id) => buildStep.readAsString(id))
        .map((c) => ClientModule.deserialize(jsonDecode(c)));

    var entrypoints = [
      await for (var module in modules) (id: module.id, import: '${module.id}.client.dart'),
    ];

    if (entrypoints.isEmpty) {
      return null;
    }

    var source = '''
      import 'package:jaspr/browser.dart';
      [[/]]
      
      void main() {
        registerClients({
          ${entrypoints.map((e) => '''
            '${e.id}': loadClient([[${e.import}]].loadLibrary, (p) => [[${e.import}]].getComponentForParams(p)),
          ''').join('\n')}
        });
      }
    ''';

    source = ImportsWriter(deferred: true).resolve(source);
    return source;
  }
}
