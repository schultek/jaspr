import 'dart:io';

import 'package:mason/mason.dart' hide Level;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../commands/base_command.dart';
import '../logging.dart';
import '../process_runner.dart';
import '../project.dart';

/// helpers used to locate the project root, read its pubspec.yaml, and install missing dependencies.
mixin PubspecHelper on BaseCommand {
  /// Walk up from the start directory until we find the project root (i.e., when we find a pubspec.yaml file)
  /// this means that in a monorepo (e.g., jaspr repo), this walk will stop at the current package's root
  Directory? findProjectRoot(Directory start) {
    var dir = start.absolute;
    while (true) {
      // stop as soon as you find a pubspec.yaml file
      if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
        return dir;
      }

      // otherwise try again in the parent directory
      final parent = dir.parent;
      if (parent.path == dir.path) {
        // reached the filesystem root without finding a pubspec.yaml
        return null;
      }
      dir = parent;
    }
  }

  /// read the pubspec yaml file from a given directory, returns null if it doesn't exist
  /// Note that this doesn't use project.pubspecYaml or pubspecFile because this command could conceivably be used in another dir
  /// than the root, so it makes sense to walk up to the root of the project and use the file we find there.
  YamlMap? readPubspec(Directory root) {
    final file = File(p.join(root.path, 'pubspec.yaml'));
    if (!file.existsSync()) {
      return null;
    }

    try {
      final yaml = loadYaml(file.readAsStringSync());
      return yaml is YamlMap ? yaml : null;
    } catch (_) {
      return null;
    }
  }

  /// check if the pubspec file contains the packageName as a dep
  bool hasDep(YamlMap? pubspecMap, String packageName, {bool isDevDependency = false}) {
    final deps = pubspecMap?.nodes[isDevDependency ? 'dev_dependencies' : 'dependencies'];
    return deps is YamlMap && deps.containsKey(packageName);
  }

  /// for a given list of packages, check if they are already installed, if not then prompt the user to install them
  void conditionallyInstallDeps(Directory projectRoot, List<String> packages, {bool isDevDependency = false}) {
    // check if the pubspec.yaml of the target project already contains the deps, if so return early

    final pubspecMap = readPubspec(projectRoot);
    if (pubspecMap == null) {
      logger.write(
        'Failed to find pubspec.yaml file in dir ${blue.wrap(projectRoot.path)}',
        tag: Tag.cli,
        level: Level.error,
      );
      return;
    }

    final String depString = isDevDependency ? 'dev_dependencies' : 'dependencies';
    final String pubAddArg = isDevDependency ? '--dev' : '';

    for (String packageName in packages) {
      // exit quietly if the package is already installed
      if (pubspecMap.containsKey(depString)) {
        final deps = pubspecMap.nodes[depString];
        if (deps is YamlMap && deps.containsKey(packageName)) {
          continue;
        }
      }

      final log = logger.logger;
      if (log == null) {
        // the confirm method on mason's logger require a terminal to be attached,
        // if it isn't the case we tell the user to install the package themselves
        logger.write(
          "Cannot automatically add $packageName to pubspec.yaml, run ${yellow.wrap("dart pub add $packageName $pubAddArg")}",
          tag: Tag.cli,
          level: Level.warning,
        );
        continue;
      }

      final result = logger.logger!.confirm(
        'The ${cyan.wrap(packageName)} package is required. Do you want to add $packageName to your $depString?',
        defaultValue: true,
      );

      if (!result) {
        logger.write(
          'Skipped adding $packageName. Run ${yellow.wrap("dart pub add $packageName $pubAddArg")}',
          tag: Tag.cli,
          level: Level.warning,
        );
        continue;
      }

      // if we are adding either the flutter of flutter_test dependency,
      // we need to specify that we want to use flutter from the currently installed sdk
      // TODO: maybe find a better way than this
      if (packageName == 'flutter' || packageName == 'flutter_test') {
        packageName = '$packageName@{sdk: flutter}';
      }

      final pubCommand = ProcessRunner.instance.runSync(
        dartExecutable,
        ['pub', 'add', '${isDevDependency ? "dev:" : ""}$packageName'],
        workingDirectory: projectRoot.path,
      );
      if (pubCommand.exitCode != 0) {
        log.err(pubCommand.stderr as String?);
        logger.write(
          'Failed to run ${yellow.wrap("dart pub add $packageName $pubAddArg")}. There is probably more output above.',
          tag: Tag.cli,
          level: Level.error,
        );
        continue;
      }

      logger.write(
        'Successfully added ${green.wrap(packageName)} to your $depString.',
        tag: Tag.cli,
        level: Level.info,
      );
    }

    return;
  }
}
