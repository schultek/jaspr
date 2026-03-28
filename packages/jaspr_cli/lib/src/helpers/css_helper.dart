import 'dart:convert';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;

import '../commands/base_command.dart';
import '../logging.dart';
import '../process_runner.dart';
import '../project.dart';

extension CssHelper on BaseCommand {
  Future<int> generateCss() async {
    final projectName = project.requirePubspecYaml['name'] as String;
    final buildDir = '.dart_tool/build/generated/$projectName/lib';

    if (!Directory(buildDir).absolute.existsSync()) {
      return 0;
    }

    bool hasError = false;

    final runnerFiles = Glob('$buildDir/**.styles.dart').list(root: Directory.current.path);
    await for (final runnerFile in runnerFiles) {
      if (!runnerFile.path.endsWith('.server.styles.dart') && !runnerFile.path.endsWith('.client.styles.dart')) {
        continue;
      }

      final outputFile = p
          .relative(runnerFile.path, from: p.join(Directory.current.path, buildDir))
          .replaceFirst('.server.styles.dart', '.css')
          .replaceFirst('.client.styles.dart', '.css');

      final result = await ProcessRunner.instance.run(dartExecutable, [
        'run',
        runnerFile.path,
      ], workingDirectory: Directory.current.path);
      if (result.exitCode != 0) {
        logger.write(
          'Failed to generate $outputFile, the script exited with code ${result.exitCode}:\n${result.stderr}',
          tag: Tag.cli,
          level: Level.error,
        );
        logger.write(
          'Run: `dart run ${runnerFile.path}` to debug this error.',
          tag: Tag.cli,
          level: Level.verbose,
        );
        hasError = true;
        continue;
      }

      final json = jsonDecode(result.stdout.toString());
      if (json case {'css': final String cssValue}) {
        File('.dart_tool/jaspr/generated/$outputFile').absolute
          ..createSync(recursive: true)
          ..writeAsStringSync(cssValue);
        logger.write(
          'Generated $outputFile',
          tag: Tag.cli,
        );
      }
    }

    return hasError ? 1 : 0;
  }

  Future<int> buildCss() async {
    final exitCode = await generateCss();

    await copyToBuildDir('.dart_tool/jaspr/generated');

    return exitCode;
  }
}
