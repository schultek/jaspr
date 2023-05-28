import 'dart:async';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

/// Builds web entrypoints for components annotated with @app
class ClientRegistryBuilder implements Builder {
  ClientRegistryBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      var appsSource = await generateApps(buildStep);
      if (appsSource != null) {
        var outputId = AssetId(buildStep.inputId.package, 'web/main.clients.dart');
        await buildStep.writeAsString(
          outputId,
          appsSource,
        );
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

  Future<String?> generateApps(BuildStep buildStep) async {
    var apps = await buildStep.findAssets(Glob('web/**.client.dart')).toList();

    if (apps.isEmpty) {
      return null;
    }

    return DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/browser.dart';
      ${apps.mapIndexed((index, c) => "import '${path.url.relative(c.path, from: 'web')}' deferred as i$index;").join('\n')}
      
      void main() {
        registerClients({
          ${apps.mapIndexed((index, c) {
      return '''
              '${path.url.relative(path.url.withoutExtension(path.url.withoutExtension(c.path)), from: 'web')}': loadClient(i$index.loadLibrary, 
              (p) => i$index.getComponentForParams(p),
              ),
            ''';
    }).join('\n')}
        });
      }
    ''');
  }
}
