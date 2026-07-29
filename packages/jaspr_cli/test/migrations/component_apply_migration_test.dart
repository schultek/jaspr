import 'package:jaspr_cli/src/migrations/component_apply_migration.dart';
import 'package:jaspr_cli/src/migrations/migration_models.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('component apply migration', () {
    group('succeeds', () {
      test('with Component.wrapElement', () async {
        testUnitMigration(
          ComponentApplyMigration(),
          input: '''
import 'package:jaspr/jaspr.dart';

Component build() {
  return Component.wrapElement(
    classes: 'my-class',
    child: Component.element(tag: 'span', children: [Component.text('Hello, World!')]),
  );
}
''',
          expectedOutput: '''
import 'package:jaspr/jaspr.dart';

Component build() {
  return Component.apply(
    classes: 'my-class',
    child: Component.element(tag: 'span', children: [Component.text('Hello, World!')]),
  );
}
''',
          expectedMigrations: [
            isA<MigrationInstance>().having(
              (m) => m.description,
              'description',
              'Replaced Component.wrapElement() with Component.apply()',
            ),
          ],
          expectedWarnings: [],
        );
      });

      test('with dot-shorthand .wrapElement', () async {
        testUnitMigration(
          ComponentApplyMigration(),
          input: '''
import 'package:jaspr/jaspr.dart';

Component build() {
  return .wrapElement(
    classes: 'my-class',
    child: .element(tag: 'span', children: [.text('Hello, World!')]),
  );
}
''',
          expectedOutput: '''
import 'package:jaspr/jaspr.dart';

Component build() {
  return .apply(
    classes: 'my-class',
    child: .element(tag: 'span', children: [.text('Hello, World!')]),
  );
}
''',
          expectedMigrations: [
            isA<MigrationInstance>().having(
              (m) => m.description,
              'description',
              'Replaced Component.wrapElement() with Component.apply()',
            ),
          ],
          expectedWarnings: [],
          features: ['dot-shorthands'],
        );
      });
    });

    group('skips', () {
      test('with already migrated Component.apply', () async {
        final source = '''
import 'package:jaspr/jaspr.dart';

Component build() {
  return Component.apply(
    classes: 'my-class',
    child: Component.element(tag: 'span', children: [Component.text('Hello, World!')]),
  );
}
''';

        testUnitMigration(
          ComponentApplyMigration(),
          input: source,
          expectedOutput: source,
          expectedMigrations: [],
          expectedWarnings: [],
        );
      });

      test('with no jaspr', () async {
        final source = '''
Component build() {
  return Component.wrapElement(
    classes: 'my-class',
    child: Text('Hello, World!'),
  );
}
''';

        testUnitMigration(
          ComponentApplyMigration(),
          input: source,
          expectedOutput: source,
          expectedMigrations: [],
          expectedWarnings: [],
        );
      });
    });
  });
}
