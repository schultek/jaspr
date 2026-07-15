import 'dart:convert';

import 'package:jaspr_cli/src/command_runner.dart';
import 'package:test/test.dart';

import '../fakes/fake_io.dart';
import '../fakes/fake_project.dart';

void main() {
  group('install-skills command', () {
    late JasprCommandRunner runner;
    late FakeIO io;

    setUp(() {
      io = FakeIO();
      runner = JasprCommandRunner(false);
    });

    /// Sets up a fake package_config.json that points to a jaspr package at [jasprRootUri].
    void setupPackageConfig({String? jasprRootUri = '/root/jaspr_pkg'}) {
      final packageConfig = {
        'configVersion': 2,
        'packages': [
          if (jasprRootUri case final rootUri?)
            {
              'name': 'jaspr',
              'rootUri': rootUri,
              'packageUri': 'lib/',
            },
        ],
      };
      io.fs.file('/root/.dart_tool/package_config.json')
        ..createSync(recursive: true)
        ..writeAsStringSync(jsonEncode(packageConfig));
    }

    /// Creates a fake skill directory at [basePath]/skills/[skillName]
    /// with a SKILL.md containing the given [version].
    void createSkill(String basePath, String skillName, {String? version}) {
      final skillDir = io.fs.directory('$basePath/skills/$skillName');
      skillDir.createSync(recursive: true);

      final versionMeta = version != null ? 'metadata:\n  jaspr_version: $version\n' : '';
      io.fs.file('$basePath/skills/$skillName/SKILL.md')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '---\n'
          'name: $skillName\n'
          'description: A test skill.\n'
          '$versionMeta'
          '---\n'
          '\n'
          '## Content\n'
          'Some skill content.\n',
        );
    }

    /// Creates a reference file inside a skill directory.
    void createSkillReference(String basePath, String skillName, String refPath, String content) {
      io.fs.file('$basePath/skills/$skillName/$refPath')
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
    }

    test('fails when no package_config.json exists', () async {
      await io.runZoned(() async {
        io.stubDartSDK();

        final result = await runner.run(['install-skills', '--agent', 'cursor']);

        expect(result, equals(1));
        await expectLater(io.stderr.queue, emits(contains('Could not find package_config.json')));
      });
    });

    test('fails when jaspr package is not in package_config.json', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        setupPackageConfig(jasprRootUri: null);

        final result = await runner.run(['install-skills', '--agent', 'cursor']);

        expect(result, equals(1));
        await expectLater(io.stderr.queue, emits(contains('Could not find "jaspr" package')));
      });
    });

    test('auto-detects agent when skills directory exists', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        setupPackageConfig();
        createSkill('/root/jaspr_pkg', 'test-skill', version: '1.0.0');

        // Create an existing .agents/skills directory to trigger auto-detection (first in agents map).
        io.fs.directory('/root/.agents/skills').createSync(recursive: true);

        final result = await runner.run(['install-skills']);

        expect(result, equals(0));

        expect(io.fs.file('/root/.agents/skills/test-skill/SKILL.md').existsSync(), isTrue);

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            contains('Using auto-detected skills directory: .agents/skills'),
            contains('Adding skill test-skill for version 1.0.0...'),
          ]),
        );
      });
    });

    test('fails when no agent directory is auto-detected', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        setupPackageConfig();
        createSkill('/root/jaspr_pkg', 'test-skill', version: '1.0.0');

        final result = await runner.run(['install-skills']);

        expect(result, equals(1));
        await expectLater(
          io.stdout.queue,
          emits(contains('Could not auto-detect an agent directory')),
        );
      });
    });

    test('adds skills to a specified agent directory', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        setupPackageConfig();

        createSkill('/root/jaspr_pkg', 'test-skill', version: '1.0.0');
        createSkillReference('/root/jaspr_pkg', 'test-skill', 'references/example.md', 'Example reference.');

        final result = await runner.run(['install-skills', '--agent', 'cursor']);

        expect(result, equals(0));
        expect(io.fs.file('/root/.cursor/skills/test-skill/SKILL.md').existsSync(), isTrue);
        expect(io.fs.file('/root/.cursor/skills/test-skill/references/example.md').existsSync(), isTrue);

        final content = io.fs.file('/root/.cursor/skills/test-skill/SKILL.md').readAsStringSync();
        expect(content, contains('jaspr_version: 1.0.0'));

        await expectLater(io.stdout.queue, emits(contains('Adding skill test-skill for version 1.0.0...')));
      });
    });

    test('skips skills when versions match', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        setupPackageConfig();

        createSkill('/root/jaspr_pkg', 'test-skill', version: '1.0.0');
        createSkill('/root/.cursor', 'test-skill', version: '1.0.0');

        final result = await runner.run(['install-skills', '--agent', 'cursor']);

        expect(result, equals(0));

        await expectLater(
          io.stdout.queue,
          emits(contains('All skills are already installed and up to date.')),
        );
      });
    });

    test('updates skills when version differs', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        setupPackageConfig();

        createSkill('/root/jaspr_pkg', 'test-skill', version: '2.0.0');
        createSkillReference('/root/jaspr_pkg', 'test-skill', 'references/new.md', 'New reference.');

        createSkill('/root/.cursor', 'test-skill', version: '1.0.0');

        final result = await runner.run(['install-skills', '--agent', 'cursor']);

        expect(result, equals(0));

        final content = io.fs.file('/root/.cursor/skills/test-skill/SKILL.md').readAsStringSync();
        expect(content, contains('jaspr_version: 2.0.0'));

        expect(io.fs.file('/root/.cursor/skills/test-skill/references/new.md').existsSync(), isTrue);

        await expectLater(io.stdout.queue, emits(contains('Updating skill test-skill to version 2.0.0...')));
      });
    });

    test('handles multiple skills with mixed add, update and skip', () async {
      await io.runZoned(() async {
        io.stubDartSDK();
        setupPackageConfig();

        createSkill('/root/jaspr_pkg', 'skill-a', version: '1.0.0');
        createSkill('/root/jaspr_pkg', 'skill-b', version: '2.0.0');
        createSkill('/root/jaspr_pkg', 'skill-c', version: '1.0.0');

        // Pre-install skill-b with old version (should be updated).
        createSkill('/root/.agents', 'skill-b', version: '1.0.0');
        // Pre-install skill-c with the same version (should be skipped).
        createSkill('/root/.agents', 'skill-c', version: '1.0.0');

        final result = await runner.run(['install-skills', '--agent', 'antigravity']);

        expect(result, equals(0));

        expect(io.fs.file('/root/.agents/skills/skill-a/SKILL.md').existsSync(), isTrue);
        expect(io.fs.file('/root/.agents/skills/skill-b/SKILL.md').existsSync(), isTrue);
        expect(io.fs.file('/root/.agents/skills/skill-c/SKILL.md').existsSync(), isTrue);

        // skill-a is added, skill-b is updated, skill-c is skipped.
        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            contains('Adding skill skill-a for version 1.0.0...'),
            contains('Updating skill skill-b to version 2.0.0...'),
          ]),
        );
      });
    });
  });
}
