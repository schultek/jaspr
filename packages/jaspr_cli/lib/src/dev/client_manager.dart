import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dwds/data/build_result.dart';
import 'package:dwds/dwds.dart';
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

import '../logging.dart';
import 'dev_workflow.dart';

class ClientManager {
  ClientManager(this.workflow);

  final DevWorkflow workflow;
  final Map<String, ClientConnection> _clientConnections = {};
  final StreamController<Map<String, Object?>> _clientEvents = StreamController.broadcast();

  Stream<Map<String, Object?>> get clientEvents => _clientEvents.stream;

  String? get clientDevToolsUri => _clientConnections.values.firstOrNull?.devToolsUri;

  ClientConnection? getConnection(String? appId) {
    if (appId == null) return null;
    return _clientConnections[appId];
  }

  /// Runs [action] sequentially for each currently connected client.
  ///
  /// Clients that connect while this is running aren't included,
  /// and clients that are disposed before their turn are skipped.
  ///
  /// If [action] throws for a client, the error is logged as a warning
  /// prefixed with [actionName] and the remaining clients are still updated,
  /// so one disconnecting browser can't interrupt the others or later builds.
  Future<void> forEachConnection(String actionName, Future<void> Function(ClientConnection) action) async {
    // Connections can be added or removed while an action is awaiting an RPC.
    final connections = _clientConnections.values.toList(growable: false);
    for (final connection in connections) {
      if (connection._isDisposed) continue;

      try {
        await action(connection);
      } catch (error, stackTrace) {
        workflow.logger.write(
          '$actionName failed for client ${connection.appConnection.request.appId}: $error',
          tag: .client,
          level: .warning,
        );
        workflow.logger.write(stackTrace.toString(), tag: .client, level: .verbose);
      }
    }
  }

  StreamSubscription<AppConnection>? _appsSubscription;

  void listenTo(Dwds dwds) {
    _isStopped = false;
    _appsSubscription?.cancel();
    _appsSubscription = dwds.connectedApps.listen((appConnection) {
      final appId = appConnection.request.appId;

      if (_clientConnections.containsKey(appId)) {
        appConnection.runMain();
        return;
      }

      _clientConnections[appId] = ClientConnection(appConnection, dwds, this)..start();
    });
  }

  void _sendEvent(String method, Map<String, dynamic> params) {
    _clientEvents.add({'method': method, 'params': params});
  }

  void _removeConnection(String appId) {
    _clientConnections.remove(appId);
  }

  bool _isStopped = false;
  bool get isStopped => _isStopped;

  void stop() {
    _isStopped = true;
    _appsSubscription?.cancel();
    _appsSubscription = null;
    for (final connection in _clientConnections.values) {
      connection.dispose();
    }
    _clientConnections.clear();
  }
}

class ClientConnection {
  ClientConnection(this.appConnection, this.dwds, this.manager);

  final AppConnection appConnection;
  final Dwds dwds;
  final ClientManager manager;

  DebugConnection? _debugConnection;
  vm.VmService? _vmServiceClient;
  StreamSubscription<BuildResult>? _resultSub;
  StreamSubscription<vm.Event>? _stdOutSub;
  StreamSubscription<vm.Event>? _vmServiceSub;

  bool _isDisposed = false;
  String? devToolsUri;

  vm.VmService? get vmService => _debugConnection?.vmService;

  void start() async {
    final appId = appConnection.request.appId;

    try {
      final debugConnection = _debugConnection = await dwds.debugConnection(appConnection);
      final debugUri = debugConnection.ddsUri ?? debugConnection.uri;
      final wsUri = debugUri.startsWith('http') ? '${debugUri.replaceFirst('http', 'ws')}ws' : debugUri;
      final httpUri = debugUri.startsWith('ws') ? 'http${debugUri.substring(2).replaceAll('/ws', '/')}' : debugUri;
      final normalizedHttp = httpUri.endsWith('/') ? httpUri : '$httpUri/';
      devToolsUri = '${normalizedHttp}devtools/?uri=$wsUri';
      final vmService = _vmServiceClient = await vmServiceConnectUri(debugUri);

      if (_isDisposed) {
        _vmServiceClient?.dispose();
        _vmServiceClient = null;
        return;
      }

      unawaited(
        debugConnection.onDone.then((_) {
          if (!_isDisposed && !manager.isStopped && !manager.workflow.isShuttingDown) {
            sendEvent('client.log', {'appId': appId, 'log': 'Lost connection to device.'});
            sendEvent('client.stop', {'appId': appId});
          }
          dispose();
          manager._removeConnection(appId);
        }),
      );

      sendEvent('client.start', {
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
        _vmServiceSub = vmService.onServiceEvent.listen(_onServiceEvent);
        await vmService.streamListen('Service');
      } catch (_) {}

      if (_isDisposed) {
        _vmServiceClient?.dispose();
        _vmServiceClient = null;
        return;
      }

      _stdOutSub = vmService.onStdoutEvent.listen((log) {
        sendEvent('client.log', {'appId': appId, 'log': utf8.decode(base64.decode(log.bytes!))});
      });

      sendEvent('client.debugPort', {'appId': appId, 'port': debugConnection.port, 'wsUri': debugConnection.uri});
    } catch (_) {
      // noop
    }

    _resultSub = manager.workflow.buildResults.listen((r) {
      _handleBuildResult(r, appId);
    });

    sendEvent('app.started', {'appId': appId});

    appConnection.runMain();
  }

  void sendEvent(String method, Map<String, dynamic> params) {
    manager._sendEvent(method, params);
  }

  // Mapping from service name to service method.
  final Map<String, String> _registeredMethodsForService = {};

  void _onServiceEvent(vm.Event e) {
    if (e.kind == vm.EventKind.kServiceRegistered) {
      final serviceName = e.service!;
      _registeredMethodsForService[serviceName] = e.method!;
    } else if (e.kind == vm.EventKind.kServiceUnregistered) {
      final serviceName = e.service!;
      _registeredMethodsForService.remove(serviceName);
    }
  }

  Future<vm.Response?> restart() async {
    final restartMethod = _registeredMethodsForService['hotRestart'] ?? 'hotRestart';
    final response = await vmService?.callServiceExtension(restartMethod);
    return response;
  }

  Future<void> performHotReload() async {
    final vmService = this.vmService;
    if (vmService == null) {
      manager.workflow.logger.write(
        'Tried to perform hot reload before debug connection is ready.',
        tag: Tag.client,
        level: Level.warning,
      );
      return;
    }

    final isolateId = (await vmService.getVM()).isolates?.firstOrNull?.id;
    if (isolateId == null) {
      manager.workflow.logger.write(
        'Tried to perform hot reload but no isolate was found.',
        tag: Tag.client,
        level: Level.warning,
      );
      return;
    }

    vm.ReloadReport? response;
    for (var i = 0; i < 5; i++) {
      response = await vmService.reloadSources(isolateId);
      if (response.success ?? false) {
        break;
      }
    }
    if (!(response?.success ?? false)) {
      manager.workflow.logger.write(
        'Hot reload failed after 5 attempts for unknown reason.',
        tag: Tag.client,
        level: Level.warning,
      );
    }
  }

  Future<vm.Response?> reloadStylesheets(List<String> urls) async {
    final reloadMethod = _registeredMethodsForService['ext.jaspr.reload_stylesheets'] ?? 'ext.jaspr.reload_stylesheets';
    for (var i = 0; i < 5; i++) {
      try {
        final response = await vmService?.callServiceExtension(
          reloadMethod,
          args: {'urls': jsonEncode(urls)},
        );
        if (response != null) return response;
      } catch (_) {
        await Future.pause(const Duration(milliseconds: 100));
      }
    }
    return null;
  }

  Future<vm.Response?> reassemble() async {
    final reassembleMethod = _registeredMethodsForService['ext.jaspr.reassemble'] ?? 'ext.jaspr.reassemble';
    for (var i = 0; i < 5; i++) {
      try {
        final response = await vmService?.callServiceExtension(reassembleMethod);
        if (response != null) return response;
      } catch (_) {
        await Future.pause(const Duration(milliseconds: 100));
      }
    }
    return null;
  }

  Future<vm.Response?> reloadHtml([String? path]) async {
    final reloadMethod = _registeredMethodsForService['ext.jaspr.reload_html'] ?? 'ext.jaspr.reload_html';
    final args = path != null ? {'path': path} : <String, String>{};
    for (var i = 0; i < 5; i++) {
      try {
        final response = await vmService?.callServiceExtension(reloadMethod, args: args);
        if (response != null) return response;
      } catch (_) {
        await Future.pause(const Duration(milliseconds: 100));
      }
    }
    return null;
  }

  Future<vm.Response?> refreshPage() async {
    final reloadMethod =
        _registeredMethodsForService['fullReload'] ?? _registeredMethodsForService['ext.dwds.reload'] ?? 'fullReload';
    try {
      final response = await vmService?.callServiceExtension(reloadMethod);
      return response;
    } catch (_) {
      return null;
    }
  }

  int? _buildProgressEventId;
  var _progressEventId = 0;

  Future<void> _handleBuildResult(BuildResult result, String appId) async {
    switch (result.status) {
      case BuildStatus.started:
        _buildProgressEventId = _progressEventId++;
        sendEvent('client.progress', {'appId': appId, 'id': '$_buildProgressEventId', 'message': 'Building...'});
      case BuildStatus.failed:
        sendEvent('client.progress', {'appId': appId, 'id': '$_buildProgressEventId', 'finished': true});
      case BuildStatus.succeeded:
        sendEvent('client.progress', {'appId': appId, 'id': '$_buildProgressEventId', 'finished': true});
    }
  }

  Future<void> stop() async {
    _debugConnection?.close();
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    devToolsUri = null;

    _stdOutSub?.cancel();
    _resultSub?.cancel();
    _vmServiceSub?.cancel();
    _vmServiceClient?.dispose();
    _vmServiceClient = null;
    _debugConnection?.close();
  }
}
