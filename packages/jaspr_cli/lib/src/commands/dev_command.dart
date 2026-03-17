// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dwds/data/build_result.dart';
import 'package:dwds/src/loaders/strategy.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../dev/chrome.dart';
import '../dev/client_workflow.dart';
import '../helpers/dart_define_helpers.dart';
import '../helpers/flutter_helpers.dart';
import '../helpers/proxy_helper.dart';
import '../logging.dart';
import '../project.dart';
import 'base_command.dart';

abstract class DevCommand extends BaseCommand with ProxyHelper, FlutterHelper {
  DevCommand({super.logger}) {
    argParser.addOption(
      'input',
      abbr: 'i',
      help:
          'Specify the entry file for the server app. Must end in ".server.dart".\n'
          'Defaults to the first found "*.server.dart" file in the project.',
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
      help: 'Specify a port to run the dev server on. Defaults to {jaspr.port} from pubspec.yaml or "8080".',
    );
    argParser.addOption(
      'web-port',
      help: 'Specify a port for the webdev server. Defaults to "5467". Change this to run multiple projects.',
    );
    argParser.addOption(
      'proxy-port',
      help: 'Specify a port for the proxy server. Defaults to "5567". Change this to run multiple projects.',
    );
    argParser.addFlag('debug', abbr: 'd', help: 'Serves the app in debug mode.', negatable: false);
    argParser.addFlag('release', abbr: 'r', help: 'Serves the app in release mode.', negatable: false);
    argParser.addFlag('experimental-wasm', help: 'Compile to wasm', negatable: false);
    argParser.addFlag(
      'managed-build-options',
      help:
          'Whether jaspr will launch `build_runner` with options derived from command line arguments (the default).'
          'When disabled, builders compiling to the web need to be configured manually.',
      negatable: true,
      defaultsTo: true,
    );
    argParser.addFlag(
      'skip-server',
      help:
          'Skip running the server and only run the client workflow. When using this, the server must be started manually, including setting the JASPR_PROXY_PORT environment variable.',
      negatable: false,
      defaultsTo: false,
    );
    addDartDefineArgs();
  }

  @override
  String get category => 'Project';

  late final input = argResults!.option('input');
  late final debug = argResults!.flag('debug');
  late final release = argResults!.flag('release');
  late final mode = argResults!.option('mode')!;
  late final port = argResults!.option('port') ?? project.port ?? '8080';
  late final webPort = argResults!.option('web-port') ?? '5467';
  late final customProxyPort = argResults!.option('proxy-port');
  late final useWasm = argResults!.flag('experimental-wasm');
  late final managedBuildOptions = argResults!.flag('managed-build-options');
  late final skipServer = argResults!.flag('skip-server');

  bool get launchInChrome;
  bool get autoRun;

  void handleClientWorkflow(ClientWorkflow workflow) {}

  @override
  Future<int> runCommand() async {
    ensureInProject();

    logger.write('Running jaspr in ${project.requireMode.name} rendering mode.');

    final proxyPort = project.requireMode == JasprMode.client ? port : (customProxyPort ?? '5567');
    final flutterPort = '5678';

    final entryPoint = await getServerEntryPoint(input);

    if (entryPoint != null && !entryPoint.startsWith('lib/')) {
      logger.write(
        'Entry point is not located inside lib/ folder, disabling server-side hot-reload.',
        level: Level.warning,
      );
    }

    final workflow = await _runClient(webPort);
    if (workflow == null) {
      await stop();
      return 1;
    }

    handleClientWorkflow(workflow);

    if (project.flutterMode == FlutterMode.embedded) {
      final flutterProcess = await serveFlutter(flutterPort, useWasm);

      workflow.serverManager.servers.first.buildResults.where((event) => event.status == BuildStatus.succeeded).listen((
        event,
      ) {
        // trigger reload
        flutterProcess.stdin.writeln('r');
      });
    }

    await startProxy(
      proxyPort,
      webPort: webPort,
      serverPort: port,
      flutterPort: project.flutterMode == FlutterMode.embedded ? flutterPort : null,
      redirectNotFound: project.requireMode == JasprMode.client,
    );

    if (project.requireMode == JasprMode.client) {
      logger.write('Serving at http://localhost:$proxyPort', tag: Tag.cli);

      await _runChrome();

      await workflow.done;
      return 0;
    }

    if (skipServer) {
      logger.write(
        'Skipping server as per --skip-server flag.\n'
        'Make sure to set the JASPR_PROXY_PORT=$proxyPort environment variable when starting the server manually.',
        tag: Tag.cli,
        level: Level.warning,
      );
      await workflow.done;
      return 0;
    }
    return await _runServer(entryPoint!, proxyPort, workflow);
  }

  Future<int> _runServer(String entryPoint, String proxyPort, ClientWorkflow workflow) async {
    logger.write('Starting server...', tag: Tag.cli, progress: ProgressState.running);

    final useHotReload = entryPoint.startsWith('lib/') && !release;

    final serverTarget = File('.dart_tool/jaspr/server_target.dart').absolute;
    if (useHotReload && !serverTarget.existsSync()) {
      serverTarget.createSync(recursive: true);
    }

    final serverPid = File('.dart_tool/jaspr/server.pid').absolute;
    if (!serverPid.existsSync()) {
      serverPid.createSync(recursive: true);
    }
    serverPid.writeAsStringSync('');

    final userDefines = getServerDartDefines();

    final args = [
      // Use direct `dart` entry point for now due to
      // https://github.com/dart-lang/sdk/issues/61373.
      // 'run',
      if (!release) ...['--enable-vm-service', '--enable-asserts'] else '-Djaspr.flags.release=true',
      '-Djaspr.flags.verbose=$debug',
      for (final define in userDefines.entries) '-D${define.key}=${define.value}',
    ];

    if (debug) {
      args.add('--pause-isolates-on-start');
    }

    if (useHotReload) {
      final import = entryPoint.replaceFirst('lib', 'package:${project.requirePubspecYaml['name']}');
      serverTarget.writeAsStringSync(serverEntrypoint(import));

      args.add(serverTarget.path);
    } else {
      args.add(entryPoint);
    }

    args.addAll(argResults!.rest);
    final process = await Process.start(
      Platform.executable,
      args,
      environment: {'PORT': port, 'JASPR_PROXY_PORT': proxyPort},
      workingDirectory: Directory.current.absolute.path,
    );

    logger.write('Server started.', tag: Tag.cli, progress: ProgressState.completed);

    final serverFuture = watchProcess(
      'server',
      process,
      tag: Tag.server,
      onFail: () {
        logger.write(
          'Server stopped unexpectedly. There is probably more output above.',
          tag: Tag.cli,
          level: Level.error,
          progress: ProgressState.completed,
        );
        return true;
      },
    );

    var serverClosed = false;
    serverFuture.whenComplete(() {
      serverClosed = true;
    });

    // Wait until server is reachable.
    var n = 0;
    while (true) {
      await Future<void>.delayed(Duration(seconds: 2));
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
          level: Level.error,
        );
        return 1;
      }
    }

    await _runChrome();
    return serverFuture;
  }

  Future<void> _runChrome() async {
    if (!launchInChrome) return;

    var chrome = await startChrome(int.parse(port), logger);
    if (chrome == null) {
      return;
    }

    logger.write('Chrome started.', tag: Tag.cli, progress: ProgressState.completed);

    guardResource(() async {
      if (chrome != null) {
        logger.write('Closing Chrome...');
        chrome?.close();
        chrome = null;
      }
    });
  }

  Future<ClientWorkflow?> _runClient(String webPort) async {
    if (useWasm) {
      project.checkWasmSupport();
    }

    logger.write('Starting web compiler...', tag: Tag.cli, progress: ProgressState.running);

    final configuration = Configuration(
      reload: mode == 'reload' ? ReloadConfiguration.hotRestart : ReloadConfiguration.liveReload,
      debug: launchInChrome,
      debugExtension: launchInChrome,
      launchInChrome: launchInChrome,
      autoRun: autoRun,
    );

    final compiler = useWasm
        ? 'dart2wasm'
        : release
        ? 'dart2js'
        : 'dartdevc';

    final dartDefines = getClientDartDefines();
    if (project.flutterMode == FlutterMode.embedded) {
      dartDefines.addAll(getFlutterDartDefines(useWasm, release));
    }

    if (project.flutterMode != FlutterMode.none) {
      project.checkFlutterBuildSupport();
    }

    final ddcDefines = {
      'jaspr.flags.verbose': debug,
      ...dartDefines,
    };

    final dart2jsDefines = [
      '-Djaspr.flags.release=$release',
      if (!release) '--enable-asserts',
      if (useWasm && project.flutterMode != FlutterMode.none)
        '--extra-compiler-option=--platform=${p.join(webSdkDir, 'kernel', 'dart2wasm_platform.dill')}',
      for (final e in dartDefines.entries) '-D${e.key}=${e.value}',
    ];

    List<String> additionalFlutterBuildArgs() {
      final sdkKernelPath = p.url.join(
        'kernel',
        flutterVersion.compareTo('3.32.0') >= 0 ? 'ddc_outline.dill' : 'ddc_outline_sound.dill',
      );
      final librariesPath = p.join(webSdkDir, 'libraries.json');
      final sdkJsPath = p.join(
        webSdkDir,
        'kernel',
        flutterVersion.compareTo('3.32.0') >= 0 ? 'amd-canvaskit' : 'amd-canvaskit-sound',
      );
      return [
        '--define=build_web_compilers:entrypoint=use-ui-libraries=true',
        '--define=build_web_compilers:entrypoint_marker=use-ui-libraries=true',
        '--define=build_web_compilers:ddc=use-ui-libraries=true',
        '--define=build_web_compilers:ddc_modules=use-ui-libraries=true',
        '--define=build_web_compilers:dart2js_modules=use-ui-libraries=true',
        '--define=build_web_compilers:dart2wasm_modules=use-ui-libraries=true',
        '--define=build_web_compilers:entrypoint=libraries-path=${jsonEncode(librariesPath)}',
        '--define=build_web_compilers:entrypoint=unsafe-allow-unsupported-modules=true',
        '--define=build_web_compilers:sdk_js=use-prebuilt-sdk-from-path=${jsonEncode(sdkJsPath)}',
        if (compiler == 'dartdevc') ...[
          '--define=build_web_compilers:ddc=ddc-kernel-path=${jsonEncode(sdkKernelPath)}',
          '--define=build_web_compilers:ddc=libraries-path=${jsonEncode(librariesPath)}',
          '--define=build_web_compilers:ddc=platform-sdk=${jsonEncode(webSdkDir)}',
        ],
      ];
    }

    final buildArgs = [
      if (release) '--release',
      '--delete-conflicting-outputs',
      if (managedBuildOptions) ...[
        '--define=build_web_compilers:ddc=generate-full-dill=true',
        '--define=build_web_compilers:entrypoint=compiler=$compiler',
        switch (compiler) {
          'dartdevc' => '--define=build_web_compilers:ddc=environment=${jsonEncode(ddcDefines)}',
          _ => '--define=build_web_compilers:entrypoint=${compiler}_args=${jsonEncode(dart2jsDefines)}',
        },
        if (project.flutterMode != FlutterMode.none) ...additionalFlutterBuildArgs(),
      ],
    ];

    final workflow = await ClientWorkflow.start(configuration, buildArgs, webPort, logger, guardResource);
    if (workflow == null) {
      return null;
    }

    guardResource(() async {
      logger.write('Terminating web compiler...');
      await workflow.shutDown();
    });

    final buildCompleter = Completer<void>();

    final timer = Timer(Duration(seconds: 20), () {
      if (!buildCompleter.isCompleted) {
        logger.write(
          'Building web assets... (This takes longer for the initial build)',
          tag: Tag.cli,
          progress: ProgressState.running,
        );
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
        logger.write(
          'Failed building web assets. There is probably more output above.',
          tag: Tag.cli,
          level: Level.error,
          progress: ProgressState.completed,
        );
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
      logger.write(
        'Could not start dev server due to build errors.',
        tag: Tag.cli,
        level: Level.error,
        progress: ProgressState.completed,
      );

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

String serverEntrypoint(String import) =>
    '''
  import '$import' as m;
  import 'package:hotreloader/hotreloader.dart';
      
  void main(List<String> args) async {
    final mainFunc = m.main as dynamic;
    final mainCall = mainFunc is dynamic Function(List<String>) ? () => mainFunc(args) : () => mainFunc();

    try {
      await HotReloader.create(
        debounceInterval: Duration.zero,
        onAfterReload: (ctx) => mainCall(),
      );
      print('[INFO] Server hot reload is enabled.');
    } on StateError catch (e) {
      if (e.message.contains('VM service not available')) {
        print('[WARNING] Server hot reload not enabled. Run with --enable-vm-service to enable hot reload.');
      } else {
        rethrow;
      }
    }
    
    mainCall();
  }
''';
