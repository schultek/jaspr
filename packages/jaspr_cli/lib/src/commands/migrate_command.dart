import 'dart:io';

import 'package:analyzer/source/line_info.dart';
import 'package:file/local.dart';
import 'package:io/ansi.dart';
import 'package:yaml/yaml.dart';

import '../command_runner.dart';
import '../logging.dart';
import '../migrations/build_method_migration.dart';
import '../migrations/client_import_migration.dart';
import '../migrations/component_factory_migration.dart';
import '../migrations/dom_import_migration.dart';
import '../migrations/entrypoint_migration.dart';
import '../migrations/html_helper_migration.dart';
import '../migrations/migration_models.dart';
import 'base_command.dart';

class MigrateCommand extends BaseCommand {
  MigrateCommand({super.logger}) {
    argParser.addFlag('dry-run', help: 'Preview the proposed changes but make no changes.', defaultsTo: false);
    argParser.addFlag('apply', help: 'Apply the proposed changes.', defaultsTo: false);
    argParser.addOption(
      'current-version',
      help: 'Set the currently used Jaspr version. Defaults to the version used in your pubspec.lock file.',
    );
    argParser.addOption(
      'target-version',
      help: 'Set the target Jaspr version for migration. Defaults to the latest version on pub.dev.',
    );
    argParser.addMultiOption(
      'include-dir',
      help: 'Include the specified directory for migration (can be used multiple times).',
      defaultsTo: ['lib', 'web', 'test'],
    );
    argParser.addMultiOption(
      'feature',
      help: 'Specify which language features to use during migration (can be used multiple times).',
      allowed: ['dot-shorthands'],
      allowedHelp: {'dot-shorthands': 'Use dot shorthands where possible.'},
    );
  }

  @override
  String get description => 'Migrate Jaspr code to the latest version.';

  @override
  String get name => 'migrate';

  @override
  String get category => 'Tooling';

  late final bool dryRun = argResults!.flag('dry-run');
  late final bool apply = argResults!.flag('apply');
  late final String? currentVersion = argResults!.option('current-version');
  late final String? targetVersion = argResults!.option('target-version');
  late final List<String> includeDirs = argResults!.multiOption('include-dir');
  late final List<String> features = argResults!.multiOption('feature');

  static List<Migration> get allMigrations => [
    BuildMethodMigration(),
    ComponentFactoryMigration(),
    DomImportMigration(),
    HtmlHelperMigration(),
    ClientImportMigration(),
    EntrypointMigration(),
  ];

  @override
  Future<int> runCommand() async {
    if (dryRun && apply) {
      usageException('Cannot use both --dry-run and --apply at the same time.');
    }

    if (currentVersion == null) {
      ensureInProject(
        requireJasprMode: false,
        preferBuilderDependency: false,
        checkJasprDependencyVersion: false,
      );
    }

    final currentJasprVersion =
        currentVersion ??
        switch (project.pubspecLock) {
          {'packages': {'jaspr': {'version': final String version}}} => version,
          _ => '',
        };

    if (currentJasprVersion.isEmpty) {
      usageException(
        'Could not determine current Jaspr version from pubspec.lock. Run with --current-version=x.y.z to set a version manually.',
      );
    }

    var targetJasprVersion = targetVersion;
    if (targetJasprVersion == null) {
      try {
        targetJasprVersion = await updater.getLatestVersion(packageName);
      } catch (error) {
        logger.write('$error', level: Level.error);
        logger.write(
          'Failed to fetch latest Jaspr version. Run with --target-version=x.y.z to set a version manually.',
          level: Level.critical,
        );
        return 1;
      }
    }

    logger.write('Checking for migrations from $currentJasprVersion to $targetJasprVersion...', level: Level.info);

    final migrations = allMigrations.where((m) {
      return currentJasprVersion.compareTo(m.minimumJasprVersion) < 0 &&
          targetJasprVersion!.compareTo(m.minimumJasprVersion) >= 0;
    }).toList();

    if (migrations.isEmpty) {
      logger.write(
        'No migrations available. Please update your Jaspr version in pubspec.yaml manually.',
        level: Level.info,
      );
      return 0;
    }

    if (!apply && !dryRun) {
      stdout.write(
        'Available migrations:\n\n'
        '${migrations.map((m) => '  ${m.name} · ${m.description}\n${m.hint}').join('\n\n')}\n\n',
      );

      stdout.write(
        'Run with --dry-run to preview all migration changes or --apply to apply them and update pubspec.yaml.',
      );

      return 1;
    }

    if (apply) {
      final pubspecMap = project.pubspecYaml;

      if (pubspecMap != null) {
        logger.write('Updating Jaspr dependencies to $targetJasprVersion...', level: Level.info);
        try {
          final pubspecContent = project.pubspecFile.readAsStringSync();
          final builder = EditBuilder(LineInfo.fromContent(pubspecContent));

          if (pubspecMap.nodes['dependencies'] case final YamlMap dependencies) {
            if (dependencies.nodes['jaspr'] case final YamlScalar jasprNode when jasprNode.value != null) {
              builder.replace(jasprNode.span.start.offset, jasprNode.span.length, '^$targetJasprVersion');
            }
          }
          if (pubspecMap.nodes['dev_dependencies'] case final YamlMap devDependencies) {
            if (devDependencies.nodes['jaspr_builder'] case final YamlScalar builderNode
                when builderNode.value != null) {
              builder.replace(builderNode.span.start.offset, builderNode.span.length, '^$targetJasprVersion');
            }
            if (devDependencies.nodes['jaspr_test'] case final YamlScalar testNode when testNode.value != null) {
              builder.replace(testNode.span.start.offset, testNode.span.length, '^$targetJasprVersion');
            }
          }

          project.pubspecFile.writeAsStringSync(builder.apply(pubspecContent));
        } catch (e) {
          logger.write('Failed to update pubspec.yaml: $e', level: Level.error);
        }
      }

      logger.write('Applying migrations...', level: Level.info);
    } else {
      logger.write('Previewing migrations (dry run)...', level: Level.info);
    }

    final results = migrations.computeResults(includeDirs, apply, project, LocalFileSystem(), (file, e, st) {
      logger.write('Error processing ${file.path}: $e\n$st', level: Level.error);
    }, features: features);

    final check = green.wrap(styleBold.wrap('✓'));
    final warn = yellow.wrap(styleBold.wrap('⚠'));

    for (final result in results) {
      if (result.migrations.isEmpty) {
        continue;
      }
      final StringBuffer output = StringBuffer();
      output.write('${result.path}\n');

      for (final migration in result.migrations) {
        output.write('  $check ${migration.migration.name} · ${migration.description}\n');
      }

      stdout.write('$output\n');
    }

    for (final result in results) {
      if (result.warnings.isEmpty) {
        continue;
      }
      final StringBuffer output = StringBuffer();
      output.write('${result.path}\n');

      for (final warning in result.warnings) {
        output.write('  $warn ${warning.migration.name} · ${warning.message}\n');
      }

      stdout.write('$output\n');
    }

    final successCount = results.fold<int>(0, (sum, result) => sum + result.migrations.length);

    final warningCount = results.fold<int>(0, (sum, result) => sum + result.warnings.length);

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
