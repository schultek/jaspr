import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'logging.dart';

enum JasprMode { static, server, client }

class Project {
  Project(this.logger);

  final Logger logger;

  YamlMap? get pubspecYaml => _pubspecYaml;
  YamlMap get requirePubspecYaml {
    final pubspecYaml = _pubspecYaml;
    if (pubspecYaml == null) {
      logger.write('Could not find pubspec.yaml file. Make sure to run jaspr in your root project directory.',
          tag: Tag.cli, level: Level.critical);
      exit(1);
    }
    return pubspecYaml;
  }

  late final YamlMap? _pubspecYaml = () {
    var pubspecPath = 'pubspec.yaml';
    var pubspecFile = File(pubspecPath).absolute;
    if (!pubspecFile.existsSync()) {
      return null;
    }

    try {
      return loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    } catch (e) {
      logger.write('Could not parse pubspec.yaml file: $e', tag: Tag.cli, level: Level.critical);
      exit(1);
    }
  }();

  void get requireJasprDependency {
    if (requirePubspecYaml case {'dependencies': {'jaspr': _}}) {
      // ok
    } else {
      logger.write('Missing dependency on jaspr in pubspec.yaml file. Make sure to add jaspr to your dependencies.',
          tag: Tag.cli, level: Level.critical);
      exit(1);
    }
  }

  void get preferJasprBuilderDependency {
    if (requirePubspecYaml case {'dev_dependencies': {'jaspr_builder': _}}) {
      // ok
    } else {
      var log = logger.logger;
      if (log == null) {
        logger.write(
            'Missing dependency on jaspr_builder in pubspec.yaml file. Make sure to add jaspr_builder to your dev_dependencies.',
            tag: Tag.cli,
            level: Level.warning);
      } else {
        var result = log.confirm(
            'Missing dependency on jaspr_builder package. Do you want to add jaspr_builder to your dev_dependencies now?',
            defaultValue: true);
        if (result) {
          var result = Process.runSync('dart', ['pub', 'add', '--dev', 'jaspr_builder']);
          if (result.exitCode != 0) {
            log.err(result.stderr);
            logger.write('Failed to run "dart pub add --dev jaspr_builder". There is probably more output above.',
                tag: Tag.cli, level: Level.critical);
            exit(1);
          }

          log.success('Successfully added jaspr_builder to your dev_dependencies.');
        }
      }
    }
  }

  bool get usesJasprWebCompilers {
    return switch (requirePubspecYaml) {
      {'dev_dependencies': {'jaspr_web_compilers': _}} => true,
      _ => false,
    };
  }

  bool get usesFlutter {
    return switch (requirePubspecYaml) {
      {'dependencies': {'flutter': _}} => true,
      _ => false,
    };
  }

  YamlMap get _requireJasprOptions {
    var configYaml = requirePubspecYaml['jaspr'];
    if (configYaml == null) {
      logger.write('Missing \'jaspr\' options in pubspec.yaml.', tag: Tag.cli, level: Level.critical);
      exit(1);
    }
    if (configYaml is! YamlMap) {
      logger.write('\'jaspr\' options must be a yaml map in pubspec.yaml.', tag: Tag.cli, level: Level.critical);
      exit(1);
    }
    return configYaml;
  }

  JasprMode? get modeOrNull {
    var configYaml = pubspecYaml?['jaspr'];
    if (configYaml is! YamlMap) {
      return null;
    }
    var modeYaml = configYaml['mode'];
    if (modeYaml is! String) {
      return null;
    }
    var modeOrNull = JasprMode.values.where((v) => v.name == modeYaml).firstOrNull;
    return modeOrNull;
  }

  JasprMode get requireMode {
    var configYaml = _requireJasprOptions;

    var modeYaml = configYaml['mode'];
    if (modeYaml == null) {
      logger.write('\'jaspr.mode\' option is required but missing in pubspec.yaml.',
          tag: Tag.cli, level: Level.critical);
      exit(1);
    }
    var modeOrNull = JasprMode.values.where((v) => v.name == modeYaml).firstOrNull;
    if (modeOrNull == null) {
      logger.write('\'jaspr.mode\' must be one of ${JasprMode.values.map((v) => v.name).join(', ')} in pubspec.yaml.',
          tag: Tag.cli, level: Level.critical);
      exit(1);
    }
    return modeOrNull;
  }

  String? get devCommand {
    var configYaml = _requireJasprOptions;

    var devCommandYaml = configYaml['dev-command'];
    if (devCommandYaml != null) {
      if (devCommandYaml is! String) {
        logger.write('\'jaspr.dev-command\' must be a string in pubspec.yaml.', tag: Tag.cli, level: Level.critical);
        exit(1);
      }

      return devCommandYaml;
    }
    return null;
  }

  late final YamlMap? pubspecLock = () {
    var pubspecLockPath = 'pubspec.lock';
    var pubspecLockFile = File(pubspecLockPath).absolute;

    if (!pubspecLockFile.existsSync() && pubspecYaml?['resolution'] == 'workspace') {
      var n = 1;
      while (n < 5) {
        var parent = path.dirname(path.dirname(pubspecLockFile.path));
        if (parent == pubspecLockFile.path) {
          break;
        }
        pubspecLockFile = File(path.join(parent, 'pubspec.lock'));
        if (pubspecLockFile.existsSync()) {
          break;
        }
        n++;
      }
    }

    if (pubspecLockFile.existsSync()) {
      try {
        return loadYaml(pubspecLockFile.readAsStringSync()) as YamlMap;
      } catch (e) {
        logger.write('Could not parse pubspec.lock file: $e', tag: Tag.cli, level: Level.critical);
        exit(1);
      }
    }
    return null;
  }();
}
