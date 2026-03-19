import 'dart:async';

import 'package:build/build.dart';
import 'package:collection/collection.dart';

import '../styles/styles_bundle_builder.dart';
import '../styles/styles_module_builder.dart';
import '../utils.dart';

/// Builds the standalone runner file for Jaspr projects.
class StylesStandaloneBuilder implements Builder {
  StylesStandaloneBuilder(this.options);

  final BuilderOptions options;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateStandaloneRunner(buildStep);
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
      '.client.dart': ['.client.styles.dart'],
      '.server.dart': ['.server.styles.dart'],
    };
  }

  Future<void> generateStandaloneRunner(BuildStep buildStep) async {
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

    final outputId = buildStep.inputId.changeExtension('.styles.dart');
    final runnerCode = ImportsWriter().resolve('''
    import 'dart:io';
    import 'dart:convert';
    
    import 'package:jaspr/src/dom/styles/rules.dart' show StyleRule, StyleRulesRender;
    [[/]]

    void main() {
      final List<StyleRule> styles = [
        ${buildStylesEntries(styles)}
      ];

      stdout.write(jsonEncode({
        'css': styles.render(),
      }));
    }
    ''');

    await buildStep.writeAsFormattedDart(outputId, runnerCode);
  }

  String buildStylesEntries(List<StylesModule> styles) {
    final filteredStyles = styles.where((s) => s.elements.isNotEmpty).toList();
    if (filteredStyles.isEmpty) return '';

    return filteredStyles.map((s) => s.elements.map((e) => '...[[${s.id.toImportUrl()}]].$e,').join('\n')).join('\n');
  }
}
