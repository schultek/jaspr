import 'dart:io';

import 'package:mason/mason.dart' show ExitCode;

import '../command_runner.dart';
import '../logging.dart';
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
      logger.write('Jaspr is already at the latest version.');
      return 0;
    }

    logger.write('Updating jaspr_cli to $latestVersion...', progress: ProgressState.running);
    late final ProcessResult result;
    try {
      result = await updater.update(packageName: packageName, versionConstraint: latestVersion);
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
      'There might be automatic code migrations available for your project. '
      'Run \'jaspr migrate\' to check for available migrations.',
    );

    return 0;
  }
}
