import 'dart:async';

import 'package:file/memory.dart';
import 'package:jaspr_cli/src/commands/base_command.dart';
import 'package:test/test.dart';

import '../fakes/fake_io.dart';
import '../fakes/fake_project.dart';

void main() {
  group('copyToBuildDir', () {
    const sourceRoot = '/root/myapp/generated';
    const outputRoot = '/root/myapp/build/jaspr';

    late FakeIO io;
    late _TestCommand command;
    late List<String> copiedPaths;

    void writeFiles(Map<String, String> files) {
      for (final file in files.entries) {
        io.fs.file('$sourceRoot/${file.key}')
          ..createSync(recursive: true)
          ..writeAsStringSync(file.value);
      }
    }

    void expectFilesCopiedOnce(Map<String, String> files) {
      expect(copiedPaths, unorderedEquals(files.keys.map((path) => '$sourceRoot/$path')));
      for (final file in files.entries) {
        expect(io.fs.file('$outputRoot/${file.key}').readAsStringSync(), file.value);
      }
    }

    setUp(() {
      copiedPaths = [];
      io = FakeIO(
        fileSystemOpHandler: (context, operation) {
          if (operation == FileSystemOp.copy) {
            copiedPaths.add(context);
          }
        },
      );
      io.setupFakeProject('myapp');
      command = _TestCommand();
    });

    test('copies each file in nested directories exactly once', () async {
      await io.runZoned(() async {
        const files = {
          'root.txt': 'root',
          'assets/nested/deep.txt': 'deep',
          'assets/other.txt': 'other',
        };
        writeFiles(files);
        io.fs.directory('$sourceRoot/empty').createSync(recursive: true);

        await command.copy('generated');

        expectFilesCopiedOnce(files);
        expect(io.fs.directory('$outputRoot/empty').existsSync(), isTrue);
      });
    });

    test('does not recopy descendants selected by overlapping targets', () async {
      await io.runZoned(() async {
        const files = {
          'assets/nested/deep.txt': 'deep',
          'assets/other.txt': 'other',
        };
        writeFiles(files);

        await command.copy('generated', ['assets', 'assets/nested']);

        expectFilesCopiedOnce(files);
      });
    });
  });
  group('error handling and cleanup', () {
    late FakeIO io;

    setUp(() {
      io = FakeIO();
      io.setupFakeProject('myapp');
    });

    test('cleans up guards and watched processes when uncaught async error occurs', () async {
      await io.runZoned(() async {
        bool guardExecuted = false;
        final fakeProcess = FakeProcess();

        final command = _ErrorCommand(
          onRun: (cmd) {
            cmd.guardResource(() {
              guardExecuted = true;
            });
            cmd.watchProcess('fake', fakeProcess);

            // Trigger an uncaught asynchronous error in the zone
            scheduleMicrotask(() {
              throw StateError('Simulated uncaught async crash');
            });
          },
        );

        await expectLater(command.run(), throwsA(isA<StateError>()));
        expect(guardExecuted, isTrue);
        expect(fakeProcess.killed, isTrue);
      });
    });

    test('cleans up guards and watched processes when runCommand throws synchronously/asynchronously', () async {
      await io.runZoned(() async {
        bool guardExecuted = false;
        final fakeProcess = FakeProcess();

        final command = _ErrorCommand(
          onRun: (cmd) {
            cmd.guardResource(() {
              guardExecuted = true;
            });
            cmd.watchProcess('fake', fakeProcess);
            throw Exception('Sync command failure');
          },
        );

        expect(command.run(), throwsA(isA<Exception>()));
        await pumpEventQueue();

        expect(guardExecuted, isTrue);
        expect(fakeProcess.killed, isTrue);
      });
    });
  });
}

class _TestCommand extends BaseCommand {
  @override
  String get description => 'Test command';

  @override
  String get name => 'test';

  @override
  Future<int> runCommand() async => 0;

  Future<void> copy(String from, [List<String> targets = const ['']]) {
    return copyToBuildDir(from, targets);
  }
}

class _ErrorCommand extends BaseCommand {
  _ErrorCommand({required this.onRun});

  final FutureOr<void> Function(_ErrorCommand) onRun;

  @override
  String get description => 'Error test command';

  @override
  String get name => 'error_test';

  @override
  Future<int> runCommand() async {
    await onRun(this);
    // Completer to keep command running if waiting for async error
    final completer = Completer<int>();
    return completer.future;
  }
}
