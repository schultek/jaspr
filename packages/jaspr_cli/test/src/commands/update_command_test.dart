import 'dart:io';

import 'package:jaspr_cli/src/command_runner.dart';
import 'package:jaspr_cli/src/helpers/skills_helper.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../fakes/fake_io.dart';
import '../fakes/fake_project.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ProcessStartMode.normal);
  });

  group('post-update command', () {
    late JasprCommandRunner runner;
    late FakeIO io;

    setUp(() {
      io = FakeIO();
      runner = JasprCommandRunner(false, false);
    });

    test('displays promo banner when no skills installed', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        when(
          () => io.process.run(
            '/fake/bin/dart',
            ['run', 'skills@', 'list'],
            workingDirectory: null,
          ),
        ).thenAnswer(
          (_) async => ProcessResult(0, 0, 'No managed skills installed.', ''),
        );

        final result = await runner.run(['post-update']);

        expect(result, equals(0));
        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            emitsThrough(contains('Boost your development with Jaspr AI Skills!')),
            emitsThrough(contains('dart run skills@ get -p jaspr -a')),
          ]),
        );
      });
    });

    test('does not display promo banner when jaspr skills are installed', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        when(
          () => io.process.run(
            '/fake/bin/dart',
            ['run', 'skills@', 'list'],
            workingDirectory: null,
          ),
        ).thenAnswer(
          (_) async => ProcessResult(
            0,
            0,
            'Installed skills:\n  package:jaspr:\n    - jaspr-fundamentals\n',
            '',
          ),
        );

        final result = await runner.run(['post-update']);

        expect(result, equals(0));
      });
    });
  });

  group('skills_helper', () {
    late FakeIO io;

    setUp(() {
      io = FakeIO();
    });

    test('checkJasprSkillsInstalled returns true when package:jaspr is in output', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        when(
          () => io.process.run(
            '/fake/bin/dart',
            ['run', 'skills@', 'list'],
            workingDirectory: any(named: 'workingDirectory'),
          ),
        ).thenAnswer(
          (_) async => ProcessResult(0, 0, 'Installed skills:\n  package:jaspr:\n    - jaspr-fundamentals\n', ''),
        );

        final result = await checkJasprSkillsInstalled();
        expect(result, isTrue);
      });
    });

    test('checkJasprSkillsInstalled returns false when no managed skills', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        when(
          () => io.process.run(
            '/fake/bin/dart',
            ['run', 'skills@', 'list'],
            workingDirectory: any(named: 'workingDirectory'),
          ),
        ).thenAnswer(
          (_) async => ProcessResult(0, 0, 'No managed skills installed.', ''),
        );

        final result = await checkJasprSkillsInstalled();
        expect(result, isFalse);
      });
    });

    test('checkJasprSkillsInstalled returns false on process error or non-zero exit code', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        when(
          () => io.process.run(
            '/fake/bin/dart',
            ['run', 'skills@', 'list'],
            workingDirectory: any(named: 'workingDirectory'),
          ),
        ).thenAnswer(
          (_) async => ProcessResult(0, 1, '', 'Error running skills'),
        );

        final result = await checkJasprSkillsInstalled();
        expect(result, isFalse);
      });
    });

    test('installJasprSkills runs skills get jaspr with inherited stdio', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        when(
          () => io.process.start(
            '/fake/bin/dart',
            ['run', 'skills@', 'get', '-p', 'jaspr', '-a'],
            workingDirectory: '/test_dir',
            mode: any(named: 'mode'),
          ),
        ).thenAnswer((_) async => FakeProcess.sync());

        final exitCode = await installJasprSkills(workingDirectory: '/test_dir');
        expect(exitCode, equals(0));
        verify(
          () => io.process.start(
            '/fake/bin/dart',
            ['run', 'skills@', 'get', '-p', 'jaspr', '-a'],
            workingDirectory: '/test_dir',
            mode: any(named: 'mode'),
          ),
        ).called(1);
      });
    });
  });
}
