import 'package:jaspr_cli/src/command_runner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../fakes/fake_io.dart';

void main() {
  group('create command', () {
    late JasprCommandRunner runner;
    late FakeIO io;

    setUp(() {
      io = FakeIO();
      runner = JasprCommandRunner();
    });

    test('creates project with client mode', () async {
      await io.runZoned(() async {
        when(
          () => io.process.start('dart', ['pub', 'get'], workingDirectory: '/root/myapp'),
        ).thenAnswer((_) async => FakeProcess.sync());

        final result = await runner.run(['create', 'myapp', '--mode=client']);

        expect(result, equals(0));
        expect(io.fs.directory('myapp').existsSync(), isTrue);

        // Files that should exist.
        expect(io.fs.file('myapp/pubspec.yaml').existsSync(), isTrue);
        expect(io.fs.file('myapp/lib/main.client.dart').existsSync(), isTrue);
        expect(io.fs.file('myapp/lib/app.dart').existsSync(), isTrue);
        expect(io.fs.file('myapp/web/index.html').existsSync(), isTrue);

        // Files that should not exist.
        expect(io.fs.file('myapp/lib/main.server.dart').existsSync(), isFalse);

        verify(() => io.process.start('dart', ['pub', 'get'], workingDirectory: '/root/myapp')).called(1);

        final pubspec = io.fs.file('myapp/pubspec.yaml').readAsStringSync();
        expect(pubspec, contains('name: myapp'));
        expect(pubspec, contains('jaspr:\n  mode: client'));
      });
    });

    test('creates project with server mode', () async {
      await io.runZoned(() async {
        when(
          () => io.process.start('dart', ['pub', 'get'], workingDirectory: '/root/myapp'),
        ).thenAnswer((_) async => FakeProcess.sync());

        final result = await runner.run(['create', 'myapp', '--mode=server']);

        expect(result, equals(0));
        expect(io.fs.directory('myapp').existsSync(), isTrue);

        // Files that should exist.
        expect(io.fs.file('myapp/pubspec.yaml').existsSync(), isTrue);
        expect(io.fs.file('myapp/lib/main.client.dart').existsSync(), isTrue);
        expect(io.fs.file('myapp/lib/main.server.dart').existsSync(), isTrue);
        expect(io.fs.file('myapp/lib/app.dart').existsSync(), isTrue);

        // Files that should not exist.
        expect(io.fs.file('myapp/web/index.html').existsSync(), isFalse);

        verify(() => io.process.start('dart', ['pub', 'get'], workingDirectory: '/root/myapp')).called(1);

        final pubspec = io.fs.file('myapp/pubspec.yaml').readAsStringSync();
        expect(pubspec, contains('name: myapp'));
        expect(pubspec, contains('jaspr:\n  mode: server'));
      });
    });

    test('creates project with static mode', () async {
      await io.runZoned(() async {
        when(
          () => io.process.start('dart', ['pub', 'get'], workingDirectory: '/root/myapp'),
        ).thenAnswer((_) async => FakeProcess.sync());

        final result = await runner.run(['create', 'myapp', '--mode=static']);

        expect(result, equals(0));
        expect(io.fs.directory('myapp').existsSync(), isTrue);

        // Files that should exist.
        expect(io.fs.file('myapp/pubspec.yaml').existsSync(), isTrue);
        expect(io.fs.file('myapp/lib/main.client.dart').existsSync(), isTrue);
        expect(io.fs.file('myapp/lib/main.server.dart').existsSync(), isTrue);
        expect(io.fs.file('myapp/lib/app.dart').existsSync(), isTrue);

        // Files that should not exist.
        expect(io.fs.file('myapp/web/index.html').existsSync(), isFalse);

        verify(() => io.process.start('dart', ['pub', 'get'], workingDirectory: '/root/myapp')).called(1);

        final pubspec = io.fs.file('myapp/pubspec.yaml').readAsStringSync();
        expect(pubspec, contains('name: myapp'));
        expect(pubspec, contains('jaspr:\n  mode: static'));
      });
    });

    test('creates project from docs template', () async {
      await io.runZoned(() async {
        when(
          () => io.process.start('dart', ['pub', 'get'], workingDirectory: '/root/myapp'),
        ).thenAnswer((_) async => FakeProcess.sync());

        final result = await runner.run(['create', 'myapp', '--template=docs']);

        expect(result, equals(0));
        expect(io.fs.directory('myapp').existsSync(), isTrue);

        // Files that should exist.
        expect(io.fs.file('myapp/pubspec.yaml').existsSync(), isTrue);
        expect(io.fs.file('myapp/lib/main.client.dart').existsSync(), isTrue);
        expect(io.fs.file('myapp/lib/main.server.dart').existsSync(), isTrue);
        expect(io.fs.file('myapp/content/index.md').existsSync(), isTrue);

        // Files that should not exist.
        expect(io.fs.file('myapp/lib/app.dart').existsSync(), isFalse);
        expect(io.fs.file('myapp/web/index.html').existsSync(), isFalse);

        verify(() => io.process.start('dart', ['pub', 'get'], workingDirectory: '/root/myapp')).called(1);

        final pubspec = io.fs.file('myapp/pubspec.yaml').readAsStringSync();
        expect(pubspec, contains('name: myapp'));
        expect(pubspec, contains('jaspr:\n  mode: static'));
      });
    });
  });
}
