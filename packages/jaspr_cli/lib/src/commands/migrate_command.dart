import 'dart:io';

import 'package:io/ansi.dart';

import '../logging.dart';
import '../migrations/build_method_migration.dart';
import '../migrations/component_factory_migration.dart';
import '../migrations/migration_models.dart';
import 'base_command.dart';

class MigrateCommand extends BaseCommand {
  MigrateCommand({super.logger}) {
    argParser.addFlag('dry-run', help: 'Preview the proposed changes but make no changes.', defaultsTo: false);
    argParser.addFlag('apply', help: 'Apply the proposed changes.', defaultsTo: false);
    argParser.addOption('assume-version', help: 'Set the projects Jaspr version and skip auto-detection.', hide: true);
    argParser.addMultiOption(
      'include-dir',
      help: 'Include the specified directory for migration (can be used multiple times).',
      hide: true,
      defaultsTo: ['lib', 'web', 'test'],
    );
  }

  @override
  String get description => 'Migrate Jaspr code to the latest version.';

  @override
  String get name => 'migrate';

  @override
  String get category => 'Tooling';

  late final bool dryRun = argResults!['dry-run'] as bool;
  late final bool apply = argResults!['apply'] as bool;
  late final String? assumeVersion = argResults!['assume-version'] as String?;
  late final List<String> includeDirs = List<String>.from(argResults!['include-dir'] as List);

  static List<Migration> get allMigrations => [BuildMethodMigration(), ComponentFactoryMigration()];

  @override
  Future<int> runCommand() async {
    if (assumeVersion == null) {
      ensureInProject(requireJasprMode: false, preferBuilderDependency: false);
    }

    final currentJasprVersion =
        assumeVersion ??
        switch (project.pubspecLock) {
          {'packages': {'jaspr': {'version': String version}}} => version,
          _ => '',
        };

    if (currentJasprVersion.isEmpty) {
      logger.write(
        'Could not determine current Jaspr version from pubspec.lock. Run with --assume-version=x.y.z to set a version manually.',
        level: Level.critical,
      );
      return 1;
    }

    var migrations = allMigrations.where((m) {
      return currentJasprVersion.compareTo(m.minimumJasprVersion) >= 0;
    }).toList();

    if (migrations.isEmpty) {
      logger.write('No migrations available for you current Jaspr version ($currentJasprVersion).');
      return 0;
    }

    if (!apply && !dryRun) {
      stdout.write(
        'Available migrations:\n\n'
        '${migrations.map((m) => '  ${m.name} · ${m.description}\n${m.hint}').join('\n\n')}\n\n',
      );

      stdout.write('Run with --dry-run to preview all migration changes or --apply to apply them.');

      return 1;
    }

    final results = migrations.computeResults(includeDirs, apply, (file, e, st) {
      logger.write('Error processing ${file.path}: $e\n$st', level: Level.error);
    });

    final check = green.wrap(styleBold.wrap('✓'));
    final warn = yellow.wrap(styleBold.wrap('⚠'));

    for (final result in results) {
      if (result.reporter.migrations.isEmpty) {
        continue;
      }
      StringBuffer output = StringBuffer();
      output.write('${result.path}\n');

      for (final migration in result.reporter.migrations) {
        output.write('  $check ${migration.migration.name} · ${migration.description}\n');
      }

      stdout.write('$output\n');
    }

    for (final result in results) {
      if (result.reporter.warnings.isEmpty) {
        continue;
      }
      StringBuffer output = StringBuffer();
      output.write('${result.path}\n');

      for (final warning in result.reporter.warnings) {
        output.write('  $warn ${warning.migration.name} · ${warning.message}\n');
      }

      stdout.write('$output\n');
    }

    final successCount = results.fold<int>(0, (sum, result) => sum + result.reporter.migrations.length);

    final warningCount = results.fold<int>(0, (sum, result) => sum + result.reporter.warnings.length);

    if (successCount == 0 && warningCount == 0) {
      logger.write('No migration changes found. All done.', level: Level.info);
      return 0;
    }

    logger.write(
      styleBold.wrap('Applied $successCount changes and found $warningCount warnings across ${results.length} files.')!,
      level: Level.info,
    );

    return 0;
  }
}
