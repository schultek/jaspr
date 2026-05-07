// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'dart:async';

import '../daemon/daemon.dart';
import '../daemon/domain.dart';
import 'dev_proxy.dart';
import 'util.dart';

/// A collection of method and events relevant to the running application.
class ClientDomain extends Domain {
  ClientDomain(Daemon daemon, this.devProxy) : super(daemon, 'client') {
    registerHandler('restart', _restart);
    registerHandler('callServiceExtension', _callServiceExtension);
    registerHandler('stop', _stop);

    _handleAppConnections();
  }

  final DevProxy devProxy;

  StreamSubscription<dynamic>? _clientEventSubscription;

  Future<void> _handleAppConnections() async {
    _clientEventSubscription = devProxy.clientEvents.listen((event) {
      sendEvent(event['method'] as String, event['params']);
    });
  }

  Future<Map<String, Object?>?> _callServiceExtension(Map<String, Object?> args) async {
    final appId = getStringArg(args, 'appId', required: true);
    final appState = devProxy.getClientConnection(appId);
    if (appState == null) {
      throw ArgumentError.value(appId, 'appId', 'Not found');
    }
    final methodName = getStringArg(args, 'methodName', required: true)!;
    final params = args['params'] != null ? (args['params'] as Map<String, Object?>) : <String, Object?>{};
    final response = await appState.vmService?.callServiceExtension(methodName, args: params);
    return response?.json;
  }

  Future<Map<String, Object?>> _restart(Map<String, Object?> args) async {
    final appId = getStringArg(args, 'appId', required: true);
    final appState = devProxy.getClientConnection(appId);
    if (appState == null) {
      throw ArgumentError.value(appId, 'appId', 'Not found');
    }
    final fullRestart = getBoolArg(args, 'fullRestart') ?? false;
    if (!fullRestart) {
      return {'code': 1, 'message': 'hot reload not yet supported by webdev'};
    }
    // TODO(grouma) - Support pauseAfterRestart.
    // var pauseAfterRestart = getBoolArg(args, 'pause') ?? false;
    final stopwatch = Stopwatch()..start();

    sendEvent('app.progress', {
      'appId': appId,
      'id': '0',
      'message': 'Performing hot restart...',
      'progressId': 'hot.restart',
    });
    final response = await appState.restart();
    sendEvent('app.progress', {
      'appId': appId,
      'id': '0',
      'finished': true,
      'progressId': 'hot.restart',
    });
    sendEvent('app.log', {'appId': appId, 'log': 'Restarted application in ${stopwatch.elapsedMilliseconds}ms'});
    return {'code': response?.type == 'Success' ? 0 : 1, 'message': response.toString()};
  }

  Future<bool> _stop(Map<String, Object?> args) async {
    final appId = getStringArg(args, 'appId', required: true);
    final appState = devProxy.getClientConnection(appId);
    if (appState == null) {
      throw ArgumentError.value(appId, 'appId', 'Not found');
    }
    await appState.stop();
    return true;
  }

  @override
  void dispose() {
    _clientEventSubscription?.cancel();
  }
}
