import 'dart:async';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../utils.dart';
import 'client_bundle_builder.dart';

/// Builds the registry for client components.
class ClientRegistryBuilder implements Builder {
  ClientRegistryBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      var source = await generateClients(buildStep);
      if (source != null) {
        var outputId = AssetId(buildStep.inputId.package, 'web/main.clients.dart');
        await buildStep.writeAsString(outputId, source);
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

  String get generationHeader => "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_builder\n";

  Future<String?> generateClients(BuildStep buildStep) async {
    final pubspecYaml = await buildStep.readAsString(AssetId(buildStep.inputId.package, 'pubspec.yaml'));
    final mode = yaml.loadYaml(pubspecYaml)?['jaspr']?['mode'];

    if (mode != 'static' && mode != 'server') {
      return null;
    }

    var (clients, sources) = await (
      buildStep.loadClients(),
      buildStep.loadTransitiveSources(),
    ).wait;

    clients = clients.where((c) => sources.contains(c.id)).toList();

    if (clients.isEmpty) {
      return null;
    }

    final package = buildStep.inputId.package;

    var source = '''
      $generationHeader
      
      import 'package:jaspr/browser.dart';
      [[/]]
      
      void main() {
        registerClients({
          ${clients.map((c) {
      final id = c.resolveId(package);
      final import = c.import.replaceFirst('.dart', '.client.dart');

      return '''
        '$id': loadClient([[$import]].loadLibrary, (p) => [[$import]].getComponentForParams(p)),
      ''';
    }).join('\n')}
        });
      }
    ''';

    source = ImportsWriter(deferred: true).resolve(source);
    source = DartFormatter(
      languageVersion: DartFormatter.latestShortStyleLanguageVersion,
      pageWidth: 120,
    ).format(source);
    return source;
  }
}
