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
      negatable: false,
    );
    argParser.addFlag(
      'release',
      abbr: 'r',
      help: 'Serves the app in release mode.',
      negatable: false,
    );
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Enable verbose logging.',
      negatable: false,
    );
    argParser.addOption('flutter',
      help: 'Launch an embedded flutter app from the specified entrypoint.'
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
    var debug = argResults!['debug'] as bool;
    var release = argResults!['release'] as bool;
    var verbose = argResults!['verbose'] as bool;
    var flutter = argResults!['flutter'] as String?;

    var buildCompleted = StreamController<int>.broadcast();
    var build = 0;

    if (flutter != null) {
      var flutterProcess = await Process.start(
        'flutter',
        ['run', '--device-id=web-server', '-t', flutter, '--web-port=5678'],
      );
      unawaited(watchProcess(
        flutterProcess,
        pipeStdout: verbose,
        pipeStderr: true,
        onExit: !verbose //
            ? () => print('flutter run exited unexpectedly. Run again with -v to see verbose output')
            : null,
      ));

      buildCompleted.stream.listen((event) {
        // trigger reload
        flutterProcess.stdin.writeln('r');
      });
    }

    var webProcess = await runWebdev([
      'serve',
      '--auto=${argResults!['mode'] == 'reload' ? 'restart' : 'refresh'}',
      'web:${useSSR ? '5467' : argResults!['port']}',
      if (release) '--release',
      '--',
      '--delete-conflicting-outputs',
      if (!release)
        '--define=build_web_compilers:ddc=environment={"jaspr.flags.verbose":$debug}'
      else
        '--define=build_web_compilers:entrypoint=dart2js_args=["-Djaspr.flags.release=true"]',
    ]);

    if (!useSSR) {
      return watchProcess(webProcess);
    }

    print("Starting jaspr development server in ${release ? 'release' : 'debug'} mode...");


    checkWebdevStarted(String str) {
      if (str.contains('Running build completed')) {
        buildCompleted.add(build++);
      }
    }

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
      if (!release) ...[
        '--enable-vm-service',
        '--enable-asserts',
        '-Djaspr.dev.hotreload=true',
      ] else
        '-Djaspr.flags.release=true',
      '-Djaspr.dev.proxy=5467',
      if (flutter != null) '-Djaspr.dev.flutter=5678',
      '-Djaspr.flags.verbose=$debug',
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
