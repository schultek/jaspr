import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../commands/base_command.dart';
import '../config.dart';
import '../logging.dart';

mixin FlutterHelper on BaseCommand {
  Map<String, String> getFlutterDartDefines(bool useWasm, bool release) {
    final flutterDefines = <String, String>{};

    flutterDefines['dart.vm.product'] = '$release';
    flutterDefines['FLUTTER_WEB_USE_SKWASM'] = '$useWasm';
    flutterDefines['FLUTTER_WEB_USE_SKIA'] = '${!useWasm}';

    return flutterDefines;
  }

  Future<Process> serveFlutter(String flutterPort, bool wasm) async {
    await _ensureTarget();

    final flutterProcess = await Process.start(
      'flutter',
      [
        'run',
        '--device-id=web-server',
        '-t',
        '.dart_tool/jaspr/flutter_target.dart',
        '--web-port=$flutterPort',
        if (wasm) '--wasm',
        if (argResults!.flag('release')) '--release',
      ],
      runInShell: true,
      workingDirectory: Directory.current.path,
    );

    unawaited(watchProcess('flutter run', flutterProcess, tag: Tag.flutter, hide: (_) => !verbose));

    return flutterProcess;
  }

  Future<void> buildFlutter(bool wasm) async {
    await _ensureTarget();

    final flutterProcess = await Process.start(
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

    final target = project.requireMode != JasprMode.server ? 'build/jaspr' : 'build/jaspr/web';

    final moveTargets = ['version.json', 'flutter_service_worker.js', 'flutter_bootstrap.js', 'assets/', 'canvaskit/'];

    await watchProcess('flutter build', flutterProcess, tag: Tag.flutter);

    await copyFiles('./build/flutter', target, moveTargets);
  }

  Future<void> _ensureTarget() async {
    final flutterTarget = File('.dart_tool/jaspr/flutter_target.dart').absolute;
    if (!await flutterTarget.exists()) {
      await flutterTarget.create(recursive: true);
    }
    await flutterTarget.writeAsString('void main() {}');
  }
}

Future<void> copyFiles(String from, String to, [List<String> targets = const ['']]) async {
  final moveTargets = [...targets];

  final moves = <Future<void>>[];
  while (moveTargets.isNotEmpty) {
    final moveTarget = moveTargets.removeAt(0);
    final file = File('$from/$moveTarget').absolute;
    final isDir = file.statSync().type == FileSystemEntityType.directory;
    if (isDir) {
      await Directory('$to/$moveTarget').absolute.create(recursive: true);

      final files = Directory('$from/$moveTarget').absolute.list(recursive: true);
      await for (final file in files) {
        final path = p.relative(file.absolute.path, from: p.join(Directory.current.absolute.path, from));
        moveTargets.add(path);
      }
    } else {
      moves.add(file.copy(File('$to/$moveTarget').absolute.path));
    }
  }

  await moves.wait;
}

final flutterInfo = (() {
  final result = Process.runSync(
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
    Process.runSync('flutter', ['precache', '--web'], runInShell: true);
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
