import 'dart:io';

import 'package:mason/mason.dart' show ExitCode;
import 'package:pub_updater/pub_updater.dart';

import '../command_runner.dart';
import '../logging.dart';
import '../version.dart';
import 'base_command.dart';

class UpdateCommand extends BaseCommand {
  UpdateCommand({super.logger});

  final PubUpdater _updater = PubUpdater();

  @override
  final String description = 'Update the Jaspr cli.';

  @override
  final String name = 'update';

  @override
  String get category => 'Tooling';

  @override
  bool get requiresPubspec => false;

  @override
  Future<CommandResult?> run() async {
    await super.run();

    logger.write('Checking for updates', progress: ProgressState.running);
    late final String latestVersion;
    try {
      latestVersion = await _updater.getLatestVersion(packageName);
    } catch (error) {
      logger.complete(false);
      logger.write('$error', level: Level.error);
      return CommandResult.done(ExitCode.software.code);
    }
    logger.write('Checked for updates', progress: ProgressState.completed);

    final isUpToDate = jasprCliVersion == latestVersion;
    if (isUpToDate) {
      logger.write('jaspr is already at the latest version.');
      return null;
    }

    logger.write('Updating to $latestVersion', progress: ProgressState.running);
    late final ProcessResult result;
    try {
      result = await _updater.update(
        packageName: packageName,
        versionConstraint: latestVersion,
      );
    } catch (error) {
      logger.complete(false);
      logger.write('$error', level: Level.error);
      return CommandResult.done(ExitCode.software.code);
    }

    if (result.exitCode != ExitCode.success.code) {
      logger.write('Unable to update to $latestVersion', progress: ProgressState.completed);
      logger.write('${result.stderr}', level: Level.error);
      return CommandResult.done(ExitCode.software.code);
    }

    logger.write('Updated to $latestVersion', progress: ProgressState.completed);
    return null;
  }
}
