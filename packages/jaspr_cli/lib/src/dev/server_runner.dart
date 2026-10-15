import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

import '../commands/base_command.dart';
import '../logging.dart';
import '../process_runner.dart';
import '../project.dart';

/// Manages the server process lifecycle, log watching, and VM service reload.
class ServerRunner {
  ServerRunner._({
    required this.process,
    required this.logger,
  });

  final Process process;
  final Logger logger;

  String? _vmServiceUri;
  String? _devToolsUri;
  vm.VmService? _vmService;
  final _doneCompleter = Completer<int>();

  String? get vmServiceUri => _vmServiceUri;
  String? get devToolsUri => _devToolsUri;
  vm.VmService? get vmService => _vmService;
  Future<int> get done => _doneCompleter.future;

  /// Starts the server process for development with hot reload and VM service support.
  static Future<ServerRunner?> startDev({
    required String entryPoint,
    required int port,
    required int proxyPort,
    required Project project,
    required Logger logger,
    required Map<String, String> userDefines,
    required List<String> restArgs,
    bool release = false,
    bool debug = false,
    void Function(FutureOr<void> Function())? guard,
  }) async {
    logger.write('Starting server...', tag: Tag.server, progress: ProgressState.running);
    logger.write('Using server entry point: $entryPoint', tag: Tag.server, level: Level.verbose);

    if (!entryPoint.startsWith('lib/')) {
      logger.write(
        'Server entry point is not located inside lib/ folder, disabling server-side hot-reload.',
        tag: Tag.server,
        level: Level.warning,
      );
    }

    final useServerReload = entryPoint.startsWith('lib/') && !release;

    final serverTarget = File('.dart_tool/jaspr/server_target.dart').absolute;
    if (useServerReload && !serverTarget.existsSync()) {
      serverTarget.createSync(recursive: true);
    }

    final args = [
      // Use direct `dart` entry point for now due to
      // https://github.com/dart-lang/sdk/issues/61373
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
      serverTarget.writeAsStringSync(_serverEntrypoint(import));
      args.add(serverTarget.path);
    } else {
      args.add(entryPoint);
    }

    args.addAll(restArgs);

    final process = await ProcessRunner.instance.start(
      dartExecutable,
      args,
      environment: {'PORT': '$port', 'JASPR_PROXY_PORT': '$proxyPort'},
      workingDirectory: Directory.current.absolute.path,
    );

    final runner = ServerRunner._(process: process, logger: logger);

    guard?.call(() {
      runner.stop();
    });

    Future<void> connectToVmService([int retries = 2]) async {
      if (runner._vmServiceUri == null) return;
      try {
        final wsUri = '${runner._vmServiceUri!.replaceFirst('http', 'ws')}ws';
        final currentVmService = runner._vmService = await vmServiceConnectUri(wsUri);

        currentVmService.onDone.then((_) {
          if (currentVmService == runner._vmService) {
            runner._vmService = null;
            Future.delayed(const Duration(seconds: 1), () => connectToVmService());
          }
        });
      } catch (e) {
        if (retries > 0) {
          Future.delayed(const Duration(seconds: 1), () => connectToVmService(retries - 1));
        } else {
          logger.write('Failed to connect to server VM service: $e', tag: Tag.cli, level: Level.warning);
        }
      }
    }

    var serverClosed = false;

    final errSub = process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((String line) {
      if (runner._stopped || BaseCommand.isShuttingDown) return;
      logger.write(line, tag: Tag.server, level: Level.error, progress: ProgressState.completed);
    });

    final outSub = process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((String log) {
      if (runner._devToolsUri == null) {
        final match = RegExp(r'The Dart DevTools debugger and profiler is available at:\s*(http://[^\s]+)')
            .firstMatch(log);
        if (match != null) {
          runner._devToolsUri = match.group(1)!;
        }
      }
      if (runner._vmServiceUri == null) {
        final match = RegExp(r'The Dart VM service is listening on (http://[a-zA-Z0-9:/_=\-\.\?]+)').firstMatch(log);
        if (match != null) {
          runner._vmServiceUri = match.group(1)!;
          connectToVmService();
        }
      }
      final level =
          (log.startsWith('The Dart VM service is listening') ||
              log.startsWith('The Dart DevTools debugger and profiler is available'))
          ? Level.verbose
          : Level.info;
      logger.write(log, tag: Tag.server, level: level);
    });

    process.exitCode.then((int code) {
      serverClosed = true;
      runner._vmService = null;
      errSub.cancel();
      outSub.cancel();
      // Ignore normal exit (0) and termination via interruption signals:
      // - 130 / -2: SIGINT (Ctrl+C). 130 is 128 + 2 (POSIX shell convention); -2 is Dart's negative signal code.
      // - 143 / -15: SIGTERM. 143 is 128 + 15; -15 is Dart's negative signal code.
      if (!runner._stopped &&
          !BaseCommand.isShuttingDown &&
          code != 0 &&
          code != 130 &&
          code != -2 &&
          code != 143 &&
          code != -15) {
        logger.write(
          'Server stopped unexpectedly. There is probably more output above.',
          tag: Tag.cli,
          level: Level.error,
          progress: ProgressState.completed,
        );
      }
      if (!runner._doneCompleter.isCompleted) {
        runner._doneCompleter.complete(code);
      }
    });

    // Wait until server is reachable.
    var n = 0;
    final sw = Stopwatch()..start();

    while (true) {
      await Future<void>.delayed(Duration(milliseconds: 1000 + (n * 100)));
      try {
        final socket = await Socket.connect('localhost', port);
        socket.close();
        sw.stop();
        break;
      } on SocketException catch (_) {}

      if (serverClosed) {
        sw.stop();
        return null;
      }

      n++;
      if (n >= 10) {
        sw.stop();
        logger.write(
          'Server at http://localhost:$port not reachable after ${sw.elapsed.inSeconds} seconds. Please check the server logs for errors.',
          tag: Tag.cli,
          level: Level.warning,
        );
        return null;
      }
    }

    logger.write(
      'Server started and listening on http://localhost:$port',
      tag: Tag.server,
      progress: ProgressState.completed,
    );

    return runner;
  }

  /// Starts the server process for static generation.
  static Future<ServerRunner> startForGeneration({
    required String entryPoint,
    required int port,
    required int proxyPort,
    required Map<String, String> serverDefines,
    required Logger logger,
    required Completer<void> serverStartedCompleter,
    void Function(FutureOr<void> Function())? guard,
  }) async {
    logger.write('Starting server for static rendering...', tag: Tag.server, progress: ProgressState.running);

    final process = await ProcessRunner.instance.start(
      dartExecutable,
      [
        // Use direct `dart` entry point for now due to
        // https://github.com/dart-lang/sdk/issues/61373
        // 'run',
        '--enable-asserts',
        '-Djaspr.flags.release=true',
        '-Djaspr.flags.generate=true',
        '-Djaspr.dev.web=build/jaspr',
        for (final define in serverDefines.entries) '-D${define.key}=${define.value}',
        entryPoint,
      ],
      environment: {'PORT': '$port', 'JASPR_PROXY_PORT': '$proxyPort'},
      workingDirectory: Directory.current.path,
    );

    final runner = ServerRunner._(process: process, logger: logger);

    guard?.call(() {
      runner.stop();
    });

    final errSub = process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((String line) {
      logger.write(line, tag: Tag.server, level: Level.error);
    });
    final outSub = process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((String log) {
      logger.write(log, tag: Tag.server);
    });

    process.exitCode.then((int code) {
      errSub.cancel();
      outSub.cancel();
      if (!runner._stopped &&
          !BaseCommand.isShuttingDown &&
          code != 0 &&
          code != 130 &&
          code != -2 &&
          code != 143 &&
          code != -15) {
        logger.write('Server process stopped unexpectedly.', level: Level.error, progress: ProgressState.completed);
      }
      if (!serverStartedCompleter.isCompleted) {
        serverStartedCompleter.completeError(StateError('Server process failed unexpectedly.'));
      }
      if (!runner._doneCompleter.isCompleted) {
        runner._doneCompleter.complete(code);
      }
    });

    await serverStartedCompleter.future;
    logger.write('Server started', tag: Tag.server, progress: ProgressState.completed);

    return runner;
  }

  Future<void> reload() async {
    if (_vmService case final vmService?) {
      try {
        final vmObj = await vmService.getVM();
        final mainIsolate = vmObj.isolates!.first;
        final report = await vmService.reloadSources(mainIsolate.id!);
        if (report.success ?? false) {
          await vmService.callServiceExtension('ext.jaspr.reload', isolateId: mainIsolate.id!);
          logger.write('Server reloaded.', tag: Tag.server);
        } else {
          logger.write('Failed to reload server.', tag: Tag.server, level: Level.warning);
        }
      } catch (e) {
        logger.write('Failed to reload server: $e', tag: Tag.server, level: Level.warning);
      }
    }
  }

  bool _stopped = false;
  Future<void> stop() async {
    if (_stopped) return;
    _stopped = true;
    logger.write('Stopping server...', level: Level.debug);
    _vmService?.dispose();
    _vmService = null;
    process.kill();
  }
}

String _serverEntrypoint(String import) =>
    '''
  import '$import' as m;
  import 'dart:developer';
  import 'dart:io';
      
  void main(List<String> args) async {
    stdin.listen(null, onDone: () => exit(0));

    final mainFunc = m.main as dynamic;
    final mainCall = mainFunc is dynamic Function(List<String>) ? () => mainFunc(args) : () => mainFunc();

    registerExtension('ext.jaspr.reload', (method, parameters) async {
      await mainCall();
      return ServiceExtensionResponse.result('{}');
    });
    
    mainCall();
  }
''';
