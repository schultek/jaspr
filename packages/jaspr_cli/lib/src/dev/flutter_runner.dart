import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../logging.dart';
import '../process_runner.dart';
import 'util.dart';

/// Entrypoint used when the project does not provide one.
///
/// It is empty on purpose: Flutter only needs a valid program to collect assets.
const _defaultFlutterTarget = '.dart_tool/jaspr/flutter_target.dart';

class FlutterRunner {
  FlutterRunner._(
    this.process,
    this.logger,
  );

  final Process process;
  final Logger logger;
  ProcessWatcher? _watcher;
  final _doneCompleter = Completer<int>();

  Future<int> get done => _doneCompleter.future;

  bool _stopped = false;

  static Map<String, String> getDartDefines(bool useWasm, bool release) {
    return <String, String>{
      'dart.vm.product': '$release',
      'FLUTTER_WEB_USE_SKWASM': '$useWasm',
      'FLUTTER_WEB_USE_SKIA': '${!useWasm}',
    };
  }

  static Future<FlutterRunner> startDev({
    required int port,
    required bool wasm,
    required Logger logger,
    String? flutterTarget,
    bool release = false,
    bool verbose = false,
    void Function(FutureOr<void> Function())? guard,
  }) async {
    await _ensureTarget(flutterTarget);

    final flutterProcess = await ProcessRunner.instance.start(
      'flutter',
      [
        'run',
        '--device-id=web-server',
        '-t',
        flutterTarget ?? _defaultFlutterTarget,
        '--web-port=$port',
        if (wasm) '--wasm',
        if (release) '--release',
      ],
      runInShell: true,
      workingDirectory: Directory.current.path,
    );

    final runner = FlutterRunner._(
      flutterProcess,
      logger,
    );

    runner._watcher = ProcessWatcher(
      flutterProcess,
      logger: logger,
      tag: Tag.flutter,
      verbose: verbose,
      onExit: (code) {
        if (!runner._doneCompleter.isCompleted) {
          runner._doneCompleter.complete(code);
        }
      },
    );

    guard?.call(() {
      return runner.stop();
    });

    return runner;
  }

  static Future<int> build({
    required bool wasm,
    required Logger logger,
    required Future<void> Function(String from, [List<String> targets]) copyToBuildDir,
    String? flutterTarget,
    void Function(FutureOr<void> Function())? guard,
  }) async {
    await _ensureTarget(flutterTarget);

    final flutterProcess = await ProcessRunner.instance.start(
      'flutter',
      [
        'build',
        'web',
        '-t',
        flutterTarget ?? _defaultFlutterTarget,
        if (wasm) '--wasm' else '--no-wasm-dry-run',
        // The empty default target has no icons to shake, so the declared fonts
        // would be stripped entirely; a real target makes the subsetting correct.
        if (flutterTarget == null) '--no-tree-shake-icons',
        '--output=build/flutter',
      ],
      runInShell: true,
      workingDirectory: Directory.current.path,
    );

    final exitCode = await watchProcess(
      'flutter build',
      flutterProcess,
      logger: logger,
      tag: Tag.flutter,
      guard: guard,
    );

    if (exitCode == 0) {
      await copyToBuildDir(
        './build/flutter',
        ['version.json', 'flutter_service_worker.js', 'flutter_bootstrap.js', 'assets/', 'canvaskit/'],
      );
    }

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
    await _watcher?.stop(message: 'Stopping flutter run...');
  }

  static Future<void> _ensureTarget(String? flutterTarget) async {
    // A configured entrypoint belongs to the project and stays untouched.
    if (flutterTarget != null) return;

    final targetFile = File(_defaultFlutterTarget).absolute;
    if (!await targetFile.exists()) {
      await targetFile.create(recursive: true);
    }
    await targetFile.writeAsString('void main() {}');
  }

  static final Map<String, Object?> _flutterInfo = (() {
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
    final webSdkPath = p.join(_flutterInfo['flutterRoot'] as String, 'bin', 'cache', 'flutter_web_sdk');
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
