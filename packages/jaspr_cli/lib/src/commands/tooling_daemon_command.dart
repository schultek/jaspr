import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
    argParser.addFlag('start', hide: true);
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
    if (argResults!.flag('start')) {
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

    var runningPort = await findRunningDaemon();
    if (runningPort != null) {
      stdout.writeln(
        jsonEncode([
          {'status': 'running', 'port': runningPort},
        ]),
      );
      return 0;
    }

    final args = Platform.resolvedExecutable.endsWith('/dart')
        ? [...Platform.executableArguments, Platform.script.path, 'tooling-daemon', '--start']
        : ['tooling-daemon', '--start'];

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

  Future<int?> findRunningDaemon() async {
    final lockFile = _getLockFile();
    if (!lockFile.existsSync()) return null;
    try {
      final data = jsonDecode(lockFile.readAsStringSync());
      if (data case {'pid': final int pid, 'port': final int port}) {
        try {
          final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:$port'));
          final completer = Completer<bool>();
          final id = Random().nextInt(10000);

          channel.sink.add(
            jsonEncode([
              {'id': id, 'method': 'daemon.version'},
            ]),
          );

          final sub = channel.stream
              .map((msg) => msg is String ? jsonDecode(msg) : null)
              .where((data) {
                if (data case [{'id': final int msgId}] when msgId == id) return true;
                return false;
              })
              .listen((data) => completer.complete(true), onError: (e) => completer.complete(false));

          final success = await completer.future.timeout(const Duration(seconds: 2), onTimeout: () => false);
          await sub.cancel();
          await channel.sink.close();

          if (success == true) {
            return port;
          }
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
}

final _logFile = File(path.join(getSettingsDirectory().path, 'tooling-daemon-debug.log'))..writeAsStringSync('');
void toolingDaemonDebugLog(String message) {
  _logFile.writeAsStringSync('$message\n', mode: FileMode.append, flush: true);
}
