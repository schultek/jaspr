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
