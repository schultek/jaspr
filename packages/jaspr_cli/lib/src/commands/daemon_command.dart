import 'dart:convert';
import 'dart:io';

// ignore: implementation_imports
import 'package:webdev/src/daemon/daemon.dart';
// ignore: implementation_imports
import 'package:webdev/src/daemon/daemon_domain.dart';

import '../dev/client_domain.dart';
import '../dev/client_workflow.dart';
import '../logging.dart';
import 'dev_command.dart';

class DaemonCommand extends DevCommand {
  DaemonCommand() : super(logger: DaemonLogger());

  @override
  String get description => 'Runs a daemon server.';

  @override
  String get name => 'daemon';

  @override
  bool get hidden => true;

  @override
  final bool launchInChrome = true;
  @override
  final bool autoRun = false;

  late Daemon daemon;

  @override
  Future<int> runCommand() async {
    daemon = Daemon(_stdinCommandStream, _stdoutCommandResponse);
    guardResource(() {
      daemon.shutdown();
    });

    final daemonDomain = DaemonDomain(daemon);
    daemon.registerDomain(daemonDomain);

    final resultFuture = super.runCommand();

    await daemon.onExit;
    await stop();

    return await resultFuture;
  }

  @override
  void handleClientWorkflow(ClientWorkflow workflow) {
    daemon.registerDomain(ClientDomain(daemon, workflow.serverManager));
  }
}

Stream<Map<String, dynamic>> get _stdinCommandStream => stdin
        .transform<String>(utf8.decoder)
        .transform<String>(const LineSplitter())
        .where((String line) => line.startsWith('[{') && line.endsWith('}]'))
        .map<Map<String, dynamic>>((String line) {
      line = line.substring(1, line.length - 1);
      return json.decode(line) as Map<String, dynamic>;
    });

void _stdoutCommandResponse(Map<String, dynamic> command) {
  stdout.writeln('[${json.encode(command)}]');
}

class DaemonLogger implements Logger {
  DaemonLogger();

  @override
  MasonLogger? get logger => null;

  final MasonLogger _logger = MasonLogger();

  @override
  bool get verbose => true;

  @override
  void write(String message, {Tag? tag = Tag.cli, Level level = Level.info, ProgressState? progress}) {
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
