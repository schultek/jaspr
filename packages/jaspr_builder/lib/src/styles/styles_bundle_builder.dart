import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
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

extension StylesFilter on List<StylesModule> {
  List<StylesModule> filterBySources(Set<AssetId> sources, AssetId rootId) {
    return map((s) {
      if (sources.contains(s.id)) {
        // For imported libraries include all styles.
        return s;
      } else if (s.id.package == rootId.package) {
        // For unimported libraries from the same package, include only global styles.
        return StylesModule(id: s.id, elements: s.elements.where((e) => !e.contains('.')).toList());
      } else {
        // For unimported libraries from other packages, exclude all styles.
        return StylesModule(id: s.id, elements: []);
      }
    }).toList();
  }

  String toOutputString() {
    final globalStyles = expand(
      (s) => s.elements.where((e) => !e.contains('.')).map((e) => (s.id, e)),
    ).sortedByCompare((s) => s.$1.toImportUrl(), comparePathsWithPriority);
    final componentStyles = expand(
      (s) => s.elements.where((e) => e.contains('.')).map((e) => (s.id, e)),
    ).sortedByCompare((s) => s.$1.toImportUrl(), comparePathsWithPriority);

    var styleItems = '';
    for (final (id, element) in globalStyles) {
      styleItems += '\n    ...[[${id.toImportUrl()}]].$element,';
    }
    for (final (id, element) in componentStyles) {
      styleItems += '\n    ...[[${id.toImportUrl()}]].$element,';
    }
    if (styleItems.isNotEmpty) {
      styleItems += '\n  ';
    }

    return '[$styleItems]';
  }
}
