import 'dart:io';

import 'package:file/local.dart';
import 'package:mason/mason.dart' show cyan, styleBold, styleItalic, yellow;

import '../helpers/skills_helper.dart';
import '../logging.dart';
import '../migrations/migration_models.dart';
import '../utils.dart';
import '../version.dart';
import 'base_command.dart';
import 'migrate_command.dart';

class PostUpdateCommand extends BaseCommand {
  PostUpdateCommand({super.logger}) {
    argParser.addOption('from', help: 'The previous version of jaspr_cli.');
  }

  @override
  final String description = 'Internal command run after updating the Jaspr CLI.';

  @override
  final String name = 'post-update';

  @override
  final bool hidden = true;

  @override
  Future<int> runCommand() async {
    await _checkAndApplyMigrations();

    final hasSkills = await checkJasprSkillsInstalled();
    if (!hasSkills) {
      logger.write('\n');
      printSkillsPromoBanner(logger);
    }

    return 0;
  }

  Future<void> _checkAndApplyMigrations() async {
    final fromVersion = argResults?.option('from');
    final currentJasprVersion = switch (project.pubspecLock) {
      {'packages': {'jaspr': {'version': final String version}}} => version,
      _ => fromVersion,
    };

    if (currentJasprVersion == null || currentJasprVersion.isEmpty) {
      return;
    }

    final targetJasprVersion = jasprCliVersion;
    if (currentJasprVersion.compareTo(targetJasprVersion) >= 0) {
      return;
    }

    if (project.pubspecYaml != null) {
      final shouldUpdate =
          stdout.hasTerminal &&
          await logger.confirm(
            'Update Jaspr dependencies in pubspec.yaml to $targetJasprVersion?',
            defaultValue: true,
          );

      if (shouldUpdate) {
        MigrateCommand.updatePubspecDependencies(project, logger, targetJasprVersion);
      }
    }

    final migrations = MigrateCommand.allMigrations.where((m) {
      return currentJasprVersion.compareTo(m.minimumJasprVersion) < 0 &&
          targetJasprVersion.compareTo(m.minimumJasprVersion) >= 0;
    }).toList();

    final List<MigrationResult> results = migrations.isNotEmpty
        ? migrations.computeResults(
            ['lib', 'web', 'test'],
            false,
            project,
            const LocalFileSystem(),
            (file, e, st) {},
            features: ['dot-shorthands'],
          )
        : [];

    final activeMigrations = results
        .expand((r) => [...r.migrations.map((m) => m.migration), ...r.warnings.map((w) => w.migration)])
        .toSet()
        .toList();

    if (activeMigrations.isNotEmpty) {
      logger.write('\n');
      logger.write(
        wrapBox(
          '${styleBold.wrap('Automatic code migrations available for your project:')}\n\n'
          '${activeMigrations.map((m) => '${styleBold.wrap(m.name)} · ${m.description}\n${m.hint}').join('\n\n')}',
          borderColor: yellow,
        ),
      );

      final shouldApply =
          stdout.hasTerminal &&
          await logger.confirm(
            'Apply available migrations for your project?',
            defaultValue: true,
          );

      if (shouldApply) {
        logger.write('Applying migrations...', level: Level.info);
        final applyResults = activeMigrations.computeResults(
          ['lib', 'web', 'test'],
          true,
          project,
          const LocalFileSystem(),
          (file, e, st) {
            logger.write('Error processing ${file.path}: $e\n$st', level: Level.error);
          },
          features: ['dot-shorthands'],
        );
        MigrateCommand.printMigrationResults(logger, applyResults);
      } else {
        logger.write(
          '\nRun ${styleItalic.wrap(cyan.wrap('jaspr migrate'))} to check and apply available migrations later.\n',
        );
      }
    }
  }
}
