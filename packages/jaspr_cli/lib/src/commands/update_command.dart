import 'dart:io';

import 'package:io/ansi.dart';
import 'package:mason/mason.dart' show ExitCode, green;

import '../command_runner.dart';
import '../helpers/print_logo.dart';
import '../helpers/skills_helper.dart';
import '../logging.dart';
import '../process_runner.dart';
import '../project.dart';
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

    final currentVersion = jasprCliVersion;

    late final String latestVersion;
    try {
      latestVersion = await updater.getLatestVersion(packageName);
    } catch (error) {
      logger.complete(false);
      logger.write('$error', level: Level.error);
      return ExitCode.software.code;
    }
    logger.write('Checked for updates.', progress: ProgressState.completed);

    final isUpToDate = currentVersion == latestVersion;
    if (isUpToDate) {
      logger.write(wrapBox('Jaspr is already at the latest version.', borderColor: green));
      final hasSkills = await checkJasprSkillsInstalled();
      if (!hasSkills) {
        logger.write('\n');
        printSkillsPromoBanner(logger);
      }
      return 0;
    }

    final wasAot = Platform.resolvedExecutable.endsWith('/jaspr');
    var isAot = wasAot;

    late final ProcessResult result;
    try {
      // If the cli is installed as aot snapshot, we need to use 'dart install' instead of 'dart pub global activate'.
      if (wasAot) {
        logger.write('Updating jaspr_cli to $latestVersion...', progress: ProgressState.running);
        result = await ProcessRunner.instance.run(dartExecutable, ['install', packageName, latestVersion]);
      } else {
        final useAot =
            stdout.hasTerminal &&
            await logger.confirm(
              'You are currently using Jaspr CLI as a globally activated package. '
              'Do you want to switch to the pre-compiled AOT version of the Jaspr CLI (using "dart install") '
              'for faster startup times?',
              defaultValue: true,
            );

        if (useAot) {
          isAot = true;
          logger.write('Deactivating global pub package...', progress: ProgressState.running);
          await ProcessRunner.instance.run(dartExecutable, ['pub', 'global', 'deactivate', packageName]);
          logger.write('Deactivated global pub package.', progress: ProgressState.completed);

          logger.write('Installing jaspr_cli $latestVersion via "dart install"...', progress: ProgressState.running);
          result = await ProcessRunner.instance.run(dartExecutable, ['install', packageName, latestVersion]);
        } else {
          logger.write('Updating jaspr_cli to $latestVersion...', progress: ProgressState.running);
          result = await updater.update(packageName: packageName, versionConstraint: latestVersion);
        }
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
        'Jaspr CLI is now at ${cyan.wrap(latestVersion)}.',
        borderColor: green,
      ),
    );

    final ranPostUpdate = await _runPostUpdate(fromVersion: currentVersion, isAot: isAot);
    if (!ranPostUpdate) {
      logger.write('\n');
      logger.write(
        wrapBox(
          'There might be automatic code migrations available for your project.\n'
          'Run ${styleItalic.wrap(cyan.wrap('jaspr migrate'))} to check for available migrations.',
          borderColor: cyan,
        ),
      );

      final hasSkills = await checkJasprSkillsInstalled();
      if (!hasSkills) {
        logger.write('\n');
        printSkillsPromoBanner(logger);
      }
    }

    return 0;
  }

  Future<bool> _runPostUpdate({required String fromVersion, required bool isAot}) async {
    try {
      final Process process;
      if (isAot) {
        final executable = Platform.resolvedExecutable.endsWith('/jaspr') ? Platform.resolvedExecutable : 'jaspr';
        process = await ProcessRunner.instance.start(
          executable,
          ['post-update', '--from', fromVersion],
          mode: ProcessStartMode.inheritStdio,
        );
      } else {
        process = await ProcessRunner.instance.start(
          dartExecutable,
          ['pub', 'global', 'run', 'jaspr_cli:jaspr', 'post-update', '--from', fromVersion],
          mode: ProcessStartMode.inheritStdio,
        );
      }
      return await process.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
