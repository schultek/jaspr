// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:dwds/data/build_result.dart';
import 'package:dwds/src/loaders/strategy.dart';
import 'package:mason/mason.dart' show ExitCode;
import 'package:webdev/src/command/configuration.dart';
import 'package:webdev/src/serve/dev_workflow.dart';

import '../config.dart';
import '../helpers/flutter_helpers.dart';
import '../helpers/proxy_helper.dart';
import '../logging.dart';
import 'base_command.dart';

class ServeCommand extends BaseCommand with ProxyHelper, FlutterHelper {
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
  }

  @override
  String get description => 'Runs a development server that serves the jaspr app and '
      'reloads based on file system updates.';

  @override
  String get name => 'serve';

  @override
  String get category => 'Project';

  late final debug = argResults!['debug'] as bool;
  late final release = argResults!['release'] as bool;
  late final mode = argResults!['mode'] as String;
  late final port = argResults!['port'] as String;

  @override
  Future<int> run() async {
    await super.run();

    logger.write("Running jaspr in ${config!.mode.name} rendering mode.");

    var proxyPort = config!.mode == JasprMode.client ? port : '5567';
    var flutterPort = '5678';
    var webPort = '5467';

    var workflow = await _runWebCompiler(webPort);

    if (config!.usesFlutter) {
      var flutterProcess = await serveFlutter(flutterPort);

      workflow.serverManager.servers.first.buildResults
          .where((event) => event.status == BuildStatus.succeeded)
          .listen((event) {
        // trigger reload
        flutterProcess.stdin.writeln('r');
      });
    }

    await startProxy(proxyPort, webPort, config!.usesFlutter ? flutterPort : null);

    if (config!.mode == JasprMode.client) {
      logger.write('Serving at http://localhost:$proxyPort');

      await workflow.done;
      return ExitCode.success.code;
    }

    if (config!.devCommand != null) {
      await _runDevCommand(config!.devCommand!, proxyPort);
    } else {
      await _runServer(proxyPort);
    }
    return ExitCode.success.code;
  }

  Future<void> _runServer(String proxyPort) async {
    logger.write("Starting server...", progress: ProgressState.running);

    var args = [
      'run',
      if (!release) ...[
        '--enable-vm-service',
        '--enable-asserts',
        '-Djaspr.dev.hotreload=true',
      ] else
        '-Djaspr.flags.release=true',
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
      environment: {'PORT': port, 'JASPR_PROXY_PORT': proxyPort},
    );

    logger.write('Server started.', progress: ProgressState.completed);

    await watchProcess('server', process, tag: Tag.server);
  }

  Future<void> _runDevCommand(String command, String proxyPort) async {
    logger.write("Starting server...", progress: ProgressState.running);

    if (release) {
      logger.write("Ignoring --release flag since custom dev command is used.", level: Level.warning);
    }
    if (debug) {
      logger.write("Ignoring --debug flag since custom dev command is used.", level: Level.warning);
    }

    var [exec, ...args] = command.split(" ");

    var process = await Process.start(
      exec,
      args,
      environment: {'PORT': port, 'JASPR_PROXY_PORT': proxyPort},
    );

    logger.write('Server started.', progress: ProgressState.completed);

    await watchProcess('server', process, tag: Tag.server);
  }

  Future<DevWorkflow> _runWebCompiler(String webPort) async {
    logger.write('Starting web compiler...', progress: ProgressState.running);

    var configuration = Configuration(
      reload: mode == 'reload' ? ReloadConfiguration.hotRestart : ReloadConfiguration.liveReload,
      release: release,
    );

    var compilers = '${config!.usesJasprWebCompilers ? 'jaspr' : 'build'}_web_compilers';

    var workflow = await DevWorkflow.start(configuration, [
      if (release) '--release',
      '--define',
      '$compilers:ddc=generate-full-dill=true',
      '--delete-conflicting-outputs',
      if (!release)
        '--define=$compilers:ddc=environment={"jaspr.flags.verbose":$debug}'
      else
        '--define=$compilers:entrypoint=dart2js_args=["-Djaspr.flags.release=true"]',
    ], {
      'web': int.parse(webPort)
    });

    guardResource(() async {
      logger.write('Terminating web compiler...');
      await workflow.shutDown();
    });

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
        logger.write('Failed building web assets. There is probably more output above.',
            level: Level.error, progress: ProgressState.completed);
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

    return workflow;
  }
}
