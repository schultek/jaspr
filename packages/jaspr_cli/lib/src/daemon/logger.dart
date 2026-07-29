import 'dart:convert';
import 'dart:io';

import '../logging.dart';

class DaemonLogger extends Logger {
  DaemonLogger() : super.base(verbose: true);

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

  @override
  void write(String message, {Tag? tag, Level level = Level.info, ProgressState? progress}) {
    if (message.trim().isEmpty) {
      return;
    }
    if (tag == Tag.server) {
      const vmUriPrefix = 'The Dart VM service is listening on ';
      if (message.startsWith(vmUriPrefix)) {
        final uri = message.substring(vmUriPrefix.length);
        event('server.started', {'vmServiceUri': uri});
        return;
      }
    }

    final suffix = progress == ProgressState.running && !message.endsWith('...') ? '...' : '';

    final (content, _) = Logger.formatMessage(message.trimRight() + suffix, tag, level, verbose: verbose, daemon: true);
    log({'message': content});
  }

  @override
  void complete(bool success) {}

  @override
  void clearFooter() {}

  @override
  void setFooter(List<String> lines) {}

  @override
  Future<String> prompt(String message, {String? defaultValue}) async => defaultValue ?? '';

  @override
  Future<bool> confirm(String message, {bool defaultValue = false, String? hint}) async => defaultValue;

  @override
  Future<T> chooseOne<T>(String message, {required List<T> choices, String Function(T)? display}) async =>
      choices.first;

  void log(Map<String, Object?> data) {
    event('daemon.log', data);
  }

  void event(String event, Map<String, Object?> params) {
    stdout.writeln('[${jsonEncode({'event': event, 'params': params})}]');
  }
}
