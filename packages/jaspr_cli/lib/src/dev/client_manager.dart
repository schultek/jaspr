import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dwds/data/build_result.dart';
import 'package:dwds/dwds.dart';
import 'package:meta/meta.dart';
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

import '../logging.dart';
import '../project.dart';
import 'client_call_guard.dart';
import 'dev_workflow.dart';

class ClientManager {
  ClientManager(this.workflow);

  final DevWorkflow workflow;
  final Map<String, ClientConnection> _clientConnections = {};
  final StreamController<Map<String, Object?>> _clientEvents = StreamController.broadcast();

  /// How long to wait for a single client call before skipping the client.
  ///
  /// Only applies to clients that connect after it is changed.
  @visibleForTesting
  Duration callTimeout = const Duration(seconds: 10);

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

/// An update the dev workflow applies to the connected clients.
///
/// The values are ordered by how much of the page they replace,
/// so a later update includes the ones before it.
enum ClientUpdate {
  /// A hot reload, which keeps the state of the app.
  reload,

  /// A hot restart, which runs the app from the start.
  restart,

  /// A full reload of the page.
  refresh,
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

  late final _callGuard = ClientCallGuard(
    timeout: manager.callTimeout,
    onUnresponsive: () => manager.workflow.logger.write(
      'Client ${appConnection.request.appId} did not respond, skipping it until it responds again.',
      tag: .client,
      level: .warning,
    ),
    onResponsive: () => unawaited(_catchUp()),
  );

  /// The update this client missed while it didn't respond.
  ClientUpdate? _missedUpdate;

  /// Whether this client is applying what it missed while it didn't respond.
  bool _isCatchingUp = false;

  /// Whether updates skip this client because it doesn't have the previous ones yet.
  bool get _isBehind => _callGuard.isUnresponsive || _isCatchingUp;

  /// Stylesheets that changed while this client didn't receive them.
  final Set<String> _pendingStylesheets = {};

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

  /// Applies [update] to this client and returns whether it succeeded.
  ///
  /// A client that doesn't respond in time is skipped,
  /// and catches up on [update] once it responds again.
  Future<bool> update(ClientUpdate update) async {
    if (_isBehind) {
      _markMissed(update);
      return false;
    }

    // Include an update that the catch-up couldn't apply.
    _markMissed(update);
    final pending = _missedUpdate!;
    _missedUpdate = null;

    final succeeded = await _apply(pending, _callGuard.run);
    // A refresh that timed out still reloads the page once it gets through,
    // so there is nothing left to catch up on.
    if (_callGuard.isUnresponsive && pending != .refresh) {
      _markMissed(pending);
    }
    return succeeded;
  }

  void _markMissed(ClientUpdate update) {
    final missed = _missedUpdate;
    if (missed == null || update.index > missed.index) {
      _missedUpdate = update;
    }
  }

  /// Applies what this client missed while it didn't respond.
  ///
  /// The calls aren't limited by a timeout. A client that responds slowly,
  /// such as a background tab throttled by the browser, would otherwise time
  /// out again and never get up to date. Updates that arrive in the meantime
  /// skip this client and are applied afterwards, so nothing waits for it.
  Future<void> _catchUp() async {
    final appId = appConnection.request.appId;
    final logger = manager.workflow.logger;
    logger.write(
      switch (_missedUpdate) {
        final update? => 'Client $appId is responding again, catching up on the missed ${update.name}.',
        null => 'Client $appId is responding again.',
      },
      tag: .client,
    );
    if (_isCatchingUp) return;

    _isCatchingUp = true;
    ClientUpdate? update;
    try {
      while (!_isDisposed) {
        update = _missedUpdate;
        if (update != null) {
          _missedUpdate = null;
          if (!await _apply(update, _unguarded)) break;
          update = null;
          continue;
        }

        // Changed stylesheets aren't part of an update, so deliver them afterwards.
        final stylesheets = _pendingStylesheets.toList();
        if (stylesheets.isEmpty) break;
        _pendingStylesheets.clear();
        if (await _reloadStylesheets(stylesheets) == null) {
          // Keep them for the next stylesheet reload instead of retrying forever.
          _pendingStylesheets.addAll(stylesheets);
          break;
        }
      }
    } catch (error, stackTrace) {
      logger.write('Catching up failed for client $appId: $error', tag: .client, level: .warning);
      logger.write(stackTrace.toString(), tag: .client, level: .verbose);
    } finally {
      // An update that couldn't be applied stays missed and is included in the
      // next update, instead of being retried forever.
      if (update != null) {
        _markMissed(update);
      }
      _isCatchingUp = false;
    }
  }

  static Future<T?> _unguarded<T>(Future<T?> Function() call) => call();

  /// Runs the calls of [update] through [run] and returns whether it succeeded.
  Future<bool> _apply(ClientUpdate update, Future<T?> Function<T>(Future<T?> Function() call) run) async {
    switch (update) {
      case ClientUpdate.reload:
        if (await run(_performHotReload) != true) {
          // Skip reassemble and html reload if client hot-reload fails.
          return false;
        }
        await run(_reassemble);
      case ClientUpdate.restart:
        if (await run(_restart) == null) {
          // Skip html reload if client restart fails.
          return false;
        }
      case ClientUpdate.refresh:
        return await run(_refreshPage) != null;
    }
    if (manager.workflow.project.requireMode != JasprMode.client) {
      await run(_reloadHtml);
    }
    return true;
  }

  Future<vm.Response?> restart() => _callGuard.run(_restart);

  Future<vm.Response?> _restart() async {
    final restartMethod = _registeredMethodsForService['hotRestart'] ?? 'hotRestart';
    final response = await vmService?.callServiceExtension(restartMethod);
    return response;
  }

  /// Performs a hot reload and returns whether it succeeded.
  Future<bool> _performHotReload() async {
    final vmService = this.vmService;
    if (vmService == null) {
      manager.workflow.logger.write(
        'Tried to perform hot reload before debug connection is ready.',
        tag: Tag.client,
        level: Level.warning,
      );
      return false;
    }

    final isolateId = (await vmService.getVM()).isolates?.firstOrNull?.id;
    if (isolateId == null) {
      manager.workflow.logger.write(
        'Tried to perform hot reload but no isolate was found.',
        tag: Tag.client,
        level: Level.warning,
      );
      return false;
    }

    vm.ReloadReport? response;
    for (var i = 0; i < 5; i++) {
      response = await vmService.reloadSources(isolateId);
      if (response.success ?? false) {
        return true;
      }
    }
    manager.workflow.logger.write(
      'Hot reload failed after 5 attempts for unknown reason.',
      tag: Tag.client,
      level: Level.warning,
    );
    return false;
  }

  /// Reloads the stylesheets at [urls], together with any stylesheets this client missed before.
  Future<vm.Response?> reloadStylesheets(List<String> urls) async {
    _pendingStylesheets.addAll(urls);
    // Delivered at the end of the catch-up.
    if (_isCatchingUp) return null;

    final pending = _pendingStylesheets.toList();
    final response = await _callGuard.run(() => _reloadStylesheets(pending));
    if (response != null) {
      _pendingStylesheets.removeAll(pending);
    }
    return response;
  }

  Future<vm.Response?> _reloadStylesheets(List<String> urls) async {
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

  Future<vm.Response?> reassemble() => _callGuard.run(_reassemble);

  Future<vm.Response?> _reassemble() async {
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

  Future<vm.Response?> reloadHtml([String? path]) => _callGuard.run(() => _reloadHtml(path));

  Future<vm.Response?> _reloadHtml([String? path]) async {
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

  Future<vm.Response?> _refreshPage() async {
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
