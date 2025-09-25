import 'package:jaspr_cli/src/migrations/component_factory_migration.dart';
import 'package:jaspr_cli/src/migrations/migration_models.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('build method migration', () {
    group('succeeds', () {
      test('with DomComponent and Text', () async {
        testMigration(
          ComponentFactoryMigration(),
          input: '''
import 'package:jaspr/jaspr.dart';

Component build() {
  return DomComponent(tag: 'div', children: [
    DomComponent(tag: 'span', children: [Text('Hello, World!')]),
    Text('Some text'),
  ]);
}
''',
          expectedOutput: '''
import 'package:jaspr/jaspr.dart';

Component build() {
  return Component.element(tag: 'div', children: [
    Component.element(tag: 'span', children: [Component.text('Hello, World!')]),
    Component.text('Some text'),
  ]);
}
''',
          expectedMigrations: [
            isA<MigrationInstance>().having((i) => i.description, 'description',
                'Replaced Text() with Component.text()'),
                isA<MigrationInstance>().having((i) => i.description, 'description',
                'Replaced DomComponent() with Component.element()'),
          ],
          expectedWarnings: [],
        );
      });

      test('with Fragment', () async {
        testMigration(
          ComponentFactoryMigration(),
          input: '''
import 'package:jaspr/jaspr.dart';

Component build() {
  return Fragment(children: [
    Text('Hello, World!'),
    Text('Goodbye, World!'),
  ]);
}
''',
          expectedOutput: '''
import 'package:jaspr/jaspr.dart';

Component build() {
  return Component.fragment([
    Component.text('Hello, World!'),
    Component.text('Goodbye, World!'),
  ]);
}
''',
        );
      });

      test('with DomComponent.wrap', () async {
        testMigration(
          ComponentFactoryMigration(),
          input: '''
import 'package:jaspr/jaspr.dart';

Component build() {
  return DomComponent.wrap(
    classes: 'my-class',
    child: DomComponent(tag: 'span', children: [Text('Hello, World!')]),
  );
}
''',
          expectedOutput: '''
import 'package:jaspr/jaspr.dart';

Component build() {
  return Component.wrapElement(
    classes: 'my-class',
    child: Component.element(tag: 'span', children: [Component.text('Hello, World!')]),
  );
}
''',
        );
      });
    });

    group('skips', () {
      test('with already migrated constructor', () async {
        final source = '''
import 'package:jaspr/jaspr.dart';

Component build() {
  return Component.element(tag: 'div', children: [
    Component.element(tag: 'span', children: [Component.text('Hello, World!')]),
    Component.text('Some text'),
  ]);
}
''';

        testMigration(
          ComponentFactoryMigration(),
          input: source,
          expectedOutput: source,
          expectedMigrations: [],
          expectedWarnings: [],
        );
      });

      test('with no jaspr', () async {
        final source = '''
Component build() {
  return Text('Hello, World!');
}
''';

        testMigration(
          ComponentFactoryMigration(),
          input: source,
          expectedOutput: source,
          expectedMigrations: [],
          expectedWarnings: [],
        );
      });
    });
  });
}
