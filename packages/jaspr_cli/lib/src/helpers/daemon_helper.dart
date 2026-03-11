import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ignore: implementation_imports
import 'package:webdev/src/daemon/daemon.dart';
// ignore: implementation_imports
import 'package:webdev/src/daemon/daemon_domain.dart';

import '../commands/base_command.dart';
import '../logging.dart';

// ignore: implementation_imports
export 'package:webdev/src/daemon/daemon.dart' show Daemon;
// ignore: implementation_imports
export 'package:webdev/src/daemon/domain.dart' show Domain;

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

class DaemonLogger extends Logger {
  DaemonLogger({this.sendEvent}) : super.base(verbose: true);

  static Stream<Map<String, Object?>> get stdinCommandStream => stdin
      .transform<String>(utf8.decoder)
      .transform<String>(const LineSplitter())
      .where((String line) => line.startsWith('[{') && line.endsWith('}]'))
      .map<Map<String, Object?>>((String line) {
        line = line.substring(1, line.length - 1);
        return json.decode(line) as Map<String, Object?>;
      });

  static void stdoutCommandResponse(Map<String, Object?> command) {
    stdout.writeln('[${json.encode(command)}]');
  }

  void Function(Map<String, Object?>)? sendEvent;

  @override
  void writeLine(String message, {Tag? tag, Level level = Level.info, ProgressState? progress}) {
    if (tag == Tag.server) {
      const vmUriPrefix = 'The Dart VM service is listening on ';
      if (message.startsWith(vmUriPrefix)) {
        final uri = message.substring(vmUriPrefix.length);
        event('server.started', {'vmServiceUri': uri});
        return;
      }

      event('server.log', {'message': message, 'level': level.name});

      if (level.index < Level.error.index) {
        return;
      }
    }

    final String logmessage = '${tag?.format(true) ?? ''}${level.format(message.trim(), true)}';

    log({'message': logmessage});
  }

  @override
  void complete(bool success) {}

  void log(Map<String, Object?> data) {
    event('daemon.log', data);
  }

  void event(String eventName, Map<String, Object?> params) {
    final event = {'event': eventName, 'params': params};
    if (sendEvent != null) {
      sendEvent!(event);
    } else {
      stdout.writeln('[${jsonEncode(event)}]');
    }
  }
}
