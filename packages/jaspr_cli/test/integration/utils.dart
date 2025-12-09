// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

({Directory Function() root, Directory Function() app}) setupTempDirs() {
  late Directory tempDir;
  late Directory appDir;

  setUp(() {
    tempDir = Directory(Directory.systemTemp.createTempSync('jaspr_cli_test').resolveSymbolicLinksSync()).absolute;
    appDir = Directory(p.join(tempDir.path, 'myapp')).absolute;
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  return (
    root: () => tempDir,
    app: () => appDir,
  );
}

Future<void> run(String command, {required Directory dir}) async {
  final [cmd, ...args] = command.split(' ');
  final result = await Process.run(cmd, args, runInShell: true, workingDirectory: dir.path);

  final firstArg = command.indexOf('-');
  final prefix = command.substring(0, firstArg != -1 ? firstArg : command.length).trim();

  LineSplitter().convert(result.stdout as String).forEach((line) {
    print('<$prefix> $line');
  });

  if (result.exitCode != 0) {
    LineSplitter().convert(result.stderr as String).forEach((line) {
      print('<$prefix> $line');
    });
  }
}
