import 'dart:io';

import 'package:io/ansi.dart';
import 'package:mason/mason.dart' show ExitCode, green;

import '../command_runner.dart';
import '../helpers/print_logo.dart';
import '../logging.dart';
import '../utils.dart';
import '../version.dart';
import 'base_command.dart';

class UpdateCommand extends BaseCommand {
  UpdateCommand({super.logger});

  @override
  final String description = 'Update the Jaspr cli.';

  @override
  final String name = 'update';

  @override
  String get category => 'Tooling';

  @override
  Future<int> runCommand() async {
    printLogo();

    logger.write('Checking for updates...', progress: ProgressState.running);

    late final String latestVersion;
    try {
      latestVersion = await updater.getLatestVersion(packageName);
    } catch (error) {
      logger.complete(false);
      logger.write('$error', level: Level.error);
      return ExitCode.software.code;
    }
    logger.write('Checked for updates.', progress: ProgressState.completed);

    final isUpToDate = jasprCliVersion == latestVersion;
    if (isUpToDate) {
      logger.write(wrapBox('Jaspr is already at the latest version.', borderColor: green));
      return 0;
    }

    logger.write('Updating jaspr_cli to $latestVersion...', progress: ProgressState.running);

    late final ProcessResult result;
    try {
      // If the cli is installed as aot snapshot, we need to use 'dart install' instead of 'dart pub global activate'.
      if (Platform.resolvedExecutable.endsWith('/jaspr')) {
        result = await Process.run('dart', ['install', packageName, latestVersion]);
      } else {
        result = await updater.update(packageName: packageName, versionConstraint: latestVersion);
      }
    } catch (error) {
      logger.complete(false);
      logger.write('$error', level: Level.error);
      return ExitCode.software.code;
    }

    if (result.exitCode != ExitCode.success.code) {
      logger.write('Unable to update jaspr_cli to $latestVersion.', progress: ProgressState.completed);
      logger.write('${result.stderr}', level: Level.error);
      return ExitCode.software.code;
    }

    logger.write('Updated jaspr_cli to $latestVersion.', progress: ProgressState.completed);

    logger.write(
      wrapBox(
        'Jaspr CLI is now at ${cyan.wrap(latestVersion)}.\n\n'
        'There might be automatic code migrations available for your project.\n'
        'Run ${styleItalic.wrap(cyan.wrap('jaspr migrate'))} to check for available migrations.',
        borderColor: green,
      ),
    );

    return 0;
  }
}
