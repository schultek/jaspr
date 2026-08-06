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
  late final useWasm = argResults!.flag('experimental-wasm');
  late final moduleFormat = argResults!.option('module-format');
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

    handleClientWorkflow(workflow);

    final cssRunner = await watchCss(workflow);

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

    String? vmServiceUri;
    vm.VmService? vmService;

    Future<void> connectToVmService([int retries = 2]) async {
      if (vmServiceUri == null) return;
      try {
        final wsUri = '${vmServiceUri!.replaceFirst('http', 'ws')}ws';
        final currentVmService = vmService = await vmServiceConnectUri(wsUri);

        currentVmService.onDone.then((_) {
          if (currentVmService == vmService) {
            vmService = null;
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
      vmService = null;
      currentVmService?.dispose();
    });

    final serverFuture = watchProcess(
      'server',
      process,
      tag: Tag.server,
      hide: (log) {
        if (mode != 'none' && vmServiceUri == null) {
          final match = RegExp(r'The Dart VM service is listening on (http://[a-zA-Z0-9:/_=\-\.\?]+)').firstMatch(log);
          if (match != null) {
            vmServiceUri = match.group(1)!;
            connectToVmService();
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
      workflow.devProxy.registerPostReloadCallback(() async {
        if (vmService case final vmService?) {
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
      });
    }

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
      if (release) '--release',
      '--delete-conflicting-outputs',
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
