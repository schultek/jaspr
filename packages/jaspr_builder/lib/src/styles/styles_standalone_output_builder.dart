import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;

import '../styles/styles_module_builder.dart';
import '../utils.dart';
import 'styles_standalone_module_builder.dart';

/// Builds the standalone css file for jaspr projects.
class StylesStandaloneOutputBuilder implements PostProcessBuilder {
  StylesStandaloneOutputBuilder(this.options);

  final BuilderOptions options;

  @override
  List<String> get inputExtensions => ['.client.css.json', '.server.css.json'];

  @override
  FutureOr<void> build(PostProcessBuildStep buildStep) async {
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

  String get generationHeader =>
      '// GENERATED FILE, DO NOT MODIFY\n'
      '// Generated with jaspr_builder\n';

  Future<void> generateStandaloneStyles(PostProcessBuildStep buildStep) async {
    final module = StylesStandaloneModule.deserialize(
      jsonDecode(await buildStep.readInputAsString()) as Map<String, Object?>,
    );

    final workingDir = options.config['working_directory'] as String?;
    final pathWithoutExtension = buildStep.inputId.path
        .replaceFirst('.client.css.json', '')
        .replaceFirst('.server.css.json', '');

    final runnerId = AssetId(
      buildStep.inputId.package,
      '${pathWithoutExtension.replaceFirst('lib/', '.dart_tool/jaspr/')}.styles.dart',
    );

    final runnerCode = ImportsWriter().resolve('''
    $generationHeader

    import 'dart:io';
    import 'dart:convert';
    
    import 'package:jaspr/src/dom/styles/rules.dart' show StyleRule, StyleRulesRender;
    [[/]]

    void main() {
      final List<StyleRule> styles = [
        ${buildStylesEntries(module.styles)}
      ];

      stdout.write(jsonEncode({
        'css': styles.render(),
      }));
    }
    ''');

    final runnerFile = File(path.join(workingDir ?? '', runnerId.path));
    runnerFile
      ..createSync(recursive: true)
      ..writeAsStringSync(
        DartFormatter(languageVersion: DartFormatter.latestLanguageVersion).format(runnerCode),
      );

    String css;
    try {
      final result = Process.runSync('dart', ['run', runnerId.path], workingDirectory: workingDir);
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
