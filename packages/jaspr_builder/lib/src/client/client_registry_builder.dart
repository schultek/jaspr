import 'dart:async';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

/// Builds the registry for client components.
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
    var moduleFiles = await buildStep.findAssets(Glob('lib/**.client.json')).toList();

    if (moduleFiles.isEmpty) {
      return null;
    }

    var modules = moduleFiles.map((id) => id.changeExtension('.dart'));

    return DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/browser.dart';
      ${modules.mapIndexed((index, c) => "import '${path.url.relative(c.path, from: 'lib')}' deferred as i$index;").join('\n')}
      
      void main() {
        registerClients({
          ${modules.mapIndexed((index, c) {
      return '''
              '${path.url.relative(path.url.withoutExtension(path.url.withoutExtension(c.path)), from: 'lib')}': loadClient(i$index.loadLibrary, 
              (p) => i$index.getComponentForParams(p),
              ),
            ''';
    }).join('\n')}
        });
      }
    ''');
  }
}
