import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:collection/collection.dart';

import '../styles/styles_bundle_builder.dart';
import '../styles/styles_module_builder.dart';
import '../utils.dart';

/// Builds the standalone module file for Jaspr projects.
class StylesStandaloneModuleBuilder implements Builder {
  StylesStandaloneModuleBuilder(this.options);

  final BuilderOptions options;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateStandaloneStylesModule(buildStep);
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
  Map<String, List<String>> get buildExtensions {
    return {
      '.client.dart': ['.client.css.json'],
      '.server.dart': ['.server.css.json'],
    };
  }

  Future<void> generateStandaloneStylesModule(BuildStep buildStep) async {
    final (mode, _, stylesOption) = await buildStep.loadProjectMode();
    if (mode == null) return;
    if (mode == JasprMode.client && !buildStep.inputId.path.endsWith('.client.dart')) {
      return;
    }
    if (mode != JasprMode.client && !buildStep.inputId.path.endsWith('.server.dart')) {
      return;
    }

    if (mode != JasprMode.client && stylesOption != StylesMode.standalone) {
      return;
    }

    final rootPath = options.config['root_path'] as String?;

    var (styles, sources) = await (
      buildStep.loadStyles(),
      rootPath != null
          ? buildStep.loadTransitiveSourcesFor(AssetId(buildStep.inputId.package, rootPath))
          : buildStep.loadTransitiveSources(),
    ).wait;

    if (sources.isNotEmpty) {
      styles = styles.filterBySources(sources, buildStep.inputId);
    }

    styles.sortByCompare((s) => s.id.toImportUrl(), comparePaths);

    final module = StylesStandaloneModule(mode: mode, styles: styles);

    final outputId = buildStep.inputId.changeExtension('.css.json');
    await buildStep.writeAsString(outputId, jsonEncode(module.serialize()));
  }
}

class StylesStandaloneModule {
  final JasprMode mode;
  final List<StylesModule> styles;

  StylesStandaloneModule({required this.mode, required this.styles});

  factory StylesStandaloneModule.deserialize(Map<String, Object?> map) {
    return StylesStandaloneModule(
      mode: JasprMode.values.firstWhere((m) => m.name == map['mode'] as String),
      styles: (map['styles'] as List<Object?>).map((e) => StylesModule.deserialize(e as Map<String, Object?>)).toList(),
    );
  }

  Map<String, Object?> serialize() => {
    'mode': mode.name,
    'styles': styles.map((m) => m.serialize()).toList(),
  };
}
