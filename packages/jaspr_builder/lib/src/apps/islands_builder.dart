import 'dart:async';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

class IslandsBuilder implements Builder {
  IslandsBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      var islandsSource = await generateIslands(buildStep);
      if (islandsSource != null) {
        var outputId = AssetId(buildStep.inputId.package, 'web/main.islands.dart');
        await buildStep.writeAsString(
          outputId,
          islandsSource,
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
        'lib/\$lib\$': ['web/main.islands.dart']
      };

  String get generationHeader => "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_builder\n";

  Future<String?> generateIslands(BuildStep buildStep) async {
    var islands = await buildStep.findAssets(Glob('web/**.island.dart')).toList();

    if (islands.isEmpty) {
      return null;
    }

    return DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/browser.dart';
      ${islands.mapIndexed((index, c) => "import '${path.url.relative(c.path, from: 'web')}' deferred as i$index;").join('\n')}
      
      void main() {
        runIslandsDeferred({
          ${islands.mapIndexed((index, c) {
      return '''
              '${path.url.relative(path.url.withoutExtension(path.url.withoutExtension(c.path)), from: 'web')}': loadIsland(i$index.loadLibrary, 
              (p) => i$index.getComponentForParams(p),
              ),
            ''';
    }).join('\n')}
        });
      }
    ''');
  }
}
