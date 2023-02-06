import 'dart:async';
import 'dart:io';
import 'package:webdev/src/serve/dev_workflow.dart';
import 'package:webdev/src/command/configuration.dart';
import 'package:dwds/src/loaders/strategy.dart';
import 'package:dwds/data/build_result.dart';
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
  }

  @override
  String get description => 'Runs a development server that serves the web app with SSR and '
      'reloads based on file system updates.';

  @override
  String get name => 'serve';

  @override
  Future<void> run() async {
    await super.run();

    var verbose = argResults!['verbose'] as bool;
    var useSSR = argResults!['ssr'] as bool;
    var debug = argResults!['debug'] as bool;
    var release = argResults!['release'] as bool;
    var mode = argResults!['mode'] as String;
    var port = argResults!['port'] as String;

    var workflow = await _runWebdev(release, debug, mode, useSSR ? '5467' : port);
    guardResource(() => workflow.shutDown());

    if (!useSSR) {
      return workflow.done;
    }

    print("Starting jaspr development server in ${release ? 'release' : 'debug'} mode...");

    await workflow.serverManager.servers.first.buildResults
        .where((event) => event.status == BuildStatus.succeeded)
        .first;

    var args = [
      'run',
      if (!release) ...[
        '--enable-vm-service',
        '--enable-asserts',
        '-Djaspr.dev.hotreload=true',
      ] else
        '-Djaspr.flags.release=true',
      '-Djaspr.dev.proxy=5467',
      '-Djaspr.flags.verbose=$debug',
    ];

    if (debug) {
      args.add('--pause-isolates-on-start');
    }

    String? entryPoint = await getEntryPoint(argResults!['input']);

    if (entryPoint == null) {
      print(
          "Cannot find entry point. Create a main.dart in lib or web, or specify a file using --input.");
      await shutdown(1);
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

Future<DevWorkflow> _runWebdev(bool release, bool debug, String mode, String port) {
  var configuration = Configuration(
    //outputPath: port,
    //outputInput: 'web',
    reload: mode == 'reload' ? ReloadConfiguration.hotRestart : ReloadConfiguration.liveReload,
  );

  return DevWorkflow.start(configuration, [
    if (release) '--release',
    '--verbose',
    '--define',
    'build_web_compilers|ddc=generate-full-dill=true',
    '--delete-conflicting-outputs',
    if (!release)
      '--define=build_web_compilers:ddc=environment={"jaspr.flags.verbose":$debug}'
    else
      '--define=build_web_compilers:entrypoint=dart2js_args=["-Djaspr.flags.release=true"]',
  ], {
    'web': int.parse(port)
  });
}
