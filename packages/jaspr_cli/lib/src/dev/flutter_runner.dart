import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../commands/base_command.dart';
import '../logging.dart';
import '../process_runner.dart';

class FlutterRunner {
  FlutterRunner._(
    this.process,
    this.logger, {
    this.errSub,
    this.outSub,
  });

  final Process process;
  final Logger logger;
  final StreamSubscription<void>? errSub;
  final StreamSubscription<void>? outSub;
  final _doneCompleter = Completer<int>();

  Future<int> get done => _doneCompleter.future;

  bool _stopped = false;

  static Map<String, String> getDartDefines(bool useWasm, bool release) {
    final flutterDefines = <String, String>{};

    flutterDefines['dart.vm.product'] = '$release';
    flutterDefines['FLUTTER_WEB_USE_SKWASM'] = '$useWasm';
    flutterDefines['FLUTTER_WEB_USE_SKIA'] = '${!useWasm}';

    return flutterDefines;
  }

  static Future<FlutterRunner> startDev({
    required int port,
    required bool wasm,
    required Logger logger,
    bool release = false,
    bool verbose = false,
    void Function(FutureOr<void> Function())? guard,
  }) async {
    await _ensureTarget();

    final flutterProcess = await ProcessRunner.instance.start(
      'flutter',
      [
        'run',
        '--device-id=web-server',
        '-t',
        '.dart_tool/jaspr/flutter_target.dart',
        '--web-port=$port',
        if (wasm) '--wasm',
        if (release) '--release',
      ],
      runInShell: true,
      workingDirectory: Directory.current.path,
    );

    var stopped = false;

    final errSub = flutterProcess.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (BaseCommand.isShuttingDown || stopped) return;
      logger.write(line, tag: Tag.flutter, level: Level.error, progress: ProgressState.completed);
    });

    final outSub = flutterProcess.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((log) {
      if (!verbose || BaseCommand.isShuttingDown || stopped) return;
      logger.write(log, tag: Tag.flutter, level: Level.info);
    });

    final runner = FlutterRunner._(
      flutterProcess,
      logger,
      errSub: errSub,
      outSub: outSub,
    );

    flutterProcess.exitCode.then((code) {
      errSub.cancel();
      outSub.cancel();
      if (!runner._doneCompleter.isCompleted) {
        runner._doneCompleter.complete(code);
      }
    });

    guard?.call(() {
      stopped = true;
      return runner.stop();
    });

    return runner;
  }

  static Future<int> build({
    required bool wasm,
    required Logger logger,
    required Future<void> Function(String from, [List<String> targets]) copyToBuildDir,
    void Function(FutureOr<void> Function())? guard,
  }) async {
    await _ensureTarget();

    final flutterProcess = await ProcessRunner.instance.start(
      'flutter',
      [
        'build',
        'web',
        '-t',
        '.dart_tool/jaspr/flutter_target.dart',
        if (wasm) '--wasm' else '--no-wasm-dry-run',
        '--no-tree-shake-icons',
        '--output=build/flutter',
      ],
      runInShell: true,
      workingDirectory: Directory.current.path,
    );

    final errSub = flutterProcess.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      logger.write(line, tag: Tag.flutter, level: Level.error, progress: ProgressState.completed);
    });

    final outSub = flutterProcess.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((log) {
      logger.write(log, tag: Tag.flutter, level: Level.info);
    });

    int? exitCode;
    bool wasKilled = false;
    guard?.call(() async {
      if (exitCode == null) {
        logger.write('Terminating flutter build...', level: Level.debug);
        flutterProcess.kill();
        wasKilled = true;
        await errSub.cancel();
        await outSub.cancel();
        await flutterProcess.exitCode;
      }
    });

    exitCode = await flutterProcess.exitCode.then<int>((c) => Future.delayed(const Duration(seconds: 1), () => c));

    if (wasKilled) {
      return exitCode;
    }

    await errSub.cancel();
    await outSub.cancel();

    await copyToBuildDir(
      './build/flutter',
      ['version.json', 'flutter_service_worker.js', 'flutter_bootstrap.js', 'assets/', 'canvaskit/'],
    );

    return exitCode;
  }

  void reload() {
    process.stdin.writeln('r');
  }

  void restart() {
    process.stdin.writeln('R');
  }

  Future<void> stop() async {
    if (_stopped) return;
    _stopped = true;
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete(0);
    }
    await errSub?.cancel();
    await outSub?.cancel();
    logger.write('Terminating flutter run...', level: Level.debug);
    process.kill();
    await process.exitCode;
  }

  static Future<void> _ensureTarget() async {
    final flutterTarget = File('.dart_tool/jaspr/flutter_target.dart').absolute;
    if (!await flutterTarget.exists()) {
      await flutterTarget.create(recursive: true);
    }
    await flutterTarget.writeAsString('void main() {}');
  }

  static final Map<String, Object?> flutterInfo = (() {
    final result = ProcessRunner.instance.runSync(
      'flutter',
      ['doctor', '--version', '--machine'],
      stdoutEncoding: utf8,
      runInShell: true,
    );
    if (result.exitCode < 0) {
      throw UnsupportedError(
        'Calling "flutter doctor" resulted in: "${result.stderr}". '
        'Make sure flutter is installed and setup correctly.',
      );
    }
    final Map<String, Object?> output;
    try {
      output = jsonDecode(result.stdout as String) as Map<String, Object?>;
    } catch (e) {
      throw UnsupportedError(
        'Could not find flutter web sdk. '
        'Calling "flutter doctor" resulted in: "${result.stdout}". '
        'Make sure flutter is installed and setup correctly. '
        'If you think this is a bug, open an issue at https://github.com/schultek/jaspr/issues',
      );
    }
    return output;
  })();

  static final String webSdkDir = (() {
    final webSdkPath = p.join(flutterInfo['flutterRoot'] as String, 'bin', 'cache', 'flutter_web_sdk');
    if (!Directory(webSdkPath).existsSync()) {
      ProcessRunner.instance.runSync('flutter', ['precache', '--web'], runInShell: true);
    }
    if (!Directory(webSdkPath).existsSync()) {
      throw UnsupportedError(
        'Could not find flutter web sdk in $webSdkPath. '
        'Make sure flutter is installed and setup correctly. '
        'If you think this is a bug, open an issue at https://github.com/schultek/jaspr/issues',
      );
    }
    return webSdkPath;
  })();
}
