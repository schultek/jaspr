import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../commands/base_command.dart';
import '../logging.dart';
import '../process_runner.dart';
import '../project.dart';

mixin FlutterHelper on BaseCommand {
  Map<String, String> getFlutterDartDefines(bool useWasm, bool release) {
    final flutterDefines = <String, String>{};

    flutterDefines['dart.vm.product'] = '$release';
    flutterDefines['FLUTTER_WEB_USE_SKWASM'] = '$useWasm';
    flutterDefines['FLUTTER_WEB_USE_SKIA'] = '${!useWasm}';

    return flutterDefines;
  }

  Future<Process> serveFlutter(bool wasm) async {
    await _ensureTarget();

    final flutterProcess = await ProcessRunner.instance.start(
      'flutter',
      [
        'run',
        '--device-id=web-server',
        '-t',
        '.dart_tool/jaspr/flutter_target.dart',
        '--web-port=$flutterProxyPort',
        if (wasm) '--wasm',
        if (argResults!.flag('release')) '--release',
      ],
      runInShell: true,
      workingDirectory: Directory.current.path,
    );

    unawaited(watchProcess('flutter run', flutterProcess, tag: Tag.flutter, hide: (_) => !verbose));

    return flutterProcess;
  }

  Future<int> buildFlutter(bool wasm) async {
    await _ensureTarget();

    final flutterProcess = await ProcessRunner.instance.start(
      'flutter',
      [
        'build',
        'web',
        '-t',
        '.dart_tool/jaspr/flutter_target.dart',
        if (wasm) '--wasm' else '--no-wasm-dry-run',
        '--output=build/flutter',
      ],
      runInShell: true,
      workingDirectory: Directory.current.path,
    );

    final exitCode = await watchProcess('flutter build', flutterProcess, tag: Tag.flutter);

    await copyToBuildDir(
      './build/flutter',
      ['version.json', 'flutter_service_worker.js', 'flutter_bootstrap.js', 'assets/', 'canvaskit/'],
    );

    return exitCode;
  }

  Future<void> _ensureTarget() async {
    final flutterTarget = File('.dart_tool/jaspr/flutter_target.dart').absolute;
    if (!await flutterTarget.exists()) {
      await flutterTarget.create(recursive: true);
    }
    await flutterTarget.writeAsString('void main() {}');
  }
}

final flutterInfo = (() {
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

final webSdkDir = (() {
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

final flutterVersion = flutterInfo['flutterVersion'] as String;
