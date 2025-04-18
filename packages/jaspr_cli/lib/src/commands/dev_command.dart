// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:dwds/data/build_result.dart';
import 'package:dwds/src/loaders/strategy.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../dev/chrome.dart';
import '../dev/client_workflow.dart';
import '../helpers/dart_define_helpers.dart';
import '../helpers/flutter_helpers.dart';
import '../helpers/proxy_helper.dart';
import '../logging.dart';
import 'base_command.dart';

abstract class DevCommand extends BaseCommand with ProxyHelper, FlutterHelper {
  DevCommand({super.logger}) {
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
  String get category => 'Project';

  late final debug = argResults!['debug'] as bool;
  late final release = argResults!['release'] as bool;
  late final mode = argResults!['mode'] as String;
  late final port = argResults!['port'] as String;
  late final useWasm = argResults!['experimental-wasm'] as bool;

  bool get launchInChrome;
  bool get autoRun;

  void handleClientWorkflow(ClientWorkflow workflow) {}

  @override
  Future<int> runCommand() async {
    logger.write("Running jaspr in ${config!.mode.name} rendering mode.");

    var proxyPort = config!.mode == JasprMode.client ? port : '5567';
    var flutterPort = '5678';
    var webPort = '5467';

    var workflow = await _runClient(webPort);
    if (workflow == null) {
      await stop();
      return 1;
    }

    handleClientWorkflow(workflow);

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
      logger.write('Serving at http://localhost:$proxyPort', tag: Tag.cli);

      var result = await _runChrome();
      if (result != null) {
        return result;
      }

      await workflow.done;
      return 0;
    }

    if (config!.devCommand != null) {
      return await _runDevCommand(config!.devCommand!, proxyPort);
    } else {
      return await _runServer(proxyPort, workflow);
    }
  }

  Future<int> _runServer(String proxyPort, ClientWorkflow workflow) async {
    logger.write("Starting server...", tag: Tag.cli, progress: ProgressState.running);

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

    logger.write('Server started.', tag: Tag.cli, progress: ProgressState.completed);

    var serverFuture = watchProcess('server', process, tag: Tag.server, onFail: () {
      logger.write('Server stopped unexpectedly. There is probably more output above.',
          tag: Tag.cli, level: Level.error, progress: ProgressState.completed);
      return true;
    });

    var serverClosed = false;
    serverFuture.whenComplete(() {
      serverClosed = true;
    });

    // Wait until server is reachable.
    var n = 0;
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      try {
        await http.head(Uri.parse('http://localhost:$port'));
        break;
      } on SocketException catch (_) {}

      if (serverClosed) return serverFuture;

      n++;
      if (n > 10) {
        logger.write(
            'Server at http://localhost:$port not reachable after ${n * 2} seconds. Please check the server logs for errors.',
            tag: Tag.cli,
            level: Level.error);
        return 1;
      }
    }

    var result = await _runChrome();
    if (result != null) {
      return result;
    }

    return serverFuture;
  }

  Future<int> _runDevCommand(String command, String proxyPort) async {
    logger.write("Starting server...", tag: Tag.cli, progress: ProgressState.running);

    if (release) {
      logger.write("Ignoring --release flag since custom dev command is used.", tag: Tag.cli, level: Level.warning);
    }
    if (debug) {
      logger.write("Ignoring --debug flag since custom dev command is used.", tag: Tag.cli, level: Level.warning);
    }
    var userDefines = getServerDartDefines();
    if (userDefines.isNotEmpty) {
      logger.write("Ignoring all --dart-define options since custom dev command is used.",
          tag: Tag.cli, level: Level.warning);
    }

    var [exec, ...args] = command.split(" ");

    var process = await Process.start(
      exec,
      args,
      environment: {'PORT': port, 'JASPR_PROXY_PORT': proxyPort},
      workingDirectory: Directory.current.path,
    );

    logger.write('Server started.', tag: Tag.cli, progress: ProgressState.completed);

    return await watchProcess('server', process, tag: Tag.server);
  }

  Future<int?> _runChrome() async {
    if (!launchInChrome) return null;

    var chrome = await startChrome(int.parse(port), logger);
    if (chrome == null) {
      return 1;
    }

    logger.write('Chrome started.', tag: Tag.cli, progress: ProgressState.completed);

    guardResource(() async {
      if (chrome != null) {
        logger.write('Closing Chrome...');
        chrome?.close();
        chrome = null;
      }
    });

    return null;
  }

  Future<ClientWorkflow?> _runClient(String webPort) async {
    if (useWasm) {
      checkWasmSupport();
    }

    logger.write('Starting web compiler...', tag: Tag.cli, progress: ProgressState.running);

    var configuration = Configuration(
      reload: mode == 'reload' ? ReloadConfiguration.hotRestart : ReloadConfiguration.liveReload,
      debug: launchInChrome,
      debugExtension: launchInChrome,
      launchInChrome: launchInChrome,
      autoRun: autoRun,
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

    final buildArgs = [
      if (release) '--release',
      '--define',
      '$package:ddc=generate-full-dill=true',
      '--delete-conflicting-outputs',
      '--define=$package:entrypoint=compiler=$compiler',
      if (compiler == 'dartdevc') '--define=$package:ddc=environment={"jaspr.flags.verbose":$debug$dartdevcDefines}',
      if (compiler != 'dartdevc')
        '--define=$package:entrypoint=${compiler}_args=["-Djaspr.flags.release=$release"$dart2jsDefines${!release ? ',"--enable-asserts"' : ''}]',
    ];

    var workflow = await ClientWorkflow.start(configuration, buildArgs, webPort, logger, guardResource);
    if (workflow == null) {
      return null;
    }

    guardResource(() async {
      logger.write('Terminating web compiler...');
      await workflow.shutDown();
    });

    var buildCompleter = Completer();

    var timer = Timer(Duration(seconds: 20), () {
      if (!buildCompleter.isCompleted) {
        logger.write('Building web assets... (This takes longer for the initial build)',
            tag: Tag.cli, progress: ProgressState.running);
      }
    });

    workflow.serverManager.servers.first.buildResults.listen((event) {
      if (event.status == BuildStatus.succeeded) {
        if (!buildCompleter.isCompleted) {
          buildCompleter.complete();
        } else {
          logger.write('Rebuilt web assets.', tag: Tag.cli, progress: ProgressState.completed);
        }
      } else if (event.status == BuildStatus.failed) {
        logger.write('Failed building web assets. There is probably more output above.',
            tag: Tag.cli, level: Level.error, progress: ProgressState.completed);
        if (!buildCompleter.isCompleted) {
          buildCompleter.completeError(event);
        }
      } else if (event.status == BuildStatus.started) {
        if (buildCompleter.isCompleted) {
          logger.write('Rebuilding web assets...', tag: Tag.cli, progress: ProgressState.running);
        } else {
          logger.write('Building web assets...', tag: Tag.cli, progress: ProgressState.running);
        }
      }
    });

    var aborted = false;
    guardResource(() {
      if (!buildCompleter.isCompleted) {
        logger.write('Aborting build...');
        aborted = true;
        buildCompleter.completeError(Object());
      }
    });

    try {
      await buildCompleter.future;
      logger.write('Done building web assets.', tag: Tag.cli, progress: ProgressState.completed);
    } on BuildResult catch (_) {
      logger.write('Could not start dev server due to build errors.',
          tag: Tag.cli, level: Level.error, progress: ProgressState.completed);

      return null;
    } catch (_) {
      if (aborted) {
        return null;
      }
      rethrow;
    } finally {
      timer.cancel();
    }

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
