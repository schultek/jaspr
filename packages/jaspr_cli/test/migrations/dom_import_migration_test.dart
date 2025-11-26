import 'package:jaspr_cli/src/migrations/dom_import_migration.dart';
import 'package:jaspr_cli/src/migrations/migration_models.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('dom import migration', () {
    test('adds dom import when html tags are used', () {
      testMigration(
        DomImportMigration(),
        input: '''
import 'package:jaspr/jaspr.dart';

void main() {
  div([]);
}
''',
        expectedOutput: '''
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

void main() {
  div([]);
}
''',
        expectedMigrations: [
          isA<MigrationInstance>().having(
            (m) => m.description,
            'description',
            "Added 'package:jaspr/dom.dart' import.",
          ),
        ],
      );
    });

    test('adds dom import when dom classes are used', () {
      testMigration(
        DomImportMigration(),
        input: '''
import 'package:jaspr/jaspr.dart';

void main() {
  Styles.box();
}
''',
        expectedOutput: '''
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

void main() {
  Styles.box();
}
''',
        expectedMigrations: [
          isA<MigrationInstance>().having(
            (m) => m.description,
            'description',
            "Added 'package:jaspr/dom.dart' import.",
          ),
        ],
      );
    });

    test('does not add import if already present', () {
      testMigration(
        DomImportMigration(),
        input: '''
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

void main() {
  div([]);
}
''',
        expectedOutput: '''
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

void main() {
  div([]);
}
''',
        expectedMigrations: [],
      );
    });

    test('does not add import if no dom apis used', () {
      testMigration(
        DomImportMigration(),
        input: '''
import 'package:jaspr/jaspr.dart';

void main() {
  Component();
}
''',
        expectedOutput: '''
import 'package:jaspr/jaspr.dart';

void main() {
  Component();
}
''',
        expectedMigrations: [],
      );
    });

    test('adds import after platform import if jaspr import missing', () {
      testMigration(
        DomImportMigration(),
        input: '''
import 'package:jaspr/browser.dart';

void main() {
  div([]);
}
''',
        expectedOutput: '''
import 'package:jaspr/dom.dart';
import 'package:jaspr/browser.dart';

void main() {
  div([]);
}
''',
        expectedMigrations: [
          isA<MigrationInstance>().having(
            (m) => m.description,
            'description',
            "Added 'package:jaspr/dom.dart' import.",
          ),
        ],
      );
    });

    test('does not run if no jaspr imports present', () {
      testMigration(
        DomImportMigration(),
        input: '''
import 'dart:html';

void main() {
  div([]);
}
''',
        expectedOutput: '''
import 'dart:html';

void main() {
  div([]);
}
''',
        expectedMigrations: [],
      );
    });
  });
}
