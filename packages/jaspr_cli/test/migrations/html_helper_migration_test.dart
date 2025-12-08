import 'package:jaspr_cli/src/migrations/html_helper_migration.dart';
import 'package:jaspr_cli/src/migrations/migration_models.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('html helper migration', () {
    test('migrates text() to Component.text()', () {
      testUnitMigration(
        HtmlHelperMigration(),
        input: '''
import 'package:jaspr/jaspr.dart';

void main() {
  text('Hello');
}
''',
        expectedOutput: '''
import 'package:jaspr/jaspr.dart';

void main() {
  Component.text('Hello');
}
''',
        expectedMigrations: [
          isA<MigrationInstance>().having(
            (m) => m.description,
            'description',
            'Replaced text() with Component.text()',
          ),
        ],
      );
    });

    test('migrates fragment() to Component.fragment()', () {
      testUnitMigration(
        HtmlHelperMigration(),
        input: '''
import 'package:jaspr/jaspr.dart';

void main() {
  fragment([text('Hello')]);
}
''',
        expectedOutput: '''
import 'package:jaspr/jaspr.dart';

void main() {
  Component.fragment([Component.text('Hello')]);
}
''',
        expectedMigrations: [
          isA<MigrationInstance>().having(
            (m) => m.description,
            'description',
            'Replaced text() with Component.text()',
          ),
          isA<MigrationInstance>().having(
            (m) => m.description,
            'description',
            'Replaced fragment() with Component.fragment()',
          ),
        ],
      );
    });

    test('migrates raw() to RawText()', () {
      testUnitMigration(
        HtmlHelperMigration(),
        input: '''
import 'package:jaspr/jaspr.dart';

void main() {
  raw('<div></div>');
}
''',
        expectedOutput: '''
import 'package:jaspr/jaspr.dart';

void main() {
  RawText('<div></div>');
}
''',
        expectedMigrations: [
          isA<MigrationInstance>().having(
            (m) => m.description,
            'description',
            'Replaced raw() with RawText()',
          ),
        ],
      );
    });

    test('does not migrate when jaspr is not imported', () {
      testUnitMigration(
        HtmlHelperMigration(),
        input: '''
void main() {
  text('Hello');
}
''',
        expectedOutput: '''
void main() {
  text('Hello');
}
''',
        expectedMigrations: [],
      );
    });

    test('does not migrate methods with target', () {
      testUnitMigration(
        HtmlHelperMigration(),
        input: '''
import 'package:jaspr/jaspr.dart';

class MyClass {
  void text(String s) {}
}

void main() {
  var c = MyClass();
  c.text('Hello');
}
''',
        expectedOutput: '''
import 'package:jaspr/jaspr.dart';

class MyClass {
  void text(String s) {}
}

void main() {
  var c = MyClass();
  c.text('Hello');
}
''',
        expectedMigrations: [],
      );
    });

    test('does not migrate methods with wrong arguments', () {
      testUnitMigration(
        HtmlHelperMigration(),
        input: '''
import 'package:jaspr/jaspr.dart';

void text(String a, String b) {}

void main() {
  text('Hello', 'World');
}
''',
        expectedOutput: '''
import 'package:jaspr/jaspr.dart';

void text(String a, String b) {}

void main() {
  text('Hello', 'World');
}
''',
        expectedMigrations: [],
      );
    });

    test('migrates with key argument', () {
      testUnitMigration(
        HtmlHelperMigration(),
        input: '''
import 'package:jaspr/jaspr.dart';

void main() {
  text('Hello', key: Key('key'));
}
''',
        expectedOutput: '''
import 'package:jaspr/jaspr.dart';

void main() {
  Component.text('Hello', key: Key('key'));
}
''',
        expectedMigrations: [
          isA<MigrationInstance>().having(
            (m) => m.description,
            'description',
            'Replaced text() with Component.text()',
          ),
        ],
      );
    });

    test('migrates text() to .text() with dot-shorthands', () {
      testUnitMigration(
        HtmlHelperMigration(),
        input: '''
import 'package:jaspr/jaspr.dart';

void main() {
  text('Hello');
}
''',
        expectedOutput: '''
import 'package:jaspr/jaspr.dart';

void main() {
  .text('Hello');
}
''',
        expectedMigrations: [
          isA<MigrationInstance>().having(
            (m) => m.description,
            'description',
            'Replaced text() with .text()',
          ),
        ],
        features: ['dot-shorthands'],
      );
    });

    test('migrates fragment() to .fragment() with dot-shorthands', () {
      testUnitMigration(
        HtmlHelperMigration(),
        input: '''
import 'package:jaspr/jaspr.dart';

void main() {
  fragment([text('Hello')]);
}
''',
        expectedOutput: '''
import 'package:jaspr/jaspr.dart';

void main() {
  .fragment([.text('Hello')]);
}
''',
        expectedMigrations: [
          isA<MigrationInstance>().having(
            (m) => m.description,
            'description',
            'Replaced text() with .text()',
          ),
          isA<MigrationInstance>().having(
            (m) => m.description,
            'description',
            'Replaced fragment() with .fragment()',
          ),
        ],
        features: ['dot-shorthands'],
      );
    });
  });
}
