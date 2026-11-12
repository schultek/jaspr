import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build_daemon/client.dart';
import 'package:build_daemon/constants.dart';
import 'package:path/path.dart' as p;

import '../commands/base_command.dart';
import '../logging.dart';
import '../process_runner.dart';
import '../project.dart';

/// Connects to the `build_runner` daemon.
Future<BuildDaemonClient?> startBuildDaemon(String workingDirectory, List<String> buildOptions, Logger logger) async {
  logger.write('Connecting to the build daemon...', tag: Tag.builder, progress: ProgressState.running);
  final args = [dartExecutable, 'run', 'build_runner', 'daemon', ...buildOptions];
  if (ProcessRunner.isDefault) {
    try {
      return await BuildDaemonClient.connect(workingDirectory, args, logHandler: logger.writeServerLog);
    } on OptionsSkew catch (e) {
      logger.write(
        'Incompatible options with current running build daemon: ${e.details}\n\n'
        'Please stop other Jaspr processes running in this directory and try again.',
        tag: Tag.cli,
        level: Level.critical,
        progress: ProgressState.completed,
      );
      return null;
    } on VersionSkew catch (e) {
      logger.write(
        'Incompatible version with current running build daemon: ${e.details}\n\n'
        'Please use the latest version of build_runner and try again.',
        tag: Tag.cli,
        level: Level.critical,
        progress: ProgressState.completed,
      );
      return null;
    } on MissingPortFile catch (e) {
      logger.write(
        'Failed to start build daemon: ${e.details}.\n\n'
        'Please use the latest version of build_runner and try again.',
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
  } else {
    await ProcessRunner.instance.start(args.first, args.sublist(1), workingDirectory: workingDirectory);
    return await BuildDaemonClient.connectUnchecked(workingDirectory, logHandler: logger.writeServerLog);
  }
}

/// Returns the port of the running daemon if the port file exists.
int? getDaemonPort(String workingDirectory) {
  try {
    final portFile = File(portFilePath(workingDirectory));
    if (!portFile.existsSync()) return null;
    final lines = portFile.readAsLinesSync();
    if (lines.isEmpty) return null;
    return int.tryParse(lines.first);
  } catch (_) {
    return null;
  }
}

/// Returns the port of the daemon asset server if the port file exists.
int? getAssetServerPort(String workingDirectory) {
  try {
    final portFile = File(assetServerPortFilePath(workingDirectory));
    if (!portFile.existsSync()) return null;
    return int.tryParse(portFile.readAsStringSync().trim());
  } catch (_) {
    return null;
  }
}

/// Finds the PIDs of processes listening on the given port.
Future<List<int>> findPidsForPort(int port) async {
  final pids = <int>{};
  if (Platform.isWindows) {
    try {
      final proc = await ProcessRunner.instance.run('netstat', ['-ano']);
      if (proc.exitCode == 0) {
        final lines = (proc.stdout as String).split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;
          final tokens = trimmed.split(RegExp(r'\s+'));
          if (tokens.length < 4) continue;

          final localAddress = tokens[1];
          final parts = localAddress.split(':');
          if (parts.isNotEmpty) {
            final p = parts.last;
            if (p == '$port') {
              final pidStr = tokens.last;
              final pid = int.tryParse(pidStr);
              if (pid != null && pid != 0) {
                pids.add(pid);
              }
            }
          }
        }
      }
    } catch (_) {}
  } else {
    try {
      final proc = await ProcessRunner.instance.run('lsof', ['-tiTCP:$port', '-sTCP:LISTEN']);
      if (proc.exitCode == 0) {
        final lines = (proc.stdout as String).split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;
          final pid = int.tryParse(trimmed);
          if (pid != null && pid != 0) {
            pids.add(pid);
          }
        }
      }
    } catch (_) {}
  }
  return pids.toList();
}

bool _isPidRunning(int pid) {
  if (Platform.isWindows) {
    try {
      final res = ProcessRunner.instance.runSync('tasklist', ['/FI', 'PID eq $pid']);
      return res.stdout.toString().contains('$pid');
    } catch (_) {
      return false;
    }
  } else {
    try {
      final res = ProcessRunner.instance.runSync('kill', ['-0', '$pid']);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}

/// Recursively terminates a process and its child processes.
Future<void> killProcessTree(int pid) async {
  if (Platform.isWindows) {
    try {
      await ProcessRunner.instance.run('taskkill', ['/F', '/T', '/PID', '$pid']);
    } catch (_) {
      try {
        Process.killPid(pid);
      } catch (_) {}
    }
    return;
  }

  // Find child processes on Unix
  final childPids = <int>[];
  try {
    final res = await ProcessRunner.instance.run('pgrep', ['-P', '$pid']);
    if (res.exitCode == 0) {
      final lines = (res.stdout as String).split('\n');
      for (final line in lines) {
        final child = int.tryParse(line.trim());
        if (child != null && child != 0) {
          childPids.add(child);
        }
      }
    }
  } catch (_) {}

  for (final child in childPids) {
    await killProcessTree(child);
  }

  // Request graceful termination first
  try {
    Process.killPid(pid);
  } catch (_) {}

  final sw = Stopwatch()..start();
  while (sw.elapsedMilliseconds < 500) {
    if (!_isPidRunning(pid)) return;
    await Future.pause(const Duration(milliseconds: 50));
  }

  // Force kill if still running
  try {
    Process.killPid(pid, ProcessSignal.sigkill);
  } catch (_) {}
}

/// Stop any running build daemon in the given [workingDirectory] and clean up lock/port files.
Future<void> stopDaemon(String workingDirectory, {List<int>? knownPids}) async {
  final pids = <int>{...?knownPids};

  final daemonPort = getDaemonPort(workingDirectory);
  if (daemonPort != null) {
    pids.addAll(await findPidsForPort(daemonPort));
  }

  final assetPort = getAssetServerPort(workingDirectory);
  if (assetPort != null) {
    pids.addAll(await findPidsForPort(assetPort));
  }

  for (final pid in pids) {
    await killProcessTree(pid);
  }

  _cleanupDaemonFiles(workingDirectory);
}

void _cleanupDaemonFiles(String workingDirectory) {
  for (final path in [
    portFilePath(workingDirectory),
    assetServerPortFilePath(workingDirectory),
    versionFilePath(workingDirectory),
    optionsFilePath(workingDirectory),
    lockFilePath(workingDirectory),
  ]) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }
}

/// Returns the port of the daemon asset server.
int daemonPort(String workingDirectory) {
  final portFile = File(assetServerPortFilePath(workingDirectory));
  if (!portFile.existsSync()) {
    throw Exception('Unable to read daemon asset port file.');
  }
  return int.parse(portFile.readAsStringSync());
}

String assetServerPortFilePath(String workingDirectory) => '${daemonWorkspace(workingDirectory)}/.asset_server_port';

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

/// Watches a running process, streaming its stdout and stderr to [logger],
/// and tracking its lifecycle.
class ProcessWatcher {
  ProcessWatcher(
    this.process, {
    required this.logger,
    this.tag = Tag.none,
    this.hide,
    this.levelFor,
    this.onLine,
    this.onStderr,
    this.progress,
    this.onExit,
    bool verbose = true,
    bool cancelOnExit = true,
  }) {
    errSub = process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (_stopped || BaseCommand.isShuttingDown) return;
      if (onStderr != null) {
        onStderr!(line);
      } else {
        logger.write(line, tag: tag, level: Level.error, progress: ProgressState.completed);
      }
    });

    outSub = process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((log) {
      if (!verbose || _stopped || BaseCommand.isShuttingDown) return;
      if (hide != null && hide!(log)) return;
      if (onLine != null) {
        onLine!(log);
      } else {
        final level = levelFor?.call(log) ?? Level.info;
        if (progress != null) {
          logger.write(log, tag: tag, level: level, progress: progress);
        } else {
          logger.write(log, tag: tag, level: level);
        }
      }
    });

    if (onExit != null) {
      process.exitCode.then((code) async {
        if (cancelOnExit) {
          await cancel();
        }
        onExit!(code);
      });
    }
  }

  final Process process;
  final Logger logger;
  final Tag tag;
  final bool Function(String)? hide;
  final Level? Function(String)? levelFor;
  final void Function(String line)? onLine;
  final void Function(String line)? onStderr;
  final ProgressState? progress;
  final void Function(int exitCode)? onExit;

  late final StreamSubscription<void> errSub;
  late final StreamSubscription<void> outSub;

  bool _stopped = false;
  bool get isStopped => _stopped;

  Future<void> cancel() async {
    await errSub.cancel();
    await outSub.cancel();
  }

  Future<void> stop({String? message}) async {
    if (_stopped) return;
    _stopped = true;
    if (message != null) {
      logger.write(message, level: Level.debug);
    }
    await cancel();
    if (Platform.isWindows) {
      await killProcessTree(process.pid);
    } else {
      process.kill();
    }
    await process.exitCode;
  }

  /// Returns true if [exitCode] indicates an abnormal termination (not 0 and not SIGINT/SIGTERM signals).
  static bool isUnexpectedExit(int code) {
    return code != 0 && code != 130 && code != -2 && code != 143 && code != -15;
  }
}

/// Runs and watches [process] until completion, streaming stdout and stderr.
Future<int> watchProcess(
  String name,
  Process process, {
  required Logger logger,
  Tag tag = Tag.none,
  String? progress,
  bool Function(String)? hide,
  Level? Function(String)? levelFor,
  void Function(FutureOr<void> Function() fn)? guard,
  void Function(int exitCode)? onComplete,
  FutureOr<void> Function(int exitCode)? onFail,
}) async {
  if (progress != null) {
    logger.write(progress, tag: tag, progress: ProgressState.running);
  }

  int? exitCode;
  bool wasKilled = false;

  final watcher = ProcessWatcher(
    process,
    logger: logger,
    tag: tag,
    hide: hide,
    levelFor: levelFor,
    progress: progress != null ? ProgressState.running : null,
  );

  guard?.call(() async {
    if (exitCode == null) {
      wasKilled = true;
      await watcher.stop(message: 'Stopping $name...');
    }
  });

  exitCode = await process.exitCode.then<int>((c) => Future.delayed(const Duration(seconds: 1), () => c));

  if (wasKilled) {
    return exitCode;
  }

  await Future.pause(const Duration(milliseconds: 300));
  await watcher.cancel();

  onComplete?.call(exitCode);

  if (exitCode != 0) {
    if (onFail != null) {
      await onFail(exitCode);
    }
  } else if (progress != null) {
    logger.complete(true);
  }

  return exitCode;
}
