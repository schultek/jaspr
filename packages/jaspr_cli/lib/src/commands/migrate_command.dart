import 'dart:io';

import 'package:io/ansi.dart';

import '../logging.dart';
import '../migrations/build_method_migration.dart';
import '../migrations/migration_models.dart';
import 'base_command.dart';

class MigrateCommand extends BaseCommand {
  MigrateCommand({super.logger}) {
    argParser.addFlag(
      'dry-run',
      help: 'Preview the proposed changes but make no changes.',
      defaultsTo: false,
    );
    argParser.addFlag(
      'apply',
      help: 'Apply the proposed changes.',
      defaultsTo: false,
    );
  }

  @override
  String get description => 'Migrate Jaspr code to the latest version.';

  @override
  String get name => 'migrate';

  @override
  String get category => 'Tooling';

  @override
  bool get preferBuilderDependency => false;

  late final bool dryRun = argResults!['dry-run'] as bool;
  late final bool apply = argResults!['apply'] as bool;

  static List<Migration> get allMigrations => [
        BuildMethodMigration(),
      ];

  @override
  Future<int> runCommand() async {
    final directories = ['lib', 'web', 'test'];

    final currentJasprVersion = switch (config.pubspecLock) {
      {'packages': {'jaspr': {'version': String version}}} => version,
      _ => '',
    };

    var migrations = allMigrations.where((m) {
      return currentJasprVersion.compareTo(m.minimumJasprVersion) >= 0;
    }).toList();

    if (migrations.isEmpty) {
      logger.write('No migrations available for you current Jaspr version ($currentJasprVersion).');
      return 0;
    }

    if (!apply && !dryRun) {
      stdout.write('Available migrations:\n\n'
          '${migrations.map((m) => '  ${m.name} · ${m.description}\n${m.hint}').join('\n')}\n\n');

      stdout.write('Run with --dry-run to preview all migration changes or --apply to apply them.');

      return 1;
    }

    final results = migrations.computeResults(directories, apply, (file, e, st) {
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
      logger.write('No migrations found.', level: Level.info);
      return 0;
    }

    logger.write(
      styleBold
          .wrap('Processed ${results.length} files, applied $successCount migrations, found $warningCount warnings.')!,
      level: Level.info,
    );

    return 0;
  }
}
