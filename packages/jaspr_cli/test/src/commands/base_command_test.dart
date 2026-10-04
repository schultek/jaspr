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

  group('stop', () {
    late FakeIO io;

    setUp(() {
      io = FakeIO();
      io.setupFakeProject('myapp');
    });

    tearDown(() {
      io.tearDown();
    });

    test('waits for the guards when it is called again while they are running', () async {
      await io.runZoned(() async {
        final command = _TestCommand();
        final calls = <String>[];
        final blocked = Completer<void>();

        command.guardResource(() async {
          calls.add('first started');
          await blocked.future;
          calls.add('first done');
        });
        command.guardResource(() async {
          calls.add('second');
        });

        final first = command.stop();
        await pumpEventQueue();
        expect(calls, ['first started']);

        // The signal handler and the command's `finally` both get here.
        var secondDone = false;
        final second = command.stop().then((_) => secondDone = true);
        await pumpEventQueue();

        expect(secondDone, isFalse, reason: 'returned while the guards were still running');

        blocked.complete();
        await Future.wait([first, second]);

        expect(calls, ['first started', 'first done', 'second']);
      });
    });

    test('runs guards registered after it finished', () async {
      await io.runZoned(() async {
        final command = _TestCommand();
        final calls = <String>[];

        command.guardResource(() => calls.add('first'));
        await command.stop();

        command.guardResource(() => calls.add('second'));
        await command.stop();

        expect(calls, ['first', 'second']);
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
