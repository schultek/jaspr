import 'dart:io';

import 'package:build_daemon/client.dart';
import 'package:build_daemon/constants.dart';
import 'package:build_daemon/data/server_log.dart';
import 'package:path/path.dart' as p;

/// The path to the root directory of the SDK.
final String _sdkDir = (() {
  // The Dart executable is in "/path/to/sdk/bin/dart", so two levels up is
  // "/path/to/sdk".
  final aboveExecutable = p.dirname(p.dirname(Platform.resolvedExecutable));
  assert(FileSystemEntity.isFileSync(p.join(aboveExecutable, 'version')));
  return aboveExecutable;
})();

final String dartPath = p.join(_sdkDir, 'bin', 'dart');
final String devToolsPath = p.join(_sdkDir, 'bin', 'resources', 'devtools');

/// Connects to the `build_runner` daemon.
Future<BuildDaemonClient> connectClient(
  String workingDirectory,
  List<String> options,
  void Function(ServerLog) logHandler,
) => BuildDaemonClient.connect(workingDirectory, [
  dartPath,
  'run',
  'build_runner',
  'daemon',
  ...options,
], logHandler: logHandler);

/// Returns the port of the daemon asset server.
int daemonPort(String workingDirectory) {
  final portFile = File(_assetServerPortFilePath(workingDirectory));
  if (!portFile.existsSync()) {
    throw Exception('Unable to read daemon asset port file.');
  }
  return int.parse(portFile.readAsStringSync());
}

String _assetServerPortFilePath(String workingDirectory) => '${daemonWorkspace(workingDirectory)}/.asset_server_port';
