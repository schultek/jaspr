import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

import '../styles/styles_bundle_builder.dart';
import '../styles/styles_module_builder.dart';
import '../utils.dart';

/// Builds the standalone css file for jaspr projects.
class StylesOutputBuilder implements Builder {
  StylesOutputBuilder(this.options);

  final BuilderOptions options;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateStandaloneStyles(buildStep);
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

  late final JasprMode? jasprMode = () {
    if (options.config['jaspr-mode'] case final String mode) {
      return JasprMode.values.firstWhere((m) => m.name == mode);
    }

    if (!options.isRoot) return null;

    try {
      final pubspecYaml = File('pubspec.yaml').readAsStringSync();
      final jasprConfig = (yaml.loadYaml(pubspecYaml) as Map<Object?, Object?>?)?['jaspr'] as Map<Object?, Object?>?;
      final mode = jasprConfig?['mode'] as String?;
      return JasprMode.values.firstWhere((m) => m.name == mode);
    } catch (e) {
      return null;
    }
  }();

  @override
  Map<String, List<String>> get buildExtensions {
    return {
      'lib/{{file}}.${jasprMode == JasprMode.client ? 'client' : 'server'}.dart': ['web/{{file}}.css'],
    };
  }

  String get generationHeader =>
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n';

  Future<void> generateStandaloneStyles(BuildStep buildStep) async {
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

    final pathWithoutExtension = path.posix.withoutExtension(path.posix.withoutExtension(buildStep.inputId.path));

    final runnerId = AssetId(
      buildStep.inputId.package,
      '${pathWithoutExtension.replaceFirst('lib/', '.dart_tool/jaspr/')}.styles.dart',
    );

    final runnerCode = ImportsWriter().resolve('''
    $generationHeader

    import 'dart:io';
    import 'dart:convert';
    
    import 'package:jaspr/src/dom/styles/rules.dart' show StyleRulesRender;
    [[/]]

    void main() {
      final styles = [
        ${buildStylesEntries(styles)}
      ];

      stdout.write(jsonEncode({
        'css': styles.render(),
      }));
    }
    ''');

    File(runnerId.path)
      ..createSync(recursive: true)
      ..writeAsStringSync(
        DartFormatter(languageVersion: DartFormatter.latestLanguageVersion).format(runnerCode),
      );

    String css;
    try {
      final result = Process.runSync('dart', ['run', runnerId.path]);
      if (result.exitCode != 0) throw result.stderr.toString();

      final json = jsonDecode(result.stdout.toString());
      if (json case {'css': final String cssValue}) {
        css = cssValue;
      } else {
        throw 'Invalid output: ${result.stdout}';
      }
    } catch (e) {
      throw Exception('Failed to generate styles: $e');
    }

    final outputId = AssetId(
      buildStep.inputId.package,
      '${pathWithoutExtension.replaceFirst('lib/', 'web/')}.css',
    );

    await buildStep.writeAsString(outputId, css);
  }

  String buildStylesEntries(List<StylesModule> styles) {
    final filteredStyles = styles.where((s) => s.elements.isNotEmpty).toList();
    if (filteredStyles.isEmpty) return '';

    return filteredStyles.map((s) => s.elements.map((e) => '...[[${s.id.toImportUrl()}]].$e,').join('\n')).join('\n');
  }
}
