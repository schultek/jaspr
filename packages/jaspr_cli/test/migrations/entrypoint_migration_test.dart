import 'package:file/memory.dart';
import 'package:jaspr_cli/src/migrations/entrypoint_migration.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('entrypoint migration', () {
    group('succeeds', () {
      test('with jaspr_options import', () {
        testUnitMigration(
          EntrypointMigration(),
          input: '''
import 'package:jaspr/jaspr.dart';
import 'jaspr_options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultJasprOptions,
  );

  runApp(App());
}
''',
          expectedOutput: '''
import 'package:jaspr/server.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  runApp(App());
}
''',
          expectedMigrations: [
            matchesMigration("Replaced 'jaspr_options.dart' import with 'main.server.options.dart'"),
          ],
          expectedWarnings: [],
        );
      });

      test('replacing entrypoints', () {
        final fs = MemoryFileSystem()
          ..directory('lib').createSync()
          ..file('pubspec.yaml').writeAsStringSync('''
jaspr:
  mode: static
''')
          ..file('lib/main.dart').writeAsStringSync('''
void main() {}
''')
          ..file('lib/jaspr_options.dart').writeAsStringSync('''
// Some options
''');

        testProjectMigration(
          EntrypointMigration(),
          fs: fs,

          expectedMigrations: {
            'lib/main.dart': [
              matchesMigration("Renamed 'main.dart' file to 'main.server.dart'"),
            ],
            'lib/jaspr_options.dart': [
              matchesMigration("Removed 'jaspr_options.dart' file. Run 'jaspr serve' to re-generate."),
            ],
            'lib/main.client.dart': [
              matchesMigration("Created 'main.client.dart' file"),
            ],
          },
          expectedWarnings: {},
        );

        expect(fs.file('lib/main.dart').existsSync(), isFalse);
        expect(fs.file('lib/main.server.dart').existsSync(), isTrue);
        expect(fs.file('lib/jaspr_options.dart').existsSync(), isFalse);
        expect(fs.file('lib/main.client.dart').existsSync(), isTrue);
      });
    });

    group('skips', () {
      test('with no jaspr_options import', () async {
        final source = '''
void main() {
  final options = defaultJasprOptions;
}
''';

        testUnitMigration(
          EntrypointMigration(),
          input: source,
          expectedOutput: source,
          expectedMigrations: [],
          expectedWarnings: [],
        );
      });

      test('with client mode', () async {
        final fs = MemoryFileSystem()
          ..directory('lib').createSync()
          ..file('pubspec.yaml').writeAsStringSync('''
jaspr:
  mode: client
''')
          ..file('lib/main.dart').writeAsStringSync('''
void main() {}
''');

        testProjectMigration(
          EntrypointMigration(),
          fs: fs,

          expectedMigrations: {},
          expectedWarnings: {},
        );

        expect(fs.file('lib/main.dart').existsSync(), isTrue);
        expect(fs.file('lib/main.server.dart').existsSync(), isFalse);
        expect(fs.file('lib/main.client.dart').existsSync(), isFalse);
      });
    });
  });
}
