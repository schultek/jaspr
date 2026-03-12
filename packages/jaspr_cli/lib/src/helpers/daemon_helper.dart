import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../commands/base_command.dart';
import '../daemon/daemon.dart';
import '../daemon/daemon_domain.dart';
import '../daemon/logger.dart';

mixin DaemonHelper on BaseCommand {
  late Daemon daemon;

  Future<int> runWithDaemon(Future<int> Function(Daemon daemon) callback) async {
    daemon = Daemon(DaemonLogger.stdinCommandStream, DaemonLogger.stdoutCommandResponse);
    guardResource(() {
      daemon.shutdown();
    });

    final daemonDomain = DaemonDomain(daemon);
    daemon.registerDomain(daemonDomain);

    final resultFuture = callback(daemon);

    await daemon.onExit;
    await stop();

    return await resultFuture;
  }

  Future<int> runWithWebSocketDaemon(
    Future<void> Function(Daemon daemon) callback, {
    required int port,
    void Function(int port)? onStarted,
    void Function(String message)? onLog,
  }) async {
    final commandStreamController = StreamController<Map<String, Object?>>();
    final channels = <int, WebSocketChannel>{};
    int clientCounter = 0;

    void sendToClient(WebSocketChannel channel, Map<String, Object?> command) {
      channel.sink.add('[${jsonEncode(command)}]');
    }

    void broadcast(Map<String, Object?> command) {
      for (final channel in channels.values) {
        sendToClient(channel, command);
      }
    }

    void handleResponse(Map<String, Object?> command) {
      if (command['id'] case final String id when id.contains(':')) {
        final parts = id.split(':');
        final clientId = int.tryParse(parts[0]);
        if (clientId != null && channels.containsKey(clientId)) {
          final originalIdStr = id.substring(parts[0].length + 1);
          final Object originalId = int.tryParse(originalIdStr) ?? originalIdStr;

          final newCommand = Map<String, Object?>.from(command);
          newCommand['id'] = originalId;

          sendToClient(channels[clientId]!, newCommand);
        } else {
          broadcast(command);
        }
      } else if (command['params'] case <String, dynamic>{
        '__clientId': final int clientId,
      } when channels.containsKey(clientId)) {
        sendToClient(channels[clientId]!, {
          ...command,
          'params': Map<String, Object?>.from(command['params'] as Map)..remove('__clientId'),
        });
      } else {
        broadcast(command);
      }
    }

    if (logger is DaemonLogger) {
      (logger as DaemonLogger).sendEvent = broadcast;
    }

    daemon = Daemon(commandStreamController.stream, handleResponse);
    guardResource(() {
      daemon.shutdown();
    });

    final daemonDomain = DaemonDomain(daemon);
    daemon.registerDomain(daemonDomain);

    await callback(daemon);

    final handler = webSocketHandler((WebSocketChannel webSocket) {
      final clientId = ++clientCounter;
      channels[clientId] = webSocket;

      onLog?.call('Client connected: $clientId (total active ${channels.length})');

      final onDone = Completer<void>();

      webSocket.stream.listen(
        (message) {
          if (message is String) {
            try {
              var data = jsonDecode(message);
              if (data is List && data.isNotEmpty) {
                data = data.first;
              }
              if (data is Map<String, Object?>) {
                if (data.containsKey('id')) {
                  final originalId = data['id'];
                  data['id'] = '$clientId:$originalId';
                }
                final params = (data['params'] ??= <String, Object?>{}) as Map<String, Object?>;
                params['__clientId'] = clientId;
                params['__clientOnDone'] = onDone.future;
                commandStreamController.add(data);
              }
            } catch (_) {}
          }
        },
        onDone: () {
          onDone.complete();
          channels.remove(clientId);

          onLog?.call('Client disconnected: $clientId (total active ${channels.length})');
        },
      );
    });

    final server = await shelf_io.serve(handler, 'localhost', port);
    onStarted?.call(server.port);

    guardResource(() async {
      await server.close(force: true);
    });

    // Keep the daemon running indefinitely
    await daemon.onExit;
    await stop();

    return 0;
  }
}
