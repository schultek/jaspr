// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dwds/data/build_result.dart';
import 'package:dwds/src/loaders/strategy.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart' as p;

import '../dev/chrome.dart';
import '../dev/client_workflow.dart';
import '../helpers/css_helper.dart';
import '../helpers/dart_define_helpers.dart';
import '../helpers/flutter_helpers.dart';
import '../helpers/print_logo.dart';
import '../helpers/proxy_helper.dart';
import '../logging.dart';
import '../process_runner.dart';
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
      help:
          'Specify a port to run the dev server on. '
          'Defaults to {jaspr.port} from pubspec.yaml or "$defaultServePort".',
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
  late final port = argResults!.option('port') ?? project.port ?? defaultServePort;
  late final customProxyPort = argResults!.option('proxy-port') ?? serverProxyPort;
  late final useWasm = argResults!.flag('experimental-wasm');
  late final managedBuildOptions = argResults!.flag('managed-build-options');
  late final skipServer = argResults!.flag('skip-server');

  bool get launchInChrome;

  void handleClientWorkflow(ClientWorkflow workflow) {}

  @override
  Future<int> runCommand() async {
    await ensureInProject();
    printLogo();

    logger.write('Starting ${cyan.wrap(project.name)} in ${cyan.wrap(project.requireMode.name)} rendering mode.');
    if (!verbose) {
      logger.write('Showing reduced log output. Pass --verbose to see all output.', level: Level.debug);
    }
    logger.write('\n');

    final entryPoint = await getServerEntryPoint(input);

    final proxyPort = project.requireMode == JasprMode.client ? port : customProxyPort;

    final workflow = await _runClient(proxyPort);
    if (workflow == null) {
      await stop();
      return 1;
    }

    await _runBuildCallback();

    handleClientWorkflow(workflow);

    if (project.flutterMode == FlutterMode.embedded) {
      final flutterProcess = await serveFlutter(useWasm);

      workflow.devProxy.buildResults.where((event) => event.status == BuildStatus.succeeded).listen((event) {
        // trigger reload
        flutterProcess.stdin.writeln('r');
      });
    }

    await startProxy(
      proxyPort,
      devProxy: workflow.devProxy,
      serverPort: port,
      flutterPort: project.flutterMode == FlutterMode.embedded ? flutterProxyPort : null,
      redirectNotFound: project.requireMode == JasprMode.client,
    );

    if (project.requireMode == JasprMode.client) {
      logger.write('Serving at http://localhost:$proxyPort', tag: Tag.cli);

      await _runChrome();
    } else if (skipServer) {
      logger.write(
        'Skipping server as per --skip-server flag.\n'
        'Make sure to set the JASPR_PROXY_PORT=$proxyPort environment variable when starting the server manually.',
        tag: Tag.cli,
        level: Level.warning,
      );
    } else {
      final started = await _startServer(entryPoint!, proxyPort, workflow);
      if (started) {
        await _runChrome();
      }
    }

    updateFooter(DevStatus.ready);

    return await workflow.done;
  }

  void updateFooter(DevStatus status) {
    final width = stdout.hasTerminal ? stdout.terminalColumns : 80;
    final leftText = ' Serving on http://localhost:$port';
    final rightText = switch (status) {
      DevStatus.ready => 'All ready ',
      DevStatus.rebuilding => 'Rebuilding... ',
      DevStatus.error => 'Errors occurred. Fix and save to retry. ',
    };
    final spacesCount = width - leftText.length - rightText.length;
    final spaces = spacesCount < 0 ? 0 : spacesCount;
    final footerContent = leftText + (' ' * spaces) + rightText;
    final footerColor = switch (status) {
      DevStatus.ready => backgroundGreen,
      DevStatus.rebuilding => backgroundYellow,
      DevStatus.error => backgroundRed,
    };
    final footerLine = footerColor.wrap(black.wrap(styleBold.wrap(footerContent)))!;

    logger.setFooter([
      '',
      footerLine,
    ]);
  }

  Future<bool> _startServer(String entryPoint, String proxyPort, ClientWorkflow workflow) async {
    logger.write('Starting server...', tag: Tag.server, progress: ProgressState.running);

    logger.write('Using server entry point: $entryPoint', tag: Tag.server, level: Level.verbose);

    if (!entryPoint.startsWith('lib/')) {
      logger.write(
        'Server entry point is not located inside lib/ folder, disabling server-side hot-reload.',
        tag: Tag.server,
        level: Level.warning,
      );
    }

    final parsedPort = int.tryParse(port);
    if (parsedPort != null && IOOverrides.current == null) {
      try {
        final socket = await ServerSocket.bind(InternetAddress.anyIPv4, parsedPort);
        await socket.close();
      } on SocketException catch (_) {
        logger.complete(false);
        logger.write(
          'Port $port is already in use.\nPlease quit the running process or choose a different port.',
          tag: Tag.server,
          level: Level.error,
        );
        await shutdown();
      }
    }

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
    final process = await ProcessRunner.instance.start(
      dartExecutable,
      args,
      environment: {'PORT': port, 'JASPR_PROXY_PORT': proxyPort},
      workingDirectory: Directory.current.absolute.path,
    );

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
      levelFor: (t) {
        if (t.startsWith('The Dart VM service is listening') ||
            t.startsWith('The Dart DevTools debugger and profiler is available')) {
          return Level.verbose;
        }
        return null;
      },
    );

    var serverClosed = false;
    serverFuture.then((code) {
      workflow.shutDown(code);
      serverClosed = true;
    });

    // Wait until server is reachable.
    var n = 0;
    final sw = Stopwatch()..start();

    while (true) {
      await Future<void>.delayed(Duration(milliseconds: 1000 + (n * 100)));
      try {
        final socket = await Socket.connect('localhost', int.parse(port));
        socket.close();
        sw.stop();
        break;
      } on SocketException catch (_) {}

      if (serverClosed) {
        sw.stop();
        return false;
      }

      n++;
      if (n >= 10) {
        sw.stop();
        logger.write(
          'Server at http://localhost:$port not reachable after ${sw.elapsed.inSeconds} seconds. Please check the server logs for errors.',
          tag: Tag.cli,
          level: Level.warning,
        );
        return false;
      }
    }

    logger.write(
      'Server started and listening on http://localhost:$port',
      tag: Tag.server,
      progress: ProgressState.completed,
    );

    return true;
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
        logger.write('Closing Chrome...', level: Level.debug);
        chrome?.close();
        chrome = null;
      }
    });
  }

  Future<ClientWorkflow?> _runClient(String proxyPort) async {
    if (useWasm) {
      project.checkWasmSupport();
    }

    logger.write('Starting web compilers...', tag: Tag.builder, progress: ProgressState.running);

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

    final workflow = await ClientWorkflow.start(
      proxyPort,
      buildArgs,
      logger,
      guardResource,
      enableDebugging: launchInChrome,
      reload: mode == 'reload' ? ReloadConfiguration.hotRestart : ReloadConfiguration.liveReload,
    );
    if (workflow == null) {
      return null;
    }

    guardResource(() async {
      logger.write('Stopping web compilers...', level: Level.debug);
      await workflow.shutDown();
    });

    final buildCompleter = Completer<void>();

    final timer = Timer(Duration(seconds: 20), () {
      if (!buildCompleter.isCompleted) {
        logger.write(
          'Building web assets... (This takes longer for the initial build)',
          tag: Tag.builder,
          progress: ProgressState.running,
        );
      }
    });

    workflow.devProxy.buildResults.listen((event) async {
      if (event.status == BuildStatus.succeeded) {
        if (!buildCompleter.isCompleted) {
          buildCompleter.complete();
        } else {
          logger.write('Rebuilt web assets.', tag: Tag.builder, progress: ProgressState.completed);
          await _runBuildCallback();
          updateFooter(DevStatus.ready);
        }
      } else if (event.status == BuildStatus.failed) {
        logger.write(
          'Failed building web assets. There is probably more output above.',
          tag: Tag.builder,
          level: Level.error,
          progress: ProgressState.completed,
        );
        if (!buildCompleter.isCompleted) {
          buildCompleter.completeError(event);
        } else {
          updateFooter(DevStatus.error);
        }
      } else if (event.status == BuildStatus.started) {
        if (buildCompleter.isCompleted) {
          logger.write('Rebuilding web assets...', tag: Tag.builder, progress: ProgressState.running);
          updateFooter(DevStatus.rebuilding);
        }
      }
    });

    var aborted = false;
    guardResource(() {
      if (!buildCompleter.isCompleted) {
        logger.write('Aborting build...', level: Level.debug);
        aborted = true;
        buildCompleter.completeError(Object());
      }
    });

    try {
      await buildCompleter.future;
      logger.write('Done building web assets.', tag: Tag.builder, progress: ProgressState.completed);
    } on BuildResult catch (_) {
      logger.write(
        'Could not start dev server due to build errors.',
        tag: Tag.builder,
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

  Future<void> _runBuildCallback() async {
    await generateCss();
  }
}

enum DevStatus { ready, rebuilding, error }

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
    } catch (_) {}
    
    mainCall();
  }
''';
