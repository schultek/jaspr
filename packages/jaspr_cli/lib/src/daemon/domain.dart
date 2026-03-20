// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'daemon.dart';

/// Hosts a set of commands and events to be used with the Daemon.
abstract class Domain {
  Domain(this.daemon, this.name);

  final Daemon daemon;
  final String name;
  final Map<String, CommandHandler> _handlers = <String, CommandHandler>{};

  void registerHandler(String name, CommandHandler handler) {
    _handlers[name] = handler;
  }

  @override
  String toString() => name;

  void handleCommand(String command, dynamic id, Map<String, dynamic> args, int? clientId) {
    Future<dynamic>.sync(() {
          if (_handlers.containsKey(command)) return _handlers[command]!(args, clientId);
          throw ArgumentError('command not understood: $name.$command');
        })
        .then<dynamic>((dynamic result) {
          if (result == null) {
            _send(<String, dynamic>{'id': id, 'clientId': ?clientId});
          } else {
            _send(<String, dynamic>{'id': id, 'clientId': ?clientId, 'result': toJsonable(result)});
          }
        })
        .catchError((dynamic error, dynamic trace) {
          _send(<String, dynamic>{
            'id': id,
            'clientId': ?clientId,
            'error': toJsonable(error),
            'trace': '$trace',
          });
        });
  }

  void sendEvent(String name, [dynamic args, int? clientId]) {
    final map = <String, dynamic>{'event': name, 'clientId': ?clientId};
    if (args != null) map['params'] = toJsonable(args);
    _send(map);
  }

  void _send(Map<String, dynamic> map) => daemon.send(map);

  void handleClientDisconnect(int clientId) {}

  void dispose() {}
}

typedef CommandHandler = Future<dynamic> Function(Map<String, dynamic> args, int? clientId);
