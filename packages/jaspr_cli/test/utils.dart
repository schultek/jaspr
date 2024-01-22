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
    tempDir = Directory(Directory.systemTemp.createTempSync('jaspr_cli_test').resolveSymbolicLinksSync());
    appDir = Directory(p.join(tempDir.path, 'myapp'));
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
  var [cmd, ...args] = command.split(' ');
  var result = await Process.run(cmd, args, runInShell: true, workingDirectory: dir.path);

  var firstArg = command.indexOf('-');
  var prefix = command.substring(0, firstArg != -1 ? firstArg : command.length).trim();

  LineSplitter().convert(result.stdout).forEach((line) {
    print('<$prefix> $line');
  });

  if (result.exitCode != 0) {
    LineSplitter().convert(result.stderr).forEach((line) {
      print('<$prefix> $line');
    });
  }
}

Future<Future<void> Function()> start(String command, {required Directory dir}) async {
  var [cmd, ...args] = command.split(' ');
  var process = await Process.start(cmd, args, runInShell: true, workingDirectory: dir.path);

  bool killed = false;
  addTearDown(() {
    killed = true;
    process.kill(ProcessSignal.sigint);
  });

  var firstArg = command.indexOf('-');
  var prefix = command.substring(0, firstArg != -1 ? firstArg : command.length).trim();

  var done = Completer();

  process.stdout.map(utf8.decode).transform(LineSplitter()).listen((line) {
    print('<$prefix> $line');
  }, onDone: () {
    if (!done.isCompleted) {
      done.complete();
    }
  });

  process.stderr.map(utf8.decode).transform(LineSplitter()).listen((line) {
    print('<$prefix> $line');
  });

  process.exitCode.then((code) {
    if (!killed && code != 0) {
      fail('Process <$prefix> exited with code $code.');
    }
  });

  return () async {
    killed = true;
    print("Stopping <$prefix>.");
    process.kill(ProcessSignal.sigint);
    await done.future.timeout(Duration(seconds: 20), onTimeout: () {});
    await Future.delayed(Duration(seconds: 10));
  };
}
