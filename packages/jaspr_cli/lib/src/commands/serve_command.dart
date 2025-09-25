// ignore: implementation_imports
import 'dart:async';

// ignore: implementation_imports
import 'package:webdev/src/daemon/daemon.dart';

import '../dev/client_domain.dart';
import '../dev/client_workflow.dart';
import '../logging.dart';
import 'dev_command.dart';

class ServeCommand extends DevCommand {
  ServeCommand({super.logger}) {
    argParser.addFlag(
      'launch-in-chrome',
      help: 'Automatically launches your application in Chrome with the debug port open.',
      negatable: false,
    );
  }

  @override
  String get description => 'Runs a development server that reloads based on file system updates.';

  @override
  String get name => 'serve';

  @override
  late final bool launchInChrome = argResults?['launch-in-chrome'] as bool? ?? false;
  @override
  final bool autoRun = true;

  late Daemon daemon;

  @override
  Future<int> runCommand() async {
    var fakeInput = StreamController<Map<String, dynamic>>();
    daemon = Daemon(fakeInput.stream, (data) {
      //print(data);
      if (data['event'] == 'client.debugPort') {
        final wsUri = data['params']['wsUri'] as String;
        logger.write(
          'The Dart VM service is listening on http${wsUri.substring(2, wsUri.length - 2)}',
          tag: Tag.client,
        );
      }
      if (data['event'] == 'client.log') {
        logger.write(data['params']['log'], tag: Tag.client);
      }
    });
    guardResource(() {
      daemon.shutdown();
    });

    final resultFuture = super.runCommand();

    await daemon.onExit;
    await stop();

    return await resultFuture;
  }

  @override
  void handleClientWorkflow(ClientWorkflow workflow) {
    if (launchInChrome) {
      daemon.registerDomain(ClientDomain(daemon, workflow.serverManager));
    }
  }
}
