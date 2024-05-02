import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:build_modules/build_modules.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

Builder buildStylesheet(BuilderOptions options) => TailwindBuilder(options);

class TailwindBuilder implements Builder {
  TailwindBuilder(BuilderOptions options);

  @override
  Future<void> build(BuildStep buildStep) async {
    var scratchSpace = await buildStep.fetchResource(scratchSpaceResource);

    await scratchSpace.ensureAssets({buildStep.inputId}, buildStep);

    var outputId = buildStep.inputId.changeExtension('').changeExtension('.css');

    var packageFile = File('.dart_tool/package_config.json');
    var packageJson = jsonDecode(await packageFile.readAsString());

    var packageConfig = (packageJson['packages'] as List?)?.where((p) => p['name'] == 'jaspr_tailwind').firstOrNull;
    if (packageConfig == null) {
      print("Cannot find 'jaspr_tailwind' in package config.");
      return;
    }

    // in order to rebuild when source files change
    var assets = await buildStep.findAssets(Glob('{lib,web}/**.dart')).toList();
    await Future.wait(assets.map((a) => buildStep.canRead(a)));

    var root = p.normalize(p.join(Directory.current.path, '.dart_tool', Uri.parse(packageConfig['rootUri']!).path));

    var configFile = File('tailwind.config.js');
    var hasCustomConfig = await configFile.exists();

    await Process.run(
      'npx',
      [
        'tailwindcss',
        '--input',
        scratchSpace.fileFor(buildStep.inputId).path,
        '--output',
        scratchSpace.fileFor(outputId).path.toPosix(),
        '--content',
        p.join(Directory.current.path, '{lib,web}', '**', '*.dart').toPosix(true),
        if (hasCustomConfig) ...[
          '--config',
          p.join(Directory.current.path, 'tailwind.config.js'),
        ],
      ],
      workingDirectory: root,
    );

    await scratchSpace.copyOutput(outputId, buildStep);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        'web/{{file}}.tw.css': ['web/{{file}}.css']
      };
}

extension POSIXPath on String {
  String toPosix([bool quoted = false]) {
    if (Platform.isWindows) {
      final result = replaceAll('\\', '/');
      return quoted ? "'$result'" : result;
    }
    return this;
  }
}
