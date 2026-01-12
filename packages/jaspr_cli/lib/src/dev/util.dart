import 'dart:io';

import 'package:build_daemon/client.dart';
import 'package:build_daemon/constants.dart';
import 'package:path/path.dart' as p;

import '../logging.dart';
import '../project.dart';

/// Connects to the `build_runner` daemon.
Future<BuildDaemonClient?> startBuildDaemon(String workingDirectory, List<String> buildOptions, Logger logger) async {
  try {
    logger.write('Connecting to the build daemon...', tag: Tag.builder, progress: ProgressState.running);
    final args = [dartExecutable, 'run', 'build_runner', 'daemon', ...buildOptions];
    return await BuildDaemonClient.connect(workingDirectory, args, logHandler: logger.writeServerLog);
  } on OptionsSkew {
    logger.write(
      'Incompatible options with current running build daemon.\n\n'
      'Please stop other Jaspr processes running in this directory and try again.',
      tag: Tag.cli,
      level: Level.critical,
      progress: ProgressState.completed,
    );
    return null;
  } on VersionSkew {
    logger.write(
      'Incompatible version with current running build daemon.\n\n'
      'Please stop other Jaspr processes running in this directory and try again.',
      tag: Tag.cli,
      level: Level.critical,
      progress: ProgressState.completed,
    );
    return null;
  } catch (e) {
    logger.write(e.toString(), tag: Tag.builder, level: Level.error, progress: ProgressState.completed);
    logger.write(
      'Failed to connect to the build daemon. See the error above for more details.',
      tag: Tag.cli,
      level: Level.critical,
      progress: ProgressState.completed,
    );
    return null;
  }
}

/// Returns the port of the daemon asset server.
int daemonPort(String workingDirectory) {
  final portFile = File(_assetServerPortFilePath(workingDirectory));
  if (!portFile.existsSync()) {
    throw Exception('Unable to read daemon asset port file.');
  }
  return int.parse(portFile.readAsStringSync());
}

String _assetServerPortFilePath(String workingDirectory) => '${daemonWorkspace(workingDirectory)}/.asset_server_port';

/// Returns the absolute file path of the `package_config.json` file in the `.dart_tool`
/// directory, searching recursively from the current directory hierarchy.
String? findPackageConfigFilePath() {
  var candidateDir = Directory(p.current).absolute;

  while (true) {
    final candidatePackageConfigFile = File(p.join(candidateDir.path, '.dart_tool', 'package_config.json'));

    if (candidatePackageConfigFile.existsSync()) {
      return candidatePackageConfigFile.path;
    }

    final parentDir = candidateDir.parent;
    if (parentDir.path == candidateDir.path) {
      // We've reached the root directory
      return null;
    }

    candidateDir = parentDir;
  }
}

String? getStringArg(Map<String, dynamic> args, String name, {bool required = false}) {
  if (required && !args.containsKey(name)) {
    throw ArgumentError('$name is required');
  }
  final val = args[name];
  if (val != null && val is! String) {
    throw ArgumentError('$name is not a String');
  }
  return val as String?;
}

bool? getBoolArg(Map<String, dynamic> args, String name, {bool required = false}) {
  if (required && !args.containsKey(name)) {
    throw ArgumentError('$name is required');
  }
  final val = args[name];
  if (val != null && val is! bool) throw ArgumentError('$name is not a bool');
  return val as bool?;
}

int? getIntArg(Map<String, dynamic> args, String name, {bool required = false}) {
  if (required && !args.containsKey(name)) {
    throw ArgumentError('$name is required');
  }
  final val = args[name];
  if (val != null && val is! int) throw ArgumentError('$name is not an int');
  return val as int?;
}
