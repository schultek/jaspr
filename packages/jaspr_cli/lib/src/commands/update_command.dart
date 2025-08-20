import 'dart:io';

import 'package:mason/mason.dart' show ExitCode;
import 'package:pub_updater/pub_updater.dart';

import '../command_runner.dart';
import '../logging.dart';
import '../version.dart';
import 'base_command.dart';
import 'migrate_command.dart';

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
  Future<int> runCommand() async {
    logger.write('Checking for updates', progress: ProgressState.running);
    late final String latestVersion;
    try {
      latestVersion = await _updater.getLatestVersion(packageName);
    } catch (error) {
      logger.complete(false);
      logger.write('$error', level: Level.error);
      return ExitCode.software.code;
    }
    logger.write('Checked for updates', progress: ProgressState.completed);

    final isUpToDate = jasprCliVersion == latestVersion;
    if (isUpToDate) {
      logger.write('Jaspr is already at the latest version.');
      return 0;
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
      return ExitCode.software.code;
    }

    if (result.exitCode != ExitCode.success.code) {
      logger.write('Unable to update to $latestVersion',
          progress: ProgressState.completed);
      logger.write('${result.stderr}', level: Level.error);
      return ExitCode.software.code;
    }

    logger.write('Updated to $latestVersion',
        progress: ProgressState.completed);

    var migrations = MigrateCommand.allMigrations.where((m) {
      return latestVersion.compareTo(m.minimumJasprVersion) >= 0;
    }).toList();

    if (migrations.isNotEmpty) {
      final results = migrations.computeResults(['lib'], false, (file, e, st) {
        logger.write('Error processing ${file.path}: $e\n$st',
            level: Level.error);
      });

      if (results.isNotEmpty) {
        stdout.write('\nYour project has automatic migrations available for updating the code to the newest Jaspr syntax:\n\n'
          '${migrations.map((m) => '  ${m.name} · ${m.description}\n${m.hint}').join('\n')}\n\n');

        stdout.write('Make sure to update the dependency constraint of jaspr in your pubspec.yaml file to include $latestVersion.\n');
        stdout.write(
            'Then run \'jaspr migrate --dry-run\' to preview all migration changes.');
      }
    }

    return 0;
  }
}
