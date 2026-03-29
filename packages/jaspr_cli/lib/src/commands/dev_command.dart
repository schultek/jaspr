// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dwds/data/build_result.dart';
import 'package:dwds/src/loaders/strategy.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart' as p;
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

import '../daemon/logger.dart';
import '../dev/chrome.dart';
import '../dev/client_workflow.dart';
import '../dev/devtools_server.dart';
import '../helpers/css_helper.dart';
import '../helpers/dart_define_helpers.dart';
import '../helpers/flutter_helpers.dart';
import '../helpers/print_logo.dart';
import '../helpers/proxy_helper.dart';
import '../logging.dart';
import '../process_runner.dart';
import '../project.dart';
import 'base_command.dart';

abstract class DevCommand extends BaseCommand with ProxyHelper, FlutterHelper, DevToolsHelper {
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
      allowed: ['reload', 'restart', 'refresh', 'none'],
      allowedHelp: {
        'reload': 'Hot-reloads both client and server apps',
        'restart': 'Restarts the client app (loses current state)',
        'refresh': 'Performs a full page refresh and server reload',
        'none': 'Does not perform any reloads',
      },
      defaultsTo: 'reload',
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
    argParser.addOption(
      'devtools-port',
      help: 'Specify a port for the Jaspr DevTools app. Defaults to "5468".',
    );
    argParser.addFlag('debug', abbr: 'd', help: 'Serves the app in debug mode.', negatable: false);
    argParser.addFlag('release', abbr: 'r', help: 'Serves the app in release mode.', negatable: false);
    argParser.addFlag('experimental-wasm', help: 'Compile to wasm', negatable: false);
    argParser.addOption('module-format', help: 'The module format to use.', allowed: ['ddc', 'amd'], defaultsTo: 'ddc');
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
      help: 'Skip running the server and only run the client workflow. When using this, the server must be started manually, including setting the JASPR_PROXY_PORT environment variable.',
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
  late final devToolsPort = argResults!.option('devtools-port') ?? defaultDevToolsPort;
  late final useWasm = argResults!.flag('experimental-wasm');
  late final moduleFormat = argResults!.option('module-format');
  late final managedBuildOptions = argResults!.flag('managed-build-options');

  late final skipServer = argResults!.flag('skip-server');

  String? vmServiceUri;
  String? serverDevToolsUri;
  vm.VmService? serverVmService;
  DevStatus _currentStatus = DevStatus.ready;
  late final CssRunner _cssRunner;

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

    handleClientWorkflow(workflow);

    final cssRunner = _cssRunner = await watchCss(workflow);

    Process? flutterProcess;
    if (project.flutterMode == FlutterMode.embedded) {
      flutterProcess = await serveFlutter(useWasm);

      workflow.devProxy.registerPostReloadCallback(() {
        flutterProcess?.stdin.writeln('r');
      });
    }

    await startProxy(
      proxyPort,
      devProxy: workflow.devProxy,
      serverPort: port,
      flutterPort: project.flutterMode == FlutterMode.embedded ? flutterProxyPort : null,
      redirectNotFound: project.requireMode == JasprMode.client,
      onMessage: (message) async {
        if (message case {'reload': final Object reload}) {
          final String? route = reload is String ? reload : null;
          for (final connection in workflow.devProxy.getClientConnections()) {
            try {
              await connection.vmService?.callServiceExtension(
                'ext.jaspr.reload',
                args: route != null ? {'path': route} : null,
              );
            } catch (_) {}
          }
        }
      },
    );

    await cssRunner.initialGenerationComplete;

    if (project.requireMode == JasprMode.client) {
      logger.write('Serving at http://localhost:$proxyPort', tag: Tag.cli);

      await startDevToolsServer(int.parse(devToolsPort));
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
        await startDevToolsServer(int.parse(devToolsPort));
        await _runChrome();
      }
    }

    updateFooter(DevStatus.ready);

    _setupKeyHandler(workflow, flutterProcess);

    return await workflow.done;
  }

  void updateFooter(DevStatus status) {
    _currentStatus = status;
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

    final dot = '  ·  ';
    final keys = [
      '${styleBold.wrap('[r]')}: Reload',
      '${styleBold.wrap('[R]')}: Restart',
      '${styleBold.wrap('[d]')}: DevTools',
      '${styleBold.wrap('[q]')}: Quit',
    ];
    final rawKeys = [
      '[r]: Reload',
      '[R]: Restart',
      '[d]: DevTools',
      '[q]: Quit',
    ];
    final rawKeysContent = ' ${rawKeys.join(dot)}';
    final keysSpacesCount = width - rawKeysContent.length;
    final keysSpaces = keysSpacesCount < 0 ? 0 : keysSpacesCount;
    final keysContent = ' ${keys.join(dot)}${' ' * keysSpaces}';
    final keysLine = darkGray.wrap(keysContent)!;

    logger.setFooter([
      '',
      footerLine,
      keysLine,
    ]);
  }

  void _setupKeyHandler(ClientWorkflow workflow, [Process? flutterProcess]) {
    if (!stdin.hasTerminal || logger is DaemonLogger) {
      return;
    }

    final originalLineMode = stdin.lineMode;
    final originalEchoMode = stdin.echoMode;

    try {
      stdin.lineMode = false;
      stdin.echoMode = false;
    } catch (_) {
      return;
    }

    void restoreTerminal() {
      try {
        if (stdin.hasTerminal) {
          stdin.lineMode = originalLineMode;
          stdin.echoMode = originalEchoMode;
        }
      } catch (_) {}
    }

    guardResource(restoreTerminal);

    StreamSubscription<List<int>>? sub;
    var inEscape = false;
    var inBracket = false;

    sub = stdin.listen((bytes) async {
      for (final byte in bytes) {
        if (byte == 3 || byte == 4) {
          shutdown();
          return;
        }
        if (byte == 27) {
          inEscape = true;
          inBracket = false;
          continue;
        }
        if (inEscape) {
          if (byte == 91) {
            inBracket = true;
            continue;
          }
          if (inBracket) {
            if (byte >= 64 && byte <= 126) {
              inEscape = false;
              inBracket = false;
            }
            continue;
          }
          inEscape = false;
          continue;
        }

        final char = String.fromCharCode(byte);
        await _handleKey(char, workflow, flutterProcess);
      }
    });

    guardResource(() async {
      await sub?.cancel();
    });
  }

  Future<void> _handleKey(String key, ClientWorkflow workflow, Process? flutterProcess) async {
    switch (key) {
      case 'r':
        logger.write('Reloading...', tag: Tag.client);
        try {
          await workflow.devProxy.reloadClients();
        } catch (e) {
          logger.write('Failed to reload: $e', tag: Tag.cli, level: Level.warning);
        }
      case 'R':
        logger.write('Restarting...', tag: Tag.client);
        try {
          await workflow.devProxy.restartClients();
          flutterProcess?.stdin.writeln('R');
          await _reloadServer();
          await _cssRunner.restart();
        } catch (e) {
          logger.write('Failed to restart: $e', tag: Tag.cli, level: Level.warning);
        }
      case 'd':
        final clientUri = workflow.devProxy.clientDevToolsUri;
        final serverUri =
            serverDevToolsUri ??
            (vmServiceUri != null
                ? '${vmServiceUri!}devtools/?uri=${vmServiceUri!.replaceFirst('http', 'ws')}ws'
                : null);

        if (clientUri == null && serverUri == null) {
          logger.write('DevTools not available yet.', tag: Tag.cli);
        } else {
          if (clientUri != null) {
            logger.write('Opening Client DevTools: $clientUri', tag: Tag.client);
            await launchUrl(clientUri);
          }
          if (serverUri != null) {
            logger.write('Opening Server DevTools: $serverUri', tag: Tag.server);
            await launchUrl(serverUri);
          }
        }
      case 'c':
        stdout.write('\x1b[2J\x1b[0;0H');
        updateFooter(_currentStatus);
      case 'q':
        shutdown();
    }
  }

  Future<void> launchUrl(String url) async {
    try {
      if (Platform.isMacOS) {
        await Process.run('open', [url]);
      } else if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', url]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [url]);
      }
    } catch (e) {
      logger.write('Failed to open browser: $e', tag: Tag.cli, level: Level.warning);
    }
  }

  Future<void> _reloadServer() async {
    if (serverVmService case final vmService?) {
      try {
        final vmObj = await vmService.getVM();
        final mainIsolate = vmObj.isolates!.first;
        await vmService.reloadSources(mainIsolate.id!);
        await vmService.callServiceExtension('ext.jaspr.reload', isolateId: mainIsolate.id!);
        logger.write('Server reloaded.', tag: Tag.server);
      } catch (e) {
        logger.write('Failed to reload server: $e', tag: Tag.server, level: Level.warning);
      }
    }
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

    final useServerReload = entryPoint.startsWith('lib/') && !release;

    final serverTarget = File('.dart_tool/jaspr/server_target.dart').absolute;
    if (useServerReload && !serverTarget.existsSync()) {
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

    if (useServerReload) {
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

    vm.VmService? vmService;

    Future<void> connectToVmService([int retries = 2]) async {
      if (vmServiceUri == null) return;
      try {
        final wsUri = '${vmServiceUri!.replaceFirst('http', 'ws')}ws';
        final currentVmService = vmService = serverVmService = await vmServiceConnectUri(wsUri);

        currentVmService.onDone.then((_) {
          if (currentVmService == vmService) {
            vmService = serverVmService = null;
            Future.delayed(Duration(seconds: 1), () => connectToVmService());
          }
        });
      } catch (e) {
        if (retries > 0) {
          Future.delayed(Duration(seconds: 1), () => connectToVmService(retries - 1));
        } else {
          logger.write('Failed to connect to server VM service: $e', tag: Tag.cli, level: Level.warning);
        }
      }
    }

    guardResource(() {
      final currentVmService = vmService;
      vmService = serverVmService = null;
      currentVmService?.dispose();
    });

    final serverFuture = watchProcess(
      'server',
      process,
      tag: Tag.server,
      hide: (log) {
        if (serverDevToolsUri == null) {
          final match = RegExp(r'The Dart DevTools debugger and profiler is available at:\s*(http://[^\s]+)')
              .firstMatch(log);
          if (match != null) {
            serverDevToolsUri = match.group(1)!;
          }
        }
        if (mode != 'none' && vmServiceUri == null) {
          final match = RegExp(r'The Dart VM service is listening on (http://[a-zA-Z0-9:/_=\-\.\?]+)').firstMatch(log);
          if (match != null) {
            var url = vmServiceUri = match.group(1)!;
            connectToVmService();

            // Optional: convert to ws:// if needed, but devtools typically accepts http and transforms it.
            if (url.startsWith('http://')) {
              url = 'ws://${url.substring(7)}';
            }
            if (!url.endsWith('/')) {
              url += '/';
            }
            controller.setServerVmServiceUri('${url}ws');
          }
        }
        return false;
      },
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

    if (mode != 'none') {
      workflow.devProxy.registerPostReloadCallback(_reloadServer);
    }

    var serverClosed = false;
    serverFuture.then((code) {
      serverVmService = null;
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
      ...dartDefines,
    };

    final dart2jsDefines = [
      '-Djaspr.flags.release=$release',
      if (!release) '--enable-asserts',
      if (useWasm && project.flutterMode != FlutterMode.none)
        '--extra-compiler-option=--platform=${p.join(webSdkDir, 'kernel', 'dart2wasm_platform.dill')}',
      for (final e in dartDefines.entries) '-D${e.key}=${e.value}',
    ];

    var reloadConfig = switch (mode) {
      'reload' => ReloadConfiguration.hotReload,
      'refresh' => ReloadConfiguration.liveReload,
      'restart' => ReloadConfiguration.hotRestart,
      _ => ReloadConfiguration.none,
    };
    final moduleFormat = this.moduleFormat ?? 'ddc';
    if (moduleFormat == 'amd' && reloadConfig == ReloadConfiguration.hotReload) {
      logger.write(
        'The AMD module format does not support hot reload. Using hot restart instead of hot reload.',
        level: Level.warning,
      );
      reloadConfig = ReloadConfiguration.hotRestart;
    }

    if (reloadConfig == ReloadConfiguration.hotReload) {
      if (!project.checkHotReloadSupport()) {
        logger.write('Falling back to hot restart instead of hot reload.', level: Level.warning);
        reloadConfig = ReloadConfiguration.hotRestart;
      }
    }

    final usesDdcLibraryBundles = moduleFormat == 'ddc';

    List<String> additionalFlutterBuildArgs() {
      final sdkKernelPath = p.url.join(
        'kernel',
        flutterVersion.compareTo('3.32.0') >= 0 ? 'ddc_outline.dill' : 'ddc_outline_sound.dill',
      );
      final librariesPath = p.join(webSdkDir, 'libraries.json');
      final ddcSdkPrefix = usesDdcLibraryBundles ? 'ddcLibraryBundle-canvaskit' : 'amd-canvaskit';
      final sdkJsPath = p.join(
        webSdkDir,
        'kernel',
        flutterVersion.compareTo('3.32.0') >= 0 ? ddcSdkPrefix : '$ddcSdkPrefix-sound',
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
      // Enable build_runner debugging
      // '--force-jit',
      // '--dart-jit-vm-arg=--observe',
      // '--dart-jit-vm-arg=--pause-isolates-on-start',
      if (verbose) '--verbose',
      if (release) '--release',
      if (managedBuildOptions) ...[
        '--define=build_web_compilers:ddc=generate-full-dill=true',
        '--define=build_web_compilers:entrypoint=compiler=$compiler',

        // Add DDC Library Bundle defines.
        if (usesDdcLibraryBundles) ...[
          '--define=build_web_compilers:ddc=ddc-library-bundle=true',
          '--define=build_web_compilers:sdk_js=ddc-library-bundle=true',
          '--define=build_web_compilers:entrypoint=ddc-library-bundle=true',
          '--define=build_web_compilers:entrypoint_marker=ddc-library-bundle=true',
        ],

        // Add Web Hot Reload defines.
        if (reloadConfig == ReloadConfiguration.hotReload) ...[
          '--define=build_web_compilers:sdk_js=web-hot-reload=true',
          '--define=build_web_compilers:entrypoint=web-hot-reload=true',
          '--define=build_web_compilers:entrypoint_marker=web-hot-reload=true',
          '--define=build_web_compilers:ddc=web-hot-reload=true',
          '--define=build_web_compilers:ddc_modules=web-hot-reload=true',
        ],
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
      enableDebugging: true,
      useDwdsWebSocketConnection: !launchInChrome,
      reload: reloadConfig,
      moduleFormat: moduleFormat,
      devTools: controller,
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
}

enum DevStatus { ready, rebuilding, error }

String serverEntrypoint(String import) =>
    '''
  import '$import' as m;
  import 'dart:developer';
      
  void main(List<String> args) async {
    final mainFunc = m.main as dynamic;
    final mainCall = mainFunc is dynamic Function(List<String>) ? () => mainFunc(args) : () => mainFunc();

    registerExtension('ext.jaspr.reload', (method, parameters) async {
      await mainCall();
      return ServiceExtensionResponse.result('{}');
    });
    
    mainCall();
  }
''';
