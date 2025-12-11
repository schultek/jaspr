import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:glob/glob.dart';

import '../utils.dart';
import 'styles_module_builder.dart';

/// Builds bundle for all styles modules.
class StylesBundleBuilder implements Builder {
  StylesBundleBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateStylesBundle(buildStep);
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
    r'lib/$lib$': ['lib/styles.bundle.json'],
  };

  Future<void> generateStylesBundle(BuildStep buildStep) async {
    final modules = await buildStep
        .findAssets(Glob('lib/**.styles.json'))
        .asyncMap((id) => buildStep.readAsString(id))
        .map((c) => jsonDecode(c))
        .toList();

    if (modules.isEmpty) return;

    final outputId = AssetId(buildStep.inputId.package, 'lib/styles.bundle.json');
    await buildStep.writeAsString(outputId, jsonEncode(modules));
  }
}

extension StylesLoader on BuildStep {
  Future<List<StylesModule>> loadStyles() async {
    final bundle = await loadBundle<StylesModule>('styles', StylesModule.deserialize).toList();
    return bundle;
  }
}
