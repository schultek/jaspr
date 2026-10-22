// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dwds/data/build_result.dart';
import 'package:dwds/src/loaders/strategy.dart';
import 'package:io/ansi.dart';
import 'package:path/path.dart' as p;

import '../daemon/logger.dart';
import '../dev/dev_workflow.dart';
import '../dev/flutter_runner.dart';
import '../dev/server_runner.dart';
import '../helpers/dart_define_helpers.dart';
import '../helpers/port_helper.dart';
import '../helpers/print_logo.dart';
import '../helpers/proxy_helper.dart';
import '../logging.dart';
import '../project.dart';
import 'base_command.dart';

abstract class DevCommand extends BaseCommand with ProxyHelper {
  DevCommand({super.logger}) {
    argParser.addOption(
      'input',
      abbr: 'i',
      help:
          'Specify the entry file for the server app. Must end in ".server.dart".\n'
          'Defaults to the first found "*.server.dart" file in the project.',
    );
    argParser.addOption(
      'auto',
      abbr: 'a',
      help: 'Perform an automatic action after each rebuild.',
      allowed: ['reload', 'restart', 'refresh'],
      allowedHelp: {
        'reload': 'Hot-reloads both client and server apps',
        'restart': 'Restarts the client app (loses current state)',
        'refresh': 'Performs a full page refresh and server reload',
      },
    );
    argParser.addOption(
      'port',
      abbr: 'p',
      help:
          'Specify a port to run the dev server on. '
          'Defaults to {jaspr.port} from pubspec.yaml or "$defaultServePort".',
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
    argParser.addOption(
      'flutter-target',
      help:
          'Specify the entrypoint of the embedded Flutter app.\n'
          'Defaults to a generated empty entrypoint that only collects the declared assets.',
    );
    addDartDefineArgs();
  }

  @override
  String get category => 'Project';

  late final input = argResults!.option('input');
  late final debug = argResults!.flag('debug');
  late final release = argResults!.flag('release');
  late final auto = argResults!.option('auto');
  late final useWasm = argResults!.flag('experimental-wasm');
  late final moduleFormat = argResults!.option('module-format');
  late final managedBuildOptions = argResults!.flag('managed-build-options');
  late final skipServer = argResults!.flag('skip-server');
  late final flutterTarget = argResults!.option('flutter-target');

  String get compiler => useWasm
      ? 'dart2wasm'
      : release
      ? 'dart2js'
      : 'dartdevc';

  String get effectiveModuleFormat => compiler == 'dartdevc' ? (moduleFormat ?? 'ddc') : 'amd';

  bool get usesDdcLibraryBundles => compiler == 'dartdevc' && effectiveModuleFormat == 'ddc';

  bool canHotReload = false;

  bool _checkHotReloadSupport() {
    if (compiler != 'dartdevc') {
      return false;
    }
    if (effectiveModuleFormat == 'amd') {
      logger.write(
        'The AMD module format does not support hot reload.',
        tag: Tag.cli,
        level: Level.warning,
      );
      return false;
    }
    return project.checkHotReloadSupport();
  }

  bool get launchInChrome;

  DevStatus _currentStatus = DevStatus.ready;
  late int port;

  late final DevWorkflow workflow;

  void handleDevWorkflow(DevWorkflow workflow) {}

  @override
  Future<int> runCommand() async {
    await ensureInProject();
    printLogo();

    final shouldCheckPort = !skipServer || project.requireMode == JasprMode.client;

    final explicitPort = argResults?.option('port');
    if (explicitPort != null) {
      final parsed = int.tryParse(explicitPort);
      if (parsed == null || parsed < 1 || parsed > 65535) {
        logger.write(
          'Invalid port "$explicitPort". Must be a number between 1 and 65535.',
          tag: Tag.cli,
          level: Level.error,
        );
        return 1;
      }
      if (shouldCheckPort && !await isPortAvailable(parsed)) {
        logger.write(
          'Port $explicitPort is already in use.\nPlease quit the running process or choose a different port.',
          tag: Tag.cli,
          level: Level.error,
        );
        return 1;
      }
      port = parsed;
    } else {
      final defaultPort = int.tryParse(project.port ?? defaultServePort) ?? 8080;
      port = shouldCheckPort ? await findAvailablePort(defaultPort) : defaultPort;
    }

    final proxyPort = project.requireMode == JasprMode.client
        ? port
        : await findAvailablePort(int.parse(serverProxyPort), exclude: [port]);

    final flutterPort = project.flutterMode == FlutterMode.embedded
        ? await findAvailablePort(int.parse(flutterProxyPort), exclude: [port, proxyPort])
        : null;

    logger.write('Starting ${cyan.wrap(project.name)} in ${cyan.wrap(project.requireMode.name)} rendering mode.');
    if (!verbose) {
      logger.write('Showing reduced log output. Pass --verbose to see all output.', level: Level.debug);
    }
    logger.write('\n');

    canHotReload = _checkHotReloadSupport();

    final entryPoint = await getServerEntryPoint(input);

    final workflow = await _runWorkflow(proxyPort);
    if (workflow == null) {
      await stop();
      return 1;
    }

    this.workflow = workflow;
    handleDevWorkflow(workflow);

    if (project.flutterMode == FlutterMode.embedded) {
      final flutter = await FlutterRunner.startDev(
        port: flutterPort!,
        wasm: useWasm,
        logger: logger,
        flutterTarget: flutterTarget,
        release: argResults!.flag('release'),
        verbose: verbose,
        guard: guardResource,
      );
      workflow.flutter = flutter;
      flutter.done.then((code) {
        if (code != 0 && !workflow.isShuttingDown && !BaseCommand.isShuttingDown) {
          logger.write('Flutter process stopped unexpectedly.', tag: Tag.flutter, level: Level.error);
          workflow.shutDown(code);
        }
      });
    }

    await startProxy(
      proxyPort,
      devWorkflow: workflow,
      flutterPort: flutterPort,
      redirectNotFound: project.requireMode == JasprMode.client,
      onMessage: (message) async {
        if (message case {'reload': final Object reload}) {
          final String? route = reload is String ? reload : null;
          for (final connection in workflow.clients.connections) {
            try {
              await connection.reloadHtml(route);
            } catch (_) {}
          }
        }
      },
    );

    await workflow.css.initialGenerationComplete;

    if (project.requireMode == JasprMode.client) {
      logger.write('Serving at http://localhost:$proxyPort', tag: Tag.cli);

      if (launchInChrome) {
        await workflow.chrome.launch(port);
      }
    } else if (skipServer) {
      logger.write(
        'Skipping server as per --skip-server flag.\n'
        'Make sure to set the JASPR_PROXY_PORT=$proxyPort environment variable when starting the server manually.',
        tag: Tag.cli,
        level: Level.warning,
      );
    } else {
      final server = await ServerRunner.startDev(
        entryPoint: entryPoint!,
        port: port,
        proxyPort: proxyPort,
        project: project,
        logger: logger,
        userDefines: getServerDartDefines(),
        restArgs: argResults!.rest,
        release: release,
        debug: debug,
        guard: guardResource,
      );
      if (server == null) {
        if (!workflow.isShuttingDown && !BaseCommand.isShuttingDown) {
          await workflow.shutDown(1);
          return 1;
        }
        return 0;
      }
      workflow.server = server;
      server.done.then((code) {
        if (!workflow.isShuttingDown && !BaseCommand.isShuttingDown) {
          workflow.shutDown(code);
        }
      });
      if (launchInChrome) {
        await workflow.chrome.launch(port);
      }
    }

    updateFooter(DevStatus.ready);

    if (stdout.hasTerminal && !Platform.isWindows && IOOverrides.current == null) {
      try {
        final resizeSub = ProcessSignal.sigwinch.watch().listen((_) {
          updateFooter(_currentStatus);
        });
        guardResource(() async {
          await resizeSub.cancel();
        });
      } catch (_) {}
    }

    _setupKeyHandler();

    return await workflow.done;
  }

  void updateFooter(DevStatus status) {
    _currentStatus = status;
    final width = stdout.hasTerminal ? stdout.terminalColumns : 80;
    final availableWidth = width > 1 ? width - 1 : width;
    final leftText = ' Serving on http://localhost:$port';
    final rightText = switch (status) {
      DevStatus.ready => 'All ready ',
      DevStatus.rebuilding => 'Rebuilding... ',
      DevStatus.error => 'Errors occurred. Fix and save to retry. ',
    };

    final String footerContent;
    if (leftText.length + rightText.length <= availableWidth) {
      final spaces = availableWidth - leftText.length - rightText.length;
      footerContent = '$leftText${' ' * spaces}$rightText';
    } else if (leftText.length <= availableWidth) {
      final spaces = availableWidth - leftText.length;
      footerContent = '$leftText${' ' * spaces}';
    } else {
      footerContent = leftText.substring(0, availableWidth);
    }

    final footerColor = switch (status) {
      DevStatus.ready => backgroundGreen,
      DevStatus.rebuilding => backgroundYellow,
      DevStatus.error => backgroundRed,
    };
    final footerLine = footerColor.wrap(black.wrap(styleBold.wrap(footerContent)))!;

    List<String> getKeys(bool showColons, bool shortChrome, bool minimal) {
      if (minimal) {
        return [
          if (canHotReload) '${styleBold.wrap('[r]')}',
          '${styleBold.wrap('[R]')}',
          '${styleBold.wrap('[l]')}',
          '${styleBold.wrap('[d]')}',
          '${styleBold.wrap('[q]')}',
        ];
      }
      final c = showColons ? ':' : '';
      final chromeName = shortChrome ? 'Chrome' : 'Launch Chrome';
      return [
        if (canHotReload) '${styleBold.wrap('[r]$c')} Reload',
        '${styleBold.wrap('[R]$c')} Restart',
        '${styleBold.wrap('[l]$c')} $chromeName',
        '${styleBold.wrap('[d]$c')} DevTools',
        '${styleBold.wrap('[q]$c')} Quit',
      ];
    }

    List<String> getRawKeys(bool showColons, bool shortChrome, bool minimal) {
      if (minimal) {
        return [
          if (canHotReload) '[r]',
          '[R]',
          '[l]',
          '[d]',
          '[q]',
        ];
      }
      final c = showColons ? ':' : '';
      final chromeName = shortChrome ? 'Chrome' : 'Launch Chrome';
      return [
        if (canHotReload) '[r]$c Reload',
        '[R]$c Restart',
        '[l]$c $chromeName',
        '[d]$c DevTools',
        '[q]$c Quit',
      ];
    }

    String dot = (availableWidth >= 88) ? '  ·  ' : ' · ';
    var selectedKeys = getKeys(true, false, false);
    var selectedRaw = getRawKeys(true, false, false);

    if (' ${selectedRaw.join(dot)}'.length > availableWidth) {
      dot = ' · ';
    }
    if (' ${selectedRaw.join(dot)}'.length > availableWidth) {
      selectedKeys = getKeys(true, true, false);
      selectedRaw = getRawKeys(true, true, false);
    }
    if (' ${selectedRaw.join(dot)}'.length > availableWidth) {
      selectedKeys = getKeys(false, true, false);
      selectedRaw = getRawKeys(false, true, false);
    }
    if (' ${selectedRaw.join(dot)}'.length > availableWidth) {
      selectedKeys = getKeys(false, false, true);
      selectedRaw = getRawKeys(false, false, true);
    }

    while (selectedKeys.length > 1 && ' ${selectedRaw.join(dot)}'.length > availableWidth) {
      selectedKeys.removeLast();
      selectedRaw.removeLast();
    }

    final content = ' ${selectedKeys.join(dot)}';
    final keysLine = darkGray.wrap(content)!;

    logger.setFooter([
      '',
      '',
      footerLine,
      keysLine,
    ]);
  }

  void _setupKeyHandler() {
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
    var isHandling = false;

    sub = stdin.listen((bytes) async {
      for (final byte in bytes) {
        // Handle Ctrl+C (ETX) or Ctrl+D (EOT).
        if (byte == 3 || byte == 4) {
          shutdown();
          return;
        }

        // Filter out ANSI escape sequences (e.g. arrow keys) so their trailing
        // characters are not mistakenly processed as shortcut keys.
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
            // CSI sequences terminate on bytes 64-126 (@ to ~).
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
        // Ignore input while an operation is running, but still allow quit.
        if (isHandling && char != 'q') {
          continue;
        }

        isHandling = true;
        try {
          await _handleKey(char);
        } finally {
          isHandling = false;
        }
      }
    });

    guardResource(() async {
      await sub?.cancel();
    });
  }

  bool _isPerformingAction = false;

  Future<void> _performReload() async {
    if (_isPerformingAction) return;
    _isPerformingAction = true;
    logger.write('Reloading...', tag: Tag.client);
    try {
      await workflow.reloadClients();
      logger.write('Reload complete.', tag: Tag.client);
    } catch (e) {
      logger.write('Failed to reload: $e', tag: Tag.cli, level: Level.warning);
    } finally {
      _isPerformingAction = false;
    }
  }

  Future<void> _performRestart() async {
    if (_isPerformingAction) return;
    _isPerformingAction = true;
    logger.write('Restarting...', tag: Tag.client);
    try {
      await workflow.restartClients();
      logger.write('Restart complete.', tag: Tag.client);
    } catch (e) {
      logger.write('Failed to restart: $e', tag: Tag.cli, level: Level.warning);
    } finally {
      _isPerformingAction = false;
    }
  }

  Future<void> _handleKey(String key) async {
    switch (key) {
      case 'r' when canHotReload:
        if (workflow.isBuilding) {
          if (workflow.queuedAction == QueuedAction.restart) {
            logger.write('Build in progress. Restart already queued.', tag: Tag.client);
          } else if (workflow.queuedAction == QueuedAction.reload) {
            logger.write('Build in progress. Reload already queued.', tag: Tag.client);
          } else {
            workflow.queueAction(QueuedAction.reload);
            logger.write('Build in progress. Queued reload...', tag: Tag.client);
          }
        } else {
          await _performReload();
        }
      case 'R':
        if (workflow.isBuilding) {
          if (workflow.queuedAction == QueuedAction.restart) {
            logger.write('Build in progress. Restart already queued.', tag: Tag.client);
          } else {
            workflow.queueAction(QueuedAction.restart);
            logger.write('Build in progress. Queued restart...', tag: Tag.client);
          }
        } else {
          await _performRestart();
        }
      case 'l':
        await workflow.chrome.launch(port);
      case 'd':
        final clientUri = workflow.clientDevToolsUri;
        final serverUri = workflow.serverDevToolsUri;

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
        await workflow.shutDown();
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

  Future<DevWorkflow?> _runWorkflow(int proxyPort) async {
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
      dartDefines.addAll(FlutterRunner.getDartDefines(useWasm, release));
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
        '--extra-compiler-option=--platform=${p.join(FlutterRunner.webSdkDir, 'kernel', 'dart2wasm_platform.dill')}',
      for (final e in dartDefines.entries) '-D${e.key}=${e.value}',
    ];

    var reloadConfig = switch (auto) {
      'reload' => ReloadConfiguration.hotReload,
      'refresh' => ReloadConfiguration.liveReload,
      'restart' => ReloadConfiguration.hotRestart,
      _ => ReloadConfiguration.none,
    };

    if (reloadConfig == ReloadConfiguration.hotReload && !canHotReload) {
      logger.write('Falling back to hot restart instead of hot reload.', tag: Tag.cli, level: Level.warning);
      reloadConfig = ReloadConfiguration.hotRestart;
    }

    if (compiler != 'dartdevc') {
      reloadConfig = reloadConfig == ReloadConfiguration.none
          ? ReloadConfiguration.none
          : ReloadConfiguration.liveReload;
    }

    List<String> additionalFlutterBuildArgs() {
      final sdkKernelPath = p.url.join('kernel', 'ddc_outline.dill');
      final librariesPath = p.join(FlutterRunner.webSdkDir, 'libraries.json');
      final ddcSdkPrefix = usesDdcLibraryBundles ? 'ddcLibraryBundle-canvaskit' : 'amd-canvaskit';
      final sdkJsPath = p.join(FlutterRunner.webSdkDir, 'kernel', ddcSdkPrefix);
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
          '--define=build_web_compilers:ddc=platform-sdk=${jsonEncode(FlutterRunner.webSdkDir)}',
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
        if (canHotReload) ...[
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

    final workflow = await DevWorkflow.start(
      proxyPort: proxyPort,
      buildArgs: buildArgs,
      project: project,
      logger: logger,
      guard: guardResource,
      enableDebugging: true,
      launchInChrome: launchInChrome,
      reload: reloadConfig,
      moduleFormat: effectiveModuleFormat,
    );
    if (workflow == null) {
      return null;
    }

    workflow.buildResults.listen((event) async {
      if (event.status == BuildStatus.succeeded) {
        logger.write('Rebuilt web assets.', tag: Tag.builder, progress: ProgressState.completed);
        updateFooter(DevStatus.ready);
        final queuedAction = workflow.takeQueuedAction();
        if (queuedAction == QueuedAction.reload) {
          await _performReload();
        } else if (queuedAction == QueuedAction.restart) {
          await _performRestart();
        }
      } else if (event.status == BuildStatus.failed) {
        logger.write(
          'Failed building web assets. There is probably more output above.',
          tag: Tag.builder,
          level: Level.error,
          progress: ProgressState.completed,
        );
        updateFooter(DevStatus.error);
        final queuedAction = workflow.takeQueuedAction();
        if (queuedAction != null) {
          logger.write('Build failed. Skipped queued ${queuedAction.name}.', tag: Tag.client);
        }
      } else if (event.status == BuildStatus.started) {
        logger.write('Rebuilding web assets...', tag: Tag.builder, progress: ProgressState.running);
        updateFooter(DevStatus.rebuilding);
      }
    });

    return workflow;
  }
}

enum DevStatus { ready, rebuilding, error }
