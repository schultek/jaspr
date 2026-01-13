import 'dart:io' as io;
import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'logging.dart';
import 'process_runner.dart';
import 'version.dart';

enum JasprMode { static, server, client }

enum FlutterMode { embedded, plugins, none }

extension JasprModeExtension on JasprMode {
  bool get isServerOrStatic => this == JasprMode.server || this == JasprMode.static;
}

class Project {
  Project(this.logger, {FileSystem? fs, Never Function(int)? exitFn})
    : _fs = fs ?? const LocalFileSystem(),
      _exitFn = exitFn ?? io.exit;

  final Logger logger;
  final FileSystem _fs;
  final Never Function(int) _exitFn;

  YamlMap? get pubspecYaml => _pubspecYaml;
  YamlMap get requirePubspecYaml {
    final pubspecYaml = _pubspecYaml;
    if (pubspecYaml == null) {
      logger.write(
        'Could not find pubspec.yaml file. Make sure to run jaspr in your root project directory.',
        tag: Tag.cli,
        level: Level.critical,
      );
      _exitFn(1);
    }
    return pubspecYaml;
  }

  late final File pubspecFile = _fs.file('pubspec.yaml').absolute;

  late final YamlMap? _pubspecYaml = () {
    if (!pubspecFile.existsSync()) {
      return null;
    }

    try {
      return loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    } catch (e) {
      logger.write('Could not parse pubspec.yaml file: $e', tag: Tag.cli, level: Level.critical);
      _exitFn(1);
    }
  }();

  void get requireJasprDependency {
    if (requirePubspecYaml case {'dependencies': {'jaspr': _}}) {
      // ok
    } else {
      logger.write(
        'Missing dependency on jaspr in pubspec.yaml file. Make sure to add jaspr to your dependencies.',
        tag: Tag.cli,
        level: Level.critical,
      );
      _exitFn(1);
    }
  }

  void checkJasprDependencyVersion() {
    final pubspecYaml = requirePubspecYaml;
    if (pubspecYaml case {'dependencies': {'jaspr': final String version}}) {
      final usedVersion = VersionConstraint.parse(version);
      final currentVersion = Version.parse(jasprCoreVersion);
      final minVersion = Version(
        currentVersion.major,
        currentVersion.minor,
        0,
        pre: currentVersion.isPreRelease ? currentVersion.preRelease.map((s) => s is int ? 0 : s).join('.') : null,
      );
      final requiredVersion = VersionConstraint.compatibleWith(minVersion);
      if (!requiredVersion.allowsAll(usedVersion)) {
        logger.write(
          'Incompatible jaspr dependency with version $version found in pubspec.yaml. Please use a minimum version constraint of $minVersion for all core packages.',
          tag: Tag.cli,
          level: Level.critical,
        );
        _exitFn(1);
      }
    }
  }

  void get preferJasprBuilderDependency {
    if (requirePubspecYaml case {'dev_dependencies': {'jaspr_builder': _}}) {
      // ok
    } else {
      final log = logger.logger;
      if (log == null || !stdout.hasTerminal) {
        logger.write(
          'Missing dependency on jaspr_builder in pubspec.yaml file. Make sure to add jaspr_builder to your dev_dependencies.',
          tag: Tag.cli,
          level: Level.warning,
        );
      } else {
        final result = log.confirm(
          'Missing dependency on jaspr_builder package. Do you want to add jaspr_builder to your dev_dependencies now?',
          defaultValue: true,
        );
        if (result) {
          final result = ProcessRunner.instance.runSync('dart', ['pub', 'add', '--dev', 'jaspr_builder']);
          if (result.exitCode != 0) {
            log.err(result.stderr as String?);
            logger.write(
              'Failed to run "dart pub add --dev jaspr_builder". There is probably more output above.',
              tag: Tag.cli,
              level: Level.critical,
            );
            _exitFn(1);
          }

          log.success('Successfully added jaspr_builder to your dev_dependencies.');
        }
      }
    }
  }

  YamlMap get _requireJasprOptions {
    final configYaml = requirePubspecYaml['jaspr'];
    if (configYaml == null) {
      logger.write('Missing \'jaspr\' options in pubspec.yaml.', tag: Tag.cli, level: Level.critical);
      _exitFn(1);
    }
    if (configYaml is! YamlMap) {
      logger.write('\'jaspr\' options must be a yaml map in pubspec.yaml.', tag: Tag.cli, level: Level.critical);
      _exitFn(1);
    }
    return configYaml;
  }

  JasprMode? get modeOrNull {
    final configYaml = pubspecYaml?['jaspr'];
    if (configYaml is! YamlMap) {
      return null;
    }
    final modeYaml = configYaml['mode'];
    if (modeYaml is! String) {
      return null;
    }
    final modeOrNull = JasprMode.values.where((v) => v.name == modeYaml).firstOrNull;
    return modeOrNull;
  }

  JasprMode get requireMode {
    final configYaml = _requireJasprOptions;

    final modeYaml = configYaml['mode'];
    if (modeYaml == null) {
      logger.write(
        '\'jaspr.mode\' option in pubspec.yaml is required but missing.',
        tag: Tag.cli,
        level: Level.critical,
      );
      _exitFn(1);
    }
    final modeOrNull = JasprMode.values.where((v) => v.name == modeYaml).firstOrNull;
    if (modeOrNull == null) {
      logger.write(
        '\'jaspr.mode\' in pubspec.yaml must be one of ${JasprMode.values.map((v) => v.name).join(', ')}.',
        tag: Tag.cli,
        level: Level.critical,
      );
      _exitFn(1);
    }
    return modeOrNull;
  }

  FlutterMode get flutterMode {
    final configYaml = pubspecYaml?['jaspr'];
    if (configYaml is! YamlMap) {
      return FlutterMode.none;
    }
    final modeYaml = configYaml['flutter'];
    if (modeYaml is! String) {
      return FlutterMode.none;
    }
    final modeOrNull = FlutterMode.values.where((v) => v.name == modeYaml).firstOrNull;
    if (modeOrNull == null) {
      logger.write(
        '\'jaspr.flutter\' in pubspec.yaml must be one of ${FlutterMode.values.map((v) => v.name).join(', ')}.',
        tag: Tag.cli,
        level: Level.critical,
      );
      _exitFn(1);
    }
    return modeOrNull;
  }

  String? get port {
    final configYaml = _requireJasprOptions;

    final portYaml = configYaml['port'];
    if (portYaml != null) {
      if (portYaml is int) {
        return portYaml.toString();
      } else {
        logger.write(
          '\'jaspr.port\' in pubspec.yaml must be an integer.',
          tag: Tag.cli,
          level: Level.critical,
        );
        _exitFn(1);
      }
    }
    return null;
  }

  late final YamlMap? pubspecLock = () {
    final pubspecLockPath = 'pubspec.lock';
    var pubspecLockFile = _fs.file(pubspecLockPath).absolute;

    if (!pubspecLockFile.existsSync() && pubspecYaml?['resolution'] == 'workspace') {
      var n = 1;
      while (n < 5) {
        final parent = path.dirname(path.dirname(pubspecLockFile.path));
        if (parent == pubspecLockFile.path) {
          break;
        }
        pubspecLockFile = _fs.file(path.join(parent, 'pubspec.lock'));
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
        _exitFn(1);
      }
    }
    return null;
  }();

  void checkWasmSupport() {
    final devDependencies = pubspecYaml?['dev_dependencies'] as Map<Object?, Object?>?;
    final version = switch (devDependencies?['build_web_compilers']) {
      final String v => VersionConstraint.parse(v),
      _ => null,
    };
    final minVersion = VersionConstraint.compatibleWith(Version(4, 1, 0));
    if (version == null || !minVersion.allowsAll(version)) {
      logger.write(
        'Using "--experimental-wasm" requires build_web_compilers 4.1.0 or newer. '
        'Please update your version constraint in pubspec.yaml.',
        tag: Tag.cli,
        level: Level.critical,
      );
      _exitFn(1);
    }

    if (flutterMode == FlutterMode.embedded) {
      logger.write(
        'Using "--experimental-wasm" is currently not supported together with Flutter embedding.',
        tag: Tag.cli,
        level: Level.critical,
      );
      _exitFn(1);
    }
  }

  void checkFlutterBuildSupport() {
    final devDependencies = pubspecYaml?['dev_dependencies'] as Map<Object?, Object?>?;
    final version = switch (devDependencies?['build_web_compilers']) {
      final String v => VersionConstraint.parse(v),
      _ => null,
    };
    final minVersion = VersionConstraint.compatibleWith(Version(4, 4, 6));
    if (version == null || !minVersion.allowsAll(version)) {
      logger.write(
        'Using "jaspr.flutter=${flutterMode.name}" in pubspec.yaml requires build_web_compilers 4.4.6 or newer. '
        'Please update your version constraint in pubspec.yaml.',
        tag: Tag.cli,
        level: Level.critical,
      );

      _exitFn(1);
    }
  }
}

const defaultServePort = '8080';
const serverProxyPort = '5567';
const flutterProxyPort = '5678';

final dartExecutable = () {
  if (Platform.isWindows) {
    // Use 'where.exe' to support powershell as well
    final result = (ProcessRunner.instance.runSync('where.exe', ['dart.exe'])).stdout.toString();
    return result.split(RegExp('(\r\n|\r|\n)')).first.trim();
  }
  return (ProcessRunner.instance.runSync('which', ['dart'])).stdout.toString().trim();
}();

final dartSdkVersion = () async {
  final result = ProcessRunner.instance.runSync(dartExecutable, ['--version']);
  if (result.exitCode != 0) {
    return 'unknown';
  }
  final output = result.stdout.toString().trim();
  if (output.startsWith('Dart SDK version:')) {
    return output.substring('Dart SDK version:'.length).trim();
  }
  return 'unknown';
}();

/// The path to the root directory of the SDK.
final String? dartSdkDir = (() {
  final maybeDartSdkDir = path.dirname(path.dirname(dartExecutable));
  if (io.FileSystemEntity.isFileSync(path.join(maybeDartSdkDir, 'version'))) {
    return maybeDartSdkDir;
  }

  final maybeFlutterDartSdkDir = path.join(path.dirname(dartExecutable), 'cache', 'dart-sdk');
  if (io.FileSystemEntity.isFileSync(path.join(maybeFlutterDartSdkDir, 'version'))) {
    return maybeFlutterDartSdkDir;
  }

  return null;
})();

final String? dartDevToolsPath = dartSdkDir != null ? path.join(dartSdkDir!, 'bin', 'resources', 'devtools') : null;
