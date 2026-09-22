import 'dart:async';
import 'dart:io';

import 'package:mason/mason.dart' show cyan, styleBold;

import '../logging.dart';
import '../process_runner.dart';
import '../project.dart';
import '../utils.dart';

/// Checks if any Jaspr skills are installed by running `dart run skills@ list`.
Future<bool> checkJasprSkillsInstalled({String? workingDirectory}) async {
  try {
    final result = await ProcessRunner.instance
        .run(
          dartExecutable,
          ['run', 'skills@', 'list'],
          workingDirectory: workingDirectory,
        )
        .timeout(const Duration(seconds: 5));

    if (result.exitCode == 0) {
      final output = result.stdout.toString();
      return output.contains('package:jaspr');
    }
    return false;
  } catch (_) {
    return false;
  }
}

/// Runs `dart run skills@` interactively with inherited stdio.
Future<int> installJasprSkills({required String workingDirectory}) async {
  try {
    final process = await ProcessRunner.instance.start(
      dartExecutable,
      ['run', 'skills@', 'get', '-p', 'jaspr', '-a'],
      workingDirectory: workingDirectory,
      mode: ProcessStartMode.inheritStdio,
    );
    return await process.exitCode;
  } catch (_) {
    return 1;
  }
}

/// Prints a promotional banner explaining how to install Jaspr AI skills.
void printSkillsPromoBanner(Logger logger) {
  logger.write(
    wrapBox(
      '${styleBold.wrap('Boost your development with Jaspr AI Skills!')}\n\n'
      'Jaspr provides official AI skills to help coding assistants (Claude, Cursor, Codex, etc.) '
      'work seamlessly with your Jaspr projects.\n\n'
      'To install them, run:\n'
      '  ${cyan.wrap(styleBold.wrap('dart run skills@ get -p jaspr -a'))}',
      borderColor: cyan,
    ),
  );
}
