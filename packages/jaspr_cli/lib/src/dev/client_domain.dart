// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dwds/data/build_result.dart';
import 'package:dwds/dwds.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';
import 'package:webdev/src/daemon/daemon.dart';
import 'package:webdev/src/daemon/domain.dart';
import 'package:webdev/src/daemon/utilites.dart';
import 'package:webdev/src/serve/server_manager.dart';
import 'package:webdev/src/serve/webdev_server.dart';

/// A collection of method and events relevant to the running application.
class ClientDomain extends Domain {
  ClientDomain(Daemon daemon, ServerManager serverManager) : super(daemon, 'client') {
    registerHandler('restart', _restart);
    registerHandler('callServiceExtension', _callServiceExtension);
    registerHandler('stop', _stop);

    _initialize(serverManager);
  }

  bool _isShutdown = false;
  int? _buildProgressEventId;
  var _progressEventId = 0;

  final _clientStates = <String, _ClientState>{};

  // Mapping from service name to service method.
  final Map<String, String> _registeredMethodsForService = <String, String>{};

  void _handleBuildResult(BuildResult result, String appId) {
    switch (result.status) {
      case BuildStatus.started:
        _buildProgressEventId = _progressEventId++;
        sendEvent('client.progress', {
          'appId': appId,
          'id': '$_buildProgressEventId',
          'message': 'Building...',
        });
        break;
      case BuildStatus.failed:
        sendEvent('client.progress', {
          'appId': appId,
          'id': '$_buildProgressEventId',
          'finished': true,
        });
        break;
      case BuildStatus.succeeded:
        sendEvent('client.progress', {
          'appId': appId,
          'id': '$_buildProgressEventId',
          'finished': true,
        });
        break;
      default:
        break;
    }
  }

  void _initialize(ServerManager serverManager) {
    serverManager.servers.forEach(_handleAppConnections);
  }

  Future<void> _handleAppConnections(WebDevServer server) async {
    final dwds = server.dwds!;

    // The connection is established right before `main()` is called.
    await for (final appConnection in dwds.connectedApps) {
      final appId = appConnection.request.appId;

      if (_clientStates.containsKey(appId)) {
        appConnection.runMain();
        continue;
      }

      _clientStates[appId] = _ClientState(appConnection, dwds, this)..start(server);
    }

    // Shutdown could have been triggered while awaiting above.
    if (_isShutdown) dispose();
  }

  void _onServiceEvent(Event e) {
    if (e.kind == EventKind.kServiceRegistered) {
      final serviceName = e.service!;
      _registeredMethodsForService[serviceName] = e.method!;
    }

    if (e.kind == EventKind.kServiceUnregistered) {
      final serviceName = e.service!;
      _registeredMethodsForService.remove(serviceName);
    }
  }

  Future<Map<String, dynamic>?> _callServiceExtension(Map<String, dynamic> args) async {
    final appId = getStringArg(args, 'appId', required: true);
    final appState = _clientStates[appId];
    if (appState == null) {
      throw ArgumentError.value(appId, 'appId', 'Not found');
    }
    final methodName = getStringArg(args, 'methodName', required: true)!;
    final params = args['params'] != null ? (args['params'] as Map<String, dynamic>) : <String, dynamic>{};
    final response = await appState.vmService?.callServiceExtension(methodName, args: params);
    return response?.json;
  }

  Future<Map<String, dynamic>> _restart(Map<String, dynamic> args) async {
    final appId = getStringArg(args, 'appId', required: true);
    final appState = _clientStates[appId];
    if (appState == null) {
      throw ArgumentError.value(appId, 'appId', 'Not found');
    }
    final fullRestart = getBoolArg(args, 'fullRestart') ?? false;
    if (!fullRestart) {
      return {
        'code': 1,
        'message': 'hot reload not yet supported by webdev',
      };
    }
    // TODO(grouma) - Support pauseAfterRestart.
    // var pauseAfterRestart = getBoolArg(args, 'pause') ?? false;
    final stopwatch = Stopwatch()..start();
    _progressEventId++;
    sendEvent('app.progress', {
      'appId': appId,
      'id': '$_progressEventId',
      'message': 'Performing hot restart...',
      'progressId': 'hot.restart',
    });
    final restartMethod = _registeredMethodsForService['hotRestart'] ?? 'hotRestart';
    final response = await appState.vmService?.callServiceExtension(restartMethod);
    sendEvent('app.progress', {
      'appId': appId,
      'id': '$_progressEventId',
      'finished': true,
      'progressId': 'hot.restart',
    });
    sendEvent('app.log', {'appId': appId, 'log': 'Restarted application in ${stopwatch.elapsedMilliseconds}ms'});
    return {'code': response?.type == 'Success' ? 0 : 1, 'message': response.toString()};
  }

  Future<bool> _stop(Map<String, dynamic> args) async {
    final appId = getStringArg(args, 'appId', required: true);
    final appState = _clientStates[appId];
    if (appState == null) {
      throw ArgumentError.value(appId, 'appId', 'Not found');
    }
    await appState._debugConnection?.close();
    return true;
  }

  @override
  void dispose() {
    _isShutdown = true;
    for (final state in _clientStates.values) {
      state.dispose();
    }
    _clientStates.clear();
  }
}

class _ClientState {
  _ClientState(this._appConnection, this.dwds, this.domain);

  final AppConnection _appConnection;
  final Dwds dwds;
  final ClientDomain domain;

  DebugConnection? _debugConnection;
  StreamSubscription<BuildResult>? _resultSub;
  StreamSubscription<Event>? _stdOutSub;
  StreamSubscription<Event>? _vmServiceSub;

  bool _isDisposed = false;

  VmService? get vmService => _debugConnection?.vmService;

  void start(WebDevServer server) async {
    final appId = _appConnection.request.appId;
    try {
      final debugConnection = _debugConnection = await dwds.debugConnection(_appConnection);
      final debugUri = debugConnection.ddsUri ?? debugConnection.uri;
      final vmService = await vmServiceConnectUri(debugUri);

      if (_isDisposed) return;

      unawaited(debugConnection.onDone.then((_) {
        domain.sendEvent('client.log', {
          'appId': appId,
          'log': 'Lost connection to device.',
        });
        domain.sendEvent('client.stop', {
          'appId': appId,
        });
        dispose();
        domain._clientStates.remove(appId);
      }));

      domain.sendEvent('client.start', {
        'appId': appId,
        'directory': Directory.current.path,
        'deviceId': 'chrome',
        'launchMode': 'run',
      });

      try {
        await vmService.streamCancel('Stdout');
      } catch (_) {}
      try {
        await vmService.streamListen('Stdout');
      } catch (_) {}

      try {
        _vmServiceSub = vmService.onServiceEvent.listen(domain._onServiceEvent);
        await vmService.streamListen('Service');
      } catch (_) {}

      if (_isDisposed) return;

      _stdOutSub = vmService.onStdoutEvent.listen((log) {
        domain.sendEvent('client.log', {
          'appId': appId,
          'log': utf8.decode(base64.decode(log.bytes!)),
        });
      });

      domain.sendEvent('client.debugPort', {
        'appId': appId,
        'port': debugConnection.port,
        'wsUri': debugConnection.uri,
      });
    } catch (e) {
      // noop
    }

    _resultSub = server.buildResults.listen((r) {
      domain._handleBuildResult(r, appId);
    });

    domain.sendEvent('app.started', {
      'appId': appId,
    });
    
    _appConnection.runMain();
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    _stdOutSub?.cancel();
    _resultSub?.cancel();
    _vmServiceSub?.cancel();
    _debugConnection?.close();
  }
}
