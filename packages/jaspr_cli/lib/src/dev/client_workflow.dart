// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:build_daemon/client.dart';
import 'package:build_daemon/data/build_target.dart';
import 'package:build_daemon/data/server_log.dart' show toLoggingLevel;
import 'package:logging/logging.dart' as logging;

import 'package:webdev/src/command/configuration.dart';
import 'package:webdev/src/daemon_client.dart';
import 'package:webdev/src/serve/server_manager.dart';
import 'package:webdev/src/serve/webdev_server.dart';

import '../logging.dart';

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
  ) async {
    final workingDirectory = Directory.current.path;
    final targetPorts = {'web': int.parse(targetPort)};

    final client = await _startBuildDaemon(workingDirectory, buildOptions, logger);
    if (client == null) return null;
    _registerBuildTargets(client, configuration, targetPorts);

    logger.write('Starting initial build...', tag: Tag.builder, progress: ProgressState.running);
    client.startBuild();

    final serverManager = await _startServerManager(configuration, targetPorts, workingDirectory, client, logger);

    return ClientWorkflow._(client, serverManager, logger);
  }

  ClientWorkflow._(
    this.client,
    this.serverManager,
    this.logger,
  ) {
    client.shutdownNotifications.listen((data) {
      logger.write(data.message, tag: Tag.builder, level: Level.warning);
      if (data.failureType == 75) {
        logger.write('Please restart Jaspr.', tag: Tag.builder, level: Level.critical);
      }
      shutDown();
    });
  }

  final _doneCompleter = Completer();
  final BuildDaemonClient client;
  final Logger logger;

  final ServerManager serverManager;
  StreamSubscription? _resultsSub;

  Future<void> get done => _doneCompleter.future;

  Future<void> shutDown() async {
    await _resultsSub?.cancel();
    await client.close();
    await serverManager.stop();
    if (!_doneCompleter.isCompleted) _doneCompleter.complete();
  }
}

Future<BuildDaemonClient?> _startBuildDaemon(String workingDirectory, List<String> buildOptions, Logger logger) async {
  try {
    logger.write('Connecting to the build daemon...', tag: Tag.builder, progress: ProgressState.running);
    return await connectClient(
      workingDirectory,
      buildOptions,
      (serverLog) {
        var level = toLoggingLevel(serverLog.level);
        if (level.value < logging.Level.INFO.value) return;

        if (!logger.verbose && level.value < logging.Level.WARNING.value) return;

        // We log our own server and don't want to confuse the user.
        if (serverLog.message.startsWith('Serving `web` on')) {
          return;
        }

        var buffer = StringBuffer(serverLog.message);
        if (serverLog.error != null) {
          buffer.writeln(serverLog.error);
        }

        var log = buffer.toString().trim();
        if (log.isEmpty) {
          return;
        }
        logger.write(log, tag: Tag.builder, level: level.toLevel());
      },
    );
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


Future<ServerManager> _startServerManager(
  Configuration configuration,
  Map<String, int> targetPorts,
  String workingDirectory,
  BuildDaemonClient client,
  Logger logger,
) async {
  final assetPort = daemonPort(workingDirectory);
  final serverOptions = <ServerOptions>{};
  for (final target in targetPorts.keys) {
    serverOptions.add(ServerOptions(
      configuration,
      targetPorts[target]!,
      target,
      assetPort,
    ));
  }
  logger.write('Starting resource servers...', tag: Tag.builder, level: Level.verbose, progress: ProgressState.running);
  final serverManager = await ServerManager.start(serverOptions, client.buildResults);

  for (final server in serverManager.servers) {
    logger.write(
      'Serving `${server.target}` on '
      '${Uri(scheme: server.protocol, host: server.host, port: server.port)}\n',
      tag: Tag.builder,
      level: Level.verbose,
      progress: ProgressState.running,
    );
  }

  return serverManager;
}

void _registerBuildTargets(
  BuildDaemonClient client,
  Configuration configuration,
  Map<String, int> targetPorts,
) {
  // Register a target for each serve target.
  for (final target in targetPorts.keys) {
    OutputLocation? outputLocation;
    if (configuration.outputPath != null &&
        (configuration.outputInput == null || target == configuration.outputInput)) {
      outputLocation = OutputLocation((b) => b
        ..output = configuration.outputPath
        ..useSymlinks = true
        ..hoist = true);
    }
    client.registerBuildTarget(DefaultBuildTarget((b) => b
      ..target = target
      ..outputLocation = outputLocation?.toBuilder()));
  }
  // Empty string indicates we should build everything, register a corresponding
  // target.
  if (configuration.outputInput == '' && configuration.outputPath != null) {
    final outputLocation = OutputLocation((b) => b
      ..output = configuration.outputPath
      ..useSymlinks = true
      ..hoist = false);
    client.registerBuildTarget(DefaultBuildTarget((b) => b
      ..target = ''
      ..outputLocation = outputLocation.toBuilder()));
  }
}
