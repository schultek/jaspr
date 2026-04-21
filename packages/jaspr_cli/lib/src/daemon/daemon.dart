// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'domain.dart';

/// A collection of domains.
///
/// Listens for commands, routes them to the corresponding domain and provides
/// the result.
class Daemon {
  Daemon(
    Stream<Map<String, dynamic>> commandStream,
    this._sendCommand,
  ) {
    _commandSubscription = commandStream.listen(
      _handleRequest,
      onDone: () {
        if (!_onExitCompleter.isCompleted) _onExitCompleter.complete(0);
      },
    );
  }

  late StreamSubscription<Map<String, dynamic>> _commandSubscription;

  final void Function(Map<String, dynamic>) _sendCommand;

  final Completer<int> _onExitCompleter = Completer<int>();
  final Map<String, Domain> _domainMap = <String, Domain>{};

  void registerDomain(Domain domain) {
    if (_domainMap.containsKey(domain.name)) {
      throw StateError('${domain.name} already registered.');
    }
    _domainMap[domain.name] = domain;
  }

  Future<int> get onExit => _onExitCompleter.future;

  void _handleRequest(Map<String, dynamic> request) {
    // {id, method, params}

    // [id] is an opaque type to us.
    final id = request['id'];

    if (id == null) {
      stderr.writeln('no id for request: $request');
      return;
    }

    try {
      final method = request['method'] as String? ?? '';
      if (!method.contains('.')) {
        throw ArgumentError('method not understood: $method');
      }

      final domain = method.substring(0, method.indexOf('.'));
      final name = method.substring(method.indexOf('.') + 1);
      final domainValue = _domainMap[domain];
      if (domainValue == null) {
        throw ArgumentError('no domain for method: $method');
      }

      domainValue.handleCommand(name, id, request['params'] as Map<String, dynamic>? ?? {});
    } catch (error, trace) {
      send(<String, dynamic>{
        'id': id,
        'error': toJsonable(error),
        'trace': '$trace',
      });
    }
  }

  void send(Map<String, dynamic> map) => _sendCommand(map);

  void shutdown({Object? error}) {
    _commandSubscription.cancel();
    for (final domain in _domainMap.values) {
      domain.dispose();
    }
    if (!_onExitCompleter.isCompleted) {
      if (error == null) {
        _onExitCompleter.complete(0);
      } else {
        _onExitCompleter.completeError(error);
      }
    }
  }
}

/// Converts an object to a JSONable value.
dynamic toJsonable(dynamic obj) {
  if (obj is String ||
      obj is int ||
      obj is bool ||
      obj is Map<dynamic, dynamic> ||
      obj is List<dynamic> ||
      obj == null) {
    return obj;
  }
  return '$obj';
}
