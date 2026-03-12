import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../daemon/logger.dart';
import '../domains/html_domain.dart';
import '../domains/scopes_domain.dart';
import '../helpers/daemon_helper.dart';
import '../helpers/settings_helper.dart';
import 'base_command.dart';

class ToolingDaemonCommand extends BaseCommand with DaemonHelper {
  ToolingDaemonCommand() : super(logger: DaemonLogger()) {
    argParser.addCommand('start');
    argParser.addCommand(
      'convert-html',
      ArgParser()
        ..addOption('file')
        ..addOption('url')
        ..addOption('query'),
    );
  }

  @override
  String get description => 'Start the Jaspr tooling daemon in the background.';

  @override
  String get name => 'tooling-daemon';

  @override
  String get category => 'Tooling';

  @override
  bool get hidden => true;

  @override
  bool get verbose => true;

  @override
  Future<int> runCommand() async {
    final command = argResults?.command?.name;

    if (command == 'convert-html') {
      final file = argResults?.command?.option('file');
      final url = argResults?.command?.option('url');
      final query = argResults?.command?.option('query');

      Map<String, Object?> params;
      if (file != null && url == null) {
        final html = File(file).readAsStringSync();
        params = {
          'html': html,
          'query': ?query,
        };
      } else if (file == null && url != null) {
        final response = await http.get(Uri.parse(url));
        params = {
          'html': response.body,
          'query': ?query,
        };
      } else {
        stderr.writeln('Either --file or --url must be provided.');
        return 1;
      }

      return runToolingDaemonCommand('html.convert', params, (response) {
        return response.toString();
      });
    }

    if (command == 'start') {
      return runWithWebSocketDaemon(
        (daemon) async {
          daemon.registerDomain(ScopesDomain(daemon, logger));
          daemon.registerDomain(HtmlDomain(daemon, logger));
        },
        port: 0,
        onStarted: (port) {
          final lockFile = _getLockFile();
          lockFile.writeAsStringSync(jsonEncode({'pid': pid, 'port': port}));
          guardResource(() {
            if (lockFile.existsSync()) {
              lockFile.deleteSync();
            }
          });
        },
        onLog: toolingDaemonDebugLog,
      );
    }

    final runningPort = await findOrStartDaemon();
    if (runningPort == null) {
      stdout.writeln(
        jsonEncode([
          {'status': 'error', 'message': 'Failed to start tooling daemon.'},
        ]),
      );
      return 1;
    } else {
      stdout.writeln(
        jsonEncode([
          {'status': 'running', 'port': runningPort},
        ]),
      );
      return 0;
    }
  }

  Future<int?> findOrStartDaemon() async {
    var runningPort = await findRunningDaemon();
    if (runningPort != null) {
      return runningPort;
    }

    final args = Platform.resolvedExecutable.endsWith('/dart')
        ? [...Platform.executableArguments, Platform.script.path, 'tooling-daemon', 'start']
        : ['tooling-daemon', 'start'];

    await Process.start(
      Platform.resolvedExecutable,
      args,
      mode: ProcessStartMode.detached,
    );

    final sw = Stopwatch()..start();
    while (sw.elapsed < const Duration(seconds: 2)) {
      runningPort = await findRunningDaemon();
      if (runningPort != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    return runningPort;
  }

  Future<int?> findRunningDaemon() async {
    final lockFile = _getLockFile();
    if (!lockFile.existsSync()) return null;
    try {
      final data = jsonDecode(lockFile.readAsStringSync());
      if (data case {'pid': final int pid, 'port': final int port}) {
        try {
          final response = await sendSingleCommandToDaemon(port, 'daemon.version', {});
          if (response != null) return port;
        } catch (_) {}

        // If we are here, either the process is dead or the WebSocket is not responding.
        // Try to kill the process just in case it's hanging.
        try {
          Process.killPid(pid);
        } catch (_) {}
      }
    } catch (_) {}

    try {
      lockFile.deleteSync();
    } catch (_) {}

    return null;
  }

  File _getLockFile() {
    final settingsDir = getSettingsDirectory();
    return File(path.join(settingsDir.path, 'tooling-daemon.json'));
  }

  Future<int> runToolingDaemonCommand(
    String method,
    Map<String, Object?> params,
    String Function(Object) resultBuilder,
  ) async {
    final runningPort = await findOrStartDaemon();
    if (runningPort == null) {
      stderr.writeln('Failed to start tooling daemon. Please try again.');
      return 1;
    }

    try {
      final response = await sendSingleCommandToDaemon(runningPort, method, params);
      if (response != null) {
        stdout.writeln(resultBuilder(response));
        return 0;
      } else {
        stderr.writeln('Failed to get result from tooling daemon.');
        return 1;
      }
    } catch (e) {
      stderr.writeln('Failed to get result from tooling daemon: $e');
      return 1;
    }
  }

  Future<Object?> sendSingleCommandToDaemon(
    int daemonPort,
    String method,
    Map<String, Object?> params, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:$daemonPort'));
    final id = Random().nextInt(10000);

    channel.sink.add(
      jsonEncode([
        {'id': id, 'method': method, 'params': params},
      ]),
    );

    final response = await channel.stream
        .map((msg) => msg is String ? jsonDecode(msg) : null)
        .map((data) {
          if (data case [{'id': final int msgId, 'result': final result}] when msgId == id) return result;
          return null;
        })
        .where((data) => data != null)
        .firstOrNull
        .timeout(timeout);

    await channel.sink.close();
    return response;
  }
}

final _logFile = File(path.join(getSettingsDirectory().path, 'tooling-daemon-debug.log'))..writeAsStringSync('');
void toolingDaemonDebugLog(String message) {
  _logFile.writeAsStringSync('$message\n', mode: FileMode.append, flush: true);
}
