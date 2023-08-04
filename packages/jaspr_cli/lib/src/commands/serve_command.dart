// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:dwds/data/build_result.dart';
import 'package:dwds/src/loaders/strategy.dart';
import 'package:mason/mason.dart' show ExitCode;
import 'package:webdev/src/command/configuration.dart';
import 'package:webdev/src/serve/dev_workflow.dart';

import '../logging.dart';
import 'base_command.dart';

class ServeCommand extends BaseCommand {
  ServeCommand({super.logger}) {
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
      defaultsTo: null,
      help: '(Deprecated) Optionally disables server-side rendering and runs as a pure client-side app.',
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
    argParser.addOption('flutter', help: 'Launch an embedded flutter app from the specified entrypoint.');
  }

  @override
  String get description => 'Runs a development server that serves the web app with SSR and '
      'reloads based on file system updates.';

  @override
  String get name => 'serve';

  late final useSSR = () {
    var useSSR = argResults!['ssr'] as bool?;

    if (useSSR != null) {
      logger.write(
          '"--ssr" is deprecated and will be removed in the next version. Use the "jaspr.ssr" configuration option in pubspec.yaml instead.',
          level: Level.warning);
    } else {
      useSSR = config.ssr.enabled;
    }
    return useSSR;
  }();

  late final debug = argResults!['debug'] as bool;
  late final release = argResults!['release'] as bool;
  late final flutter = argResults!['flutter'] as String?;
  late final mode = argResults!['mode'] as String;
  late final port = argResults!['port'] as String;

  @override
  Future<int> run() async {
    await super.run();

    logger.write(
        "Starting jaspr in ${release ? 'release' : debug ? 'debug' : 'development'} mode...",
        progress: ProgressState.running);

    var workflow = await _runWebdev();
    guardResource(() => workflow.shutDown());

    logger.complete(true);
    logger.write('Starting web builder...', progress: ProgressState.running);

    var buildCompleter = Completer();

    var timer = Timer(Duration(seconds: 20), () {
      if (!buildCompleter.isCompleted) {
        logger.write('Building web assets... (This takes longer for the initial build)',
            progress: ProgressState.running);
      }
    });

    workflow.serverManager.servers.first.buildResults.listen((event) {
      if (event.status == BuildStatus.succeeded) {
        if (!buildCompleter.isCompleted) {
          buildCompleter.complete();
        } else {
          logger.write('Rebuilt web assets.', progress: ProgressState.completed);
        }
      } else if (event.status == BuildStatus.failed) {
        if (!verbose) {
          logger.write('Building web assets failed unexpectedly. Run again with -v to see full output.',
              level: Level.critical, progress: ProgressState.completed);
        }
        shutdown();
      } else if (event.status == BuildStatus.started) {
        if (buildCompleter.isCompleted) {
          logger.write('Rebuilding web assets...', progress: ProgressState.running);
        } else {
          logger.write('Building web assets...', progress: ProgressState.running);
        }
      }
    });

    await buildCompleter.future;
    timer.cancel();

    logger.write('Done building web assets.', progress: ProgressState.completed);

    if (flutter != null) {
      var flutterProcess = await Process.start(
        'flutter',
        ['run', '--device-id=web-server', '-t', flutter!, '--web-port=5678'],
      );
      unawaited(watchProcess(flutterProcess, tag: Tag.flutter, onFail: () {
        if (!verbose) {
          logger.write('flutter run exited unexpectedly. Run again with -v to see verbose output',
              level: Level.critical, progress: ProgressState.completed);
        }
      }));

      workflow.serverManager.servers.first.buildResults
          .where((event) => event.status == BuildStatus.succeeded)
          .listen((event) {
        // trigger reload
        flutterProcess.stdin.writeln('r');
      });
    }

    if (!useSSR) {
      await workflow.done;
      return ExitCode.success.code;
    }

    await _runServer();
    return ExitCode.success.code;
  }

  Future<void> _runServer() async {
    logger.write("Starting server...", progress: ProgressState.running);

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
      logger.complete(false);
      logger.write("Cannot find entry point. Create a main.dart in lib or web, or specify a file using --input.",
          level: Level.critical);
      await shutdown();
    }

    args.add(entryPoint);

    args.addAll(argResults!.rest);

    var process = await Process.start(
      'dart',
      args,
      environment: {'PORT': argResults!['port'], 'JASPR_PROXY_PORT': '5467'},
    );

    logger.write('Server started.', progress: ProgressState.completed);

    await watchProcess(process, tag: Tag.server);
  }

  Future<DevWorkflow> _runWebdev() async {
    var builderPort = useSSR ? '5467' : port;

    var configuration = Configuration(
      reload: mode == 'reload' ? ReloadConfiguration.hotRestart : ReloadConfiguration.liveReload,
      release: release,
    );

    var compilers = '${usesJasprWebCompilers ? 'jaspr' : 'build'}_web_compilers';

    var workflow = await DevWorkflow.start(configuration, [
      if (release) '--release',
      '--verbose',
      '--define',
      '$compilers:ddc=generate-full-dill=true',
      '--delete-conflicting-outputs',
      if (!release)
        '--define=$compilers:ddc=environment={"jaspr.flags.verbose":$debug}'
      else
        '--define=$compilers:entrypoint=dart2js_args=["-Djaspr.flags.release=true"]',
    ], {
      'web': int.parse(builderPort)
    });

    return workflow;
  }
}
