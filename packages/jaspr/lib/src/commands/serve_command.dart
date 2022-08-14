import 'dart:async';
import 'dart:io';

import 'command.dart';

class ServeCommand extends BaseCommand {
  ServeCommand() {
    argParser.addOption(
      'input',
      abbr: 'i',
      help: 'Specify the input file for the web app.',
    );
    argParser.addOption(
      'mode',
      abbr: 'm',
      help: 'Sets the reload/refresh mode.',
      allowed: ['reload', 'refresh'],
      allowedHelp: {
        'reload': 'Reloads js modules without server reload (loses current state)',
        'refresh': 'Performs a full page refresh and server reload',
      },
      defaultsTo: 'refresh',
    );
    argParser.addOption(
      'port',
      abbr: 'p',
      help: 'Specify a port to run the dev server on.',
      defaultsTo: '8080',
    );
    argParser.addFlag(
      'ssr',
      defaultsTo: true,
      help: 'Optionally disables server-side rendering and runs as a pure client-side app.',
    );
    argParser.addFlag(
      'debug',
      abbr: 'd',
      help: 'Serves the app in debug mode.',
    );
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Enable verbose logging.',
    );
  }

  @override
  String get description => 'Runs a development server that serves the web app with SSR and '
      'reloads based on file system updates.';

  @override
  String get name => 'serve';

  @override
  Future<void> run() async {
    await super.run();

    var useSSR = argResults!['ssr'] as bool;
    var debug = argResults!['debug'];

    var webProcess = await runWebdev([
      'serve',
      '--auto=${argResults!['mode'] == 'reload' ? 'restart' : 'refresh'}',
      'web:${useSSR ? '5467' : argResults!['port']}',
      '--',
      '--delete-conflicting-outputs',
      '--define=build_web_compilers:ddc=environment={"jaspr.web.debug":$debug}'
    ]);

    if (!useSSR) {
      return watchProcess(webProcess);
    }

    print("Starting jaspr development server...");

    var buildCompleted = StreamController<int>.broadcast();
    var build = 0;

    checkWebdevStarted(String str) {
      if (str.contains('Running build completed')) {
        buildCompleted.add(build++);
      }
    }

    var verbose = argResults!['verbose'] as bool;

    unawaited(watchProcess(
      webProcess,
      pipeStdout: verbose,
      pipeStderr: true,
      listen: checkWebdevStarted,
      onExit: !verbose //
          ? () => print('webdev serve exited unexpectedly. Run again with -v to see verbose output')
          : null,
    ));

    await buildCompleted.stream.first;

    var args = [
      'run',
      '--enable-vm-service',
      '--enable-asserts',
      '-Djaspr.debug=true',
      '-Djaspr.hotreload=true',
    ];

    if (debug) {
      args.add('--pause-isolates-on-start');
    }

    String? entryPoint = await getEntryPoint(argResults!['input']);

    if (entryPoint == null) {
      print("Cannot find entry point. Create a main.dart in lib or web, or specify a file using --input.");
      shutdown(1);
    }

    args.add(entryPoint);

    args.addAll(argResults!.rest);

    var process = await Process.start(
      'dart',
      args,
      environment: {'PORT': argResults!['port'], 'JASPR_PROXY_PORT': '5467'},
    );

    await watchProcess(process);
  }
}
