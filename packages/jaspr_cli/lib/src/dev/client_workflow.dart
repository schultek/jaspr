// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:build_daemon/client.dart';
import 'package:build_daemon/data/build_target.dart';
import 'package:dwds/dwds.dart';

import '../logging.dart';
import 'dev_proxy.dart';
import 'util.dart';

/// Controls the web development workflow.
///
/// Connects to the Build Daemon, creates servers, launches Chrome and wires up
/// the DevTools.
class ClientWorkflow {
  static Future<ClientWorkflow?> start(
    List<String> buildOptions,
    Logger logger,
    void Function(FutureOr<void> Function()) guard, {
    bool autoRun = true,
    bool enableDebugging = false,
    ReloadConfiguration reload = ReloadConfiguration.none,
  }) async {
    var cancelled = false;

    final op = CancelableOperation<ClientWorkflow?>.fromFuture(
      Future(() async {
        final workingDirectory = Directory.current.path;

        final client = await startBuildDaemon(workingDirectory, buildOptions, logger);
        if (client == null) return null;
        if (cancelled) {
          client.close();
          return null;
        }

        client.registerBuildTarget(DefaultBuildTarget((b) => b..target = 'web'));

        logger.write('Starting initial build...', tag: Tag.builder, progress: ProgressState.running);
        client.startBuild();

        final assetPort = daemonPort(workingDirectory);
        final devProxy = await DevProxy.start(
          assetPort,
          client.buildResults,
          autoRun: autoRun,
          enableDebugging: enableDebugging,
          reload: reload,
        );

        if (cancelled) {
          await client.close();
          await devProxy.stop();
          return null;
        }

        return ClientWorkflow._(client, devProxy, logger);
      }),
    );

    guard(() {
      op.cancel();
      cancelled = true;
    });

    return op.valueOrCancellation(null);
  }

  ClientWorkflow._(this.client, this.devProxy, this.logger) {
    client.shutdownNotifications.listen((data) {
      logger.write(data.message, tag: Tag.builder, level: Level.warning);
      if (data.failureType == 75) {
        logger.write('Please restart Jaspr.', tag: Tag.builder, level: Level.critical);
      }
      shutDown();
    });
  }

  final _doneCompleter = Completer<void>();
  final BuildDaemonClient client;
  final Logger logger;

  final DevProxy devProxy;

  Future<void> get done => _doneCompleter.future;

  Future<void> shutDown() async {
    await client.close();
    await devProxy.stop();
    if (!_doneCompleter.isCompleted) _doneCompleter.complete();
  }
}
