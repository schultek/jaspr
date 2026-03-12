import 'dart:convert';
import 'dart:io';

import '../logging.dart';

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
