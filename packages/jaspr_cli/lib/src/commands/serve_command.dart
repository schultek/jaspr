// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:dwds/data/build_result.dart';
import 'package:dwds/src/loaders/strategy.dart';
import 'package:webdev/src/command/configuration.dart';
import 'package:webdev/src/serve/dev_workflow.dart';

import '../config.dart';
import '../helpers/dart_define_helpers.dart';
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
    argParser.addFlag(
      'experimental-wasm',
      help: 'Compile to wasm',
      negatable: false,
    );
    addDartDefineArgs();
  }

  @override
  String get description => 'Runs a development server that reloads based on file system updates.';

  @override
  String get name => 'serve';

  @override
  String get category => 'Project';

  late final debug = argResults!['debug'] as bool;
  late final release = argResults!['release'] as bool;
  late final mode = argResults!['mode'] as String;
  late final port = argResults!['port'] as String;
  late final useWasm = argResults!['experimental-wasm'] as bool;

  @override
  Future<CommandResult?> run() async {
    await super.run();

    logger.write("Running jaspr in ${config!.mode.name} rendering mode.");

    var proxyPort = config!.mode == JasprMode.client ? port : '5567';
    var flutterPort = '5678';
    var webPort = '5467';

    var workflow = await _runWebCompiler(webPort);

    if (config!.usesFlutter) {
      var flutterProcess = await serveFlutter(flutterPort, useWasm);

      workflow.serverManager.servers.first.buildResults
          .where((event) => event.status == BuildStatus.succeeded)
          .listen((event) {
        // trigger reload
        flutterProcess.stdin.writeln('r');
      });
    }

    await startProxy(
      proxyPort,
      webPort: webPort,
      flutterPort: config!.usesFlutter ? flutterPort : null,
      redirectNotFound: config!.mode == JasprMode.client,
    );

    if (config!.mode == JasprMode.client) {
      logger.write('Serving at http://localhost:$proxyPort');

      return CommandResult.running(workflow.done, stop);
    }

    if (config!.devCommand != null) {
      return await _runDevCommand(config!.devCommand!, proxyPort);
    } else {
      return await _runServer(proxyPort);
    }
  }

  Future<CommandResult> _runServer(String proxyPort) async {
    logger.write("Starting server...", progress: ProgressState.running);

    var serverTarget = File('.dart_tool/jaspr/server_target.dart').absolute;
    if (!serverTarget.existsSync()) {
      serverTarget.createSync(recursive: true);
    }

    var serverPid = File('.dart_tool/jaspr/server.pid').absolute;
    if (!serverPid.existsSync()) {
      serverPid.createSync(recursive: true);
    }
    serverPid.writeAsStringSync('');

    var userDefines = getServerDartDefines();

    var args = [
      'run',
      if (!release) ...[
        '--enable-vm-service',
        '--enable-asserts',
      ] else
        '-Djaspr.flags.release=true',
      '-Djaspr.flags.verbose=$debug',
      for (var define in userDefines.entries) '-D${define.key}=${define.value}',
    ];

    if (debug) {
      args.add('--pause-isolates-on-start');
    }

    var entryPoint = await getEntryPoint(argResults!['input'], true);

    if (!release) {
      var import = entryPoint.replaceFirst('lib', 'package:${config!.projectName}');
      serverTarget.writeAsStringSync(serverEntrypoint(import));

      args.add(serverTarget.path);
    } else {
      args.add(entryPoint);
    }

    args.addAll(argResults!.rest);
    var process = await Process.start(
      Platform.executable,
      args,
      environment: {'PORT': port, 'JASPR_PROXY_PORT': proxyPort},
      workingDirectory: Directory.current.path,
    );

    logger.write('Server started.', progress: ProgressState.completed);

    return CommandResult.running(watchProcess('server', process, tag: Tag.server), stop);
  }

  Future<CommandResult> _runDevCommand(String command, String proxyPort) async {
    logger.write("Starting server...", progress: ProgressState.running);

    if (release) {
      logger.write("Ignoring --release flag since custom dev command is used.", level: Level.warning);
    }
    if (debug) {
      logger.write("Ignoring --debug flag since custom dev command is used.", level: Level.warning);
    }
    var userDefines = getServerDartDefines();
    if (userDefines.isNotEmpty) {
      logger.write("Ignoring all --dart-define options since custom dev command is used.", level: Level.warning);
    }

    var [exec, ...args] = command.split(" ");

    var process = await Process.start(
      exec,
      args,
      environment: {'PORT': port, 'JASPR_PROXY_PORT': proxyPort},
      workingDirectory: Directory.current.path,
    );

    logger.write('Server started.', progress: ProgressState.completed);

    return CommandResult.running(watchProcess('server', process, tag: Tag.server), stop);
  }

  Future<DevWorkflow> _runWebCompiler(String webPort) async {
    if (useWasm) {
      checkWasmSupport();
    }

    logger.write('Starting web compiler...', progress: ProgressState.running);

    var configuration = Configuration(
      reload: mode == 'reload' ? ReloadConfiguration.hotRestart : ReloadConfiguration.liveReload,
      release: release,
    );

    var package = '${config!.usesJasprWebCompilers ? 'jaspr' : 'build'}_web_compilers';
    var compiler = useWasm
        ? 'dart2wasm'
        : release
            ? 'dart2js'
            : 'dartdevc';

    var dartDefines = getClientDartDefines();
    if (config!.usesFlutter) {
      dartDefines.addAll(getFlutterDartDefines(useWasm, release));
    }

    var dartdevcDefines = dartDefines.entries.map((e) => ',"${e.key}":"${e.value}"').join();
    var dart2jsDefines = dartDefines.entries.map((e) => ',"-D${e.key}=${e.value}"').join();

    var workflow = await DevWorkflow.start(configuration, [
      if (release) '--release',
      '--define',
      '$package:ddc=generate-full-dill=true',
      '--delete-conflicting-outputs',
      '--define=$package:entrypoint=compiler=$compiler',
      if (compiler == 'dartdevc') '--define=$package:ddc=environment={"jaspr.flags.verbose":$debug$dartdevcDefines}',
      if (compiler != 'dartdevc')
        '--define=$package:entrypoint=${compiler}_args=["-Djaspr.flags.release=$release"$dart2jsDefines${!release ? ',"--enable-asserts"' : ''}]',
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
        if (!buildCompleter.isCompleted) {
          buildCompleter.completeError(event);
        }
      } else if (event.status == BuildStatus.started) {
        if (buildCompleter.isCompleted) {
          logger.write('Rebuilding web assets...', progress: ProgressState.running);
        } else {
          logger.write('Building web assets...', progress: ProgressState.running);
        }
      }
    });

    try {
      await buildCompleter.future;
      logger.write('Done building web assets.', progress: ProgressState.completed);
    } on BuildResult catch (_) {
      logger.write('Could not start dev server due to build errors.',
          level: Level.error, progress: ProgressState.completed);
      await shutdown();
    }
    timer.cancel();

    return workflow;
  }
}

String serverEntrypoint(String import) => '''
  import '$import' as m;
  import 'package:hotreloader/hotreloader.dart';
      
  void main() async {
    try {
      await HotReloader.create(
        debounceInterval: Duration.zero,
        onAfterReload: (ctx) => m.main(),
      );
      print('[INFO] Server hot reload is enabled.');
    } on StateError catch (e) {
      if (e.message.contains('VM service not available')) {
        print('[WARNING] Server hot reload not enabled. Run with --enable-vm-service to enable hot reload.');
      } else {
        rethrow;
      }
    }
    
    m.main();
  }
''';
