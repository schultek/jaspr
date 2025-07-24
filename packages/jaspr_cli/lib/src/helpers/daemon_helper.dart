import 'dart:convert';
import 'dart:io';

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
}

class DaemonLogger implements Logger {
  DaemonLogger();

  static Stream<Map<String, dynamic>> get stdinCommandStream => stdin
          .transform<String>(utf8.decoder)
          .transform<String>(const LineSplitter())
          .where((String line) => line.startsWith('[{') && line.endsWith('}]'))
          .map<Map<String, dynamic>>((String line) {
        line = line.substring(1, line.length - 1);
        return json.decode(line) as Map<String, dynamic>;
      });

  static void stdoutCommandResponse(Map<String, dynamic> command) {
    stdout.writeln('[${json.encode(command)}]');
  }

  @override
  MasonLogger? get logger => null;

  final MasonLogger _logger = MasonLogger();

  @override
  bool get verbose => true;

  @override
  void write(String message, {Tag? tag, Level level = Level.info, ProgressState? progress}) {
    message = message.trim();
    if (message.contains('\n')) {
      var lines = message.split('\n');
      for (var l in lines) {
        write(l, tag: tag, level: level, progress: progress);
      }
      return;
    }

    if (tag == Tag.server) {
      const vmUriPrefix = "The Dart VM service is listening on ";
      if (message.startsWith(vmUriPrefix)) {
        final uri = message.substring(vmUriPrefix.length);
        event("server.started", {
          "vmServiceUri": uri,
        });
        return;
      }

      event("server.log", {
        'message': message,
        'level': level.name,
      });

      if (level.index < Level.error.index) {
        return;
      }
    }

    String logmessage = '${tag?.format(true) ?? ''}${level.format(message.trim(), true)}';

    log({'message': logmessage});
  }

  @override
  void complete(bool success) {}

  void log(Map<String, dynamic> data) {
    event('daemon.log', data);
  }

  void event(String event, Map<String, dynamic> params) {
    _logger.write('[${jsonEncode({'event': event, 'params': params})}]\n');
  }
}
