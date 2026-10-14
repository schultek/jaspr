import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:build_daemon/client.dart';
import 'package:build_daemon/data/build_status.dart' as daemon;
import 'package:build_daemon/data/build_target.dart';
import 'package:collection/collection.dart';

import '../logging.dart';
import 'util.dart' as util;

/// Manages the client compilation using the Build Daemon.
class ClientRunner {
  final BuildDaemonClient client;
  final int daemonPort;
  final Logger logger;
  final _doneCompleter = Completer<int>();

  Stream<daemon.BuildResults> get buildResults => client.buildResults;
  Future<int> get done => _doneCompleter.future;

  void startBuild() => client.startBuild();

  ClientRunner._(this.client, this.daemonPort, this.logger) {
    client.shutdownNotifications.listen((data) {
      logger.write(data.message, tag: Tag.builder, level: Level.warning);
      if (data.failureType == 75) {
        logger.write('Please restart Jaspr.', tag: Tag.builder, level: Level.critical);
      }
      shutDown(data.failureType);
    });
  }

  /// Starts the build daemon for development watching.
  static Future<ClientRunner?> start(
    List<String> buildOptions,
    Logger logger,
    void Function(FutureOr<void> Function()) guard,
  ) async {
    var cancelled = false;

    final op = CancelableOperation<ClientRunner?>.fromFuture(
      Future(() async {
        final workingDirectory = Directory.current.path;

        final client = await util.startBuildDaemon(workingDirectory, buildOptions, logger);
        if (client == null) return null;
        if (cancelled) {
          await client.close();
          return null;
        }

        logger.write('Starting initial build...', tag: Tag.builder, progress: ProgressState.running);

        client.registerBuildTarget(
          DefaultBuildTarget(
            (b) => b
              ..target = 'web'
              ..reportChangedAssets = true,
          ),
        );

        return ClientRunner._(client, util.daemonPort(workingDirectory), logger);
      }),
    );

    guard(() {
      if (!op.isCompleted) {
        op.cancel();
        cancelled = true;
      }
    });

    return op.valueOrCancellation(null);
  }

  /// Performs a one-shot build using the build daemon.
  static Future<int> build({
    required List<String> buildOptions,
    required String outputDir,
    required Logger logger,
    void Function(FutureOr<void> Function())? guard,
  }) async {
    final client = await util.startBuildDaemon(Directory.current.path, buildOptions, logger);
    if (client == null) {
      return 1;
    }

    guard?.call(() async {
      await client.close();
    });

    final outputLocation = OutputLocation(
      (b) => b
        ..output = outputDir
        ..useSymlinks = false
        ..hoist = true,
    );

    client.registerBuildTarget(
      DefaultBuildTarget(
        (b) => b
          ..target = 'web'
          ..outputLocation = outputLocation.toBuilder(),
      ),
    );

    client.startBuild();

    var exitCode = 0;
    var gotBuildStart = false;
    await for (final result in client.buildResults) {
      final targetResult = result.results.firstWhereOrNull((daemon.BuildResult r) => r.target == 'web');
      if (targetResult == null) continue;

      gotBuildStart = gotBuildStart || targetResult.status == daemon.BuildStatus.started;
      if (!gotBuildStart) continue;

      if (targetResult.status == daemon.BuildStatus.started) continue;

      if (targetResult.status == daemon.BuildStatus.failed) {
        exitCode = 1;
      }

      final error = targetResult.error ?? '';
      if (error.isNotEmpty) {
        logger.complete(false);
        logger.write(error, level: Level.error);
      }
      break;
    }

    await client.close();
    return exitCode;
  }

  bool _isShutDown = false;

  Future<void> shutDown([int code = 0]) async {
    if (_isShutDown) return;
    _isShutDown = true;
    logger.write('Stopping web compilers...', level: Level.debug);
    await client.close();
    if (!_doneCompleter.isCompleted) _doneCompleter.complete(code);
  }
}
