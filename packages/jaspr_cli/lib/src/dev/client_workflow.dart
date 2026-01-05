// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:build_daemon/client.dart';
import 'package:build_daemon/data/build_target.dart';

import 'package:webdev/src/command/configuration.dart';

import '../logging.dart';
import 'dev_proxy.dart';
import 'util.dart';

export 'package:webdev/src/command/configuration.dart';

/// Controls the web development workflow.
///
/// Connects to the Build Daemon, creates servers, launches Chrome and wires up
/// the DevTools.
class ClientWorkflow {
  static Future<ClientWorkflow?> start(
    Configuration configuration,
    List<String> buildOptions,
    String targetPort,
    Logger logger,
    void Function(FutureOr<void> Function()) guard,
  ) async {
    var cancelled = false;

    final op = CancelableOperation<ClientWorkflow?>.fromFuture(
      Future(() async {
        final workingDirectory = Directory.current.path;
        final targetPorts = {'web': int.parse(targetPort)};

        final client = await _startBuildDaemon(workingDirectory, buildOptions, logger);
        if (client == null) return null;
        if (cancelled) {
          client.close();
          return null;
        }
        _registerBuildTargets(client, configuration, targetPorts);

        logger.write('Starting initial build...', tag: Tag.builder, progress: ProgressState.running);
        client.startBuild();

        final assetPort = daemonPort(workingDirectory);
        final devProxy = await DevProxy.start(
          assetPort,
          client.buildResults,
          autoRun: configuration.autoRun,
          enableDebugging: configuration.debug,
          reload: configuration.reload,
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

Future<BuildDaemonClient?> _startBuildDaemon(String workingDirectory, List<String> buildOptions, Logger logger) async {
  try {
    logger.write('Connecting to the build daemon...', tag: Tag.builder, progress: ProgressState.running);
    return await connectClient(workingDirectory, buildOptions, logger.writeServerLog);
  } on OptionsSkew {
    logger.write(
      'Incompatible options with current running build daemon.\n\n'
      'Please stop other Jaspr processes running in this directory '
      'before starting a new process with these options.',
      tag: Tag.cli,
      level: Level.critical,
      progress: ProgressState.completed,
    );
    return null;
  }
}

void _registerBuildTargets(BuildDaemonClient client, Configuration configuration, Map<String, int> targetPorts) {
  // Register a target for each serve target.
  for (final target in targetPorts.keys) {
    OutputLocation? outputLocation;
    if (configuration.outputPath != null &&
        (configuration.outputInput == null || target == configuration.outputInput)) {
      outputLocation = OutputLocation(
        (b) => b
          ..output = configuration.outputPath
          ..useSymlinks = true
          ..hoist = true,
      );
    }
    client.registerBuildTarget(
      DefaultBuildTarget(
        (b) => b
          ..target = target
          ..outputLocation = outputLocation?.toBuilder(),
      ),
    );
  }
  // Empty string indicates we should build everything, register a corresponding
  // target.
  if (configuration.outputInput == '' && configuration.outputPath != null) {
    final outputLocation = OutputLocation(
      (b) => b
        ..output = configuration.outputPath
        ..useSymlinks = true
        ..hoist = false,
    );
    client.registerBuildTarget(
      DefaultBuildTarget(
        (b) => b
          ..target = ''
          ..outputLocation = outputLocation.toBuilder(),
      ),
    );
  }
}
