import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../commands/base_command.dart';
import '../config.dart';
import '../logging.dart';

mixin FlutterHelper on BaseCommand {
  Future<Process> serveFlutter(String flutterPort) async {
    await _ensureTarget();

    var flutterProcess = await Process.start(
      'flutter',
      [
        'run',
        '--device-id=web-server',
        '-t',
        '.dart_tool/jaspr/flutter_target.dart',
        '--web-port=$flutterPort',
        '--web-renderer=canvaskit',
        if (argResults!['release']) '--release'
      ],
      runInShell: true,
      workingDirectory: Directory.current.path,
    );

    unawaited(watchProcess('flutter run', flutterProcess, tag: Tag.flutter, hide: (_) => !verbose));

    return flutterProcess;
  }

  Future<void> buildFlutter() async {
    await _ensureTarget();

    var flutterProcess = await Process.start(
      'flutter',
      ['build', 'web', '-t', '.dart_tool/jaspr/flutter_target.dart', '--output=build/flutter'],
      runInShell: true,
      workingDirectory: Directory.current.path,
    );

    var target = config!.mode != JasprMode.server ? 'build/jaspr' : 'build/jaspr/web';

    var moveTargets = [
      'version.json',
      'flutter_service_worker.js',
      'flutter_bootstrap.js',
      'assets/',
      'canvaskit/',
    ];

    await watchProcess('flutter build', flutterProcess, tag: Tag.flutter);

    await copyFiles('./build/flutter', target, moveTargets);
  }

  Future<void> _ensureTarget() async {
    var flutterTarget = File('.dart_tool/jaspr/flutter_target.dart').absolute;
    if (!await flutterTarget.exists()) {
      await flutterTarget.create(recursive: true);
    }
    await flutterTarget.writeAsString('void main() {}');
  }
}

Future<void> copyFiles(String from, String to, [List<String> targets = const ['']]) async {
  var moveTargets = [...targets];

  var moves = <Future>[];
  while (moveTargets.isNotEmpty) {
    var moveTarget = moveTargets.removeAt(0);
    var file = File('$from/$moveTarget').absolute;
    var isDir = file.statSync().type == FileSystemEntityType.directory;
    if (isDir) {
      await Directory('$to/$moveTarget').absolute.create(recursive: true);

      var files = Directory('$from/$moveTarget').absolute.list(recursive: true);
      await for (var file in files) {
        final path = p.relative(file.absolute.path, from: p.join(Directory.current.absolute.path, from));
        moveTargets.add(path);
      }
    } else {
      moves.add(file.copy(File('$to/$moveTarget').absolute.path));
    }
  }

  await Future.wait(moves);
}
