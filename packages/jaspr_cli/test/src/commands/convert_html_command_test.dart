import 'package:jaspr_cli/src/command_runner.dart';
import 'package:test/test.dart';

import '../fakes/fake_io.dart';
import '../fakes/fake_project.dart';

void main() {
  group('convert-html command', () {
    late JasprCommandRunner runner;
    late FakeIO io;

    setUp(() {
      io = FakeIO();
      runner = JasprCommandRunner(false);
    });

    test('fails when neither --file nor --url is provided', () async {
      await io.runZoned(() async {
        io.stubDartSDK();

        final result = await runner.run(['convert-html']);

        expect(result, equals(1));
        await expectLater(io.stderr.queue, emits(contains('Either --file or --url must be provided.')));
      });
    });

    test('fails when file does not exist', () async {
      await io.runZoned(() async {
        io.stubDartSDK();

        final result = await runner.run(['convert-html', '--file', 'nonexistent.html']);

        expect(result, equals(1));
        await expectLater(io.stderr.queue, emits(contains('File not found: nonexistent.html')));
      });
    });

    test('converts html from a file', () async {
      await io.runZoned(() async {
        io.stubDartSDK();

        io.fs.file('/root/test.html')
          ..createSync(recursive: true)
          ..writeAsStringSync('<div><p>Hello</p></div>');

        final result = await runner.run(['convert-html', '--file', '/root/test.html']);

        expect(result, equals(0));
        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            'div([',
            'p([',
            ".text('Hello'),",
            ']),',
            '])',
          ]),
        );
      });
    });

    test('converts html from a file with query selector', () async {
      await io.runZoned(() async {
        io.stubDartSDK();

        io.fs.file('/root/test.html')
          ..createSync(recursive: true)
          ..writeAsStringSync('<body><header>Header</header><main><p>Content</p></main></body>');

        final result = await runner.run(['convert-html', '--file', '/root/test.html', '--query', 'main']);

        expect(result, equals(0));
        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            'main_([',
            'p([',
            ".text('Content'),",
            ']),',
            '])',
          ]),
        );
      });
    });
  });
}
