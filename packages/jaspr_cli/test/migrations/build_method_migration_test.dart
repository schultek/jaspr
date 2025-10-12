import 'package:jaspr_cli/src/migrations/build_method_migration.dart';
import 'package:jaspr_cli/src/migrations/migration_models.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('build method migration', () {
    group('succeeds', () {
      test('with single yield', () async {
        testMigration(
          BuildMethodMigration(),
          input: '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Text('Hello, World!');
  }
}
''',
          expectedOutput: '''
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Text('Hello, World!');
  }
}
''',
          expectedMigrations: [
            isA<MigrationInstance>().having(
              (i) => i.description,
              'description',
              'Migrated build() method of MyComponent class',
            ),
          ],
          expectedWarnings: [],
        );
      });

      test('with multi yield', () async {
        testMigration(
          BuildMethodMigration(),
          input: '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Text('Hello, World!');
    yield Text('Goodbye, World!');
  }
}
''',
          expectedOutput: '''
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Component.fragment([
      Text('Hello, World!'),
      Text('Goodbye, World!'),
    ]);
  }
}
''',
        );
      });

      test('with yield inside if and for', () async {
        testMigration(
          BuildMethodMigration(),
          input: '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Text('Hello, World!');
    if (true) {
      yield Text('Conditional Text');
    }
    if (false) {
      yield Text('This will not be included');
    } else {
      yield Text('This will be included');
    }
    for (var i = 0; i < 2; i++) {
      yield Text('Loop Text \$i');
    }
    yield Text('Goodbye, World!');
  }
}
''',
          expectedOutput: '''
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Component.fragment([
      Text('Hello, World!'),
      if (true) 
        Text('Conditional Text'),
      
      if (false) 
        Text('This will not be included')
       else 
        Text('This will be included'),
      
      for (var i = 0; i < 2; i++) 
        Text('Loop Text \$i'),
      
      Text('Goodbye, World!'),
    ]);
  }
}
''',
        );
      });

      test('with multi-line childs', () async {
        testMigration(
          BuildMethodMigration(),
          input: '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      id: 'my-div',
      classes: 'my-class',
      [
        Text('Hello, World!'),
      ],
    );
  }
}
''',
          expectedOutput: '''
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div(
      id: 'my-div',
      classes: 'my-class',
      [
        Text('Hello, World!'),
      ],
    );
  }
}
''',
        );
      });

      test('with multiple yields in if', () async {
        testMigration(
          BuildMethodMigration(),
          input: '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (true) {
      yield text('Hello');
      yield text('World');
    } else {
      yield text('Goodbye');
      for (var i = 0; i < 1; i++) {
        yield text('\$i');
      }
      yield text('Jaspr');
    }
  }
}
''',
          expectedOutput: '''
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Component.fragment([
      if (true) ...[
        text('Hello'),
        text('World'),
      ] else ...[
        text('Goodbye'),
        for (var i = 0; i < 1; i++) 
          text('\$i'),
        
        text('Jaspr'),
      ],
    ]);
  }
}
''',
        );
      });

      test('with logic before yield', () async {
        testMigration(
          BuildMethodMigration(),
          input: '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    final name = 'World';
    yield Text('Hello \$name!');
  }
}
''',
          expectedOutput: '''
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    final name = 'World';
    return Text('Hello \$name!');
  }
}
''',
        );
      });

      test('with logic between yields', () async {
        testMigration(
          BuildMethodMigration(),
          input: '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    final name = 'World';
    yield Text('Hello \$name!');
    final greeting = 'Goodbye';
    yield Text('\$greeting \$name!');
  }
}
''',
          expectedOutput: '''
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    final name = 'World';
    final children = <Component>[];
    children.add(Text('Hello \$name!'));
    final greeting = 'Goodbye';
    children.add(Text('\$greeting \$name!'));
    return Component.fragment(children);
  }
}
''',
        );
      });

      test('with intermediate returns', () async {
        testMigration(
          BuildMethodMigration(),
          input: '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (true) {
      yield Text('Hello, World!');
      return;
    } else {
      yield Text('This will not be included');
      for (var i = 0; i < 2; i++) {
        yield Text('Loop Text \$i');

        if (i == 1) {
          yield Text('This is the last item');
          return;
        }
      }
    }

    final greeting = 'Goodbye';
    yield Text('\$greeting World!');
  }
}
''',
          expectedOutput: '''
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    final children = <Component>[];
    if (true) {
      children.add(Text('Hello, World!'));
      return Component.fragment(children);
    } else {
      children.add(Text('This will not be included'));
      for (var i = 0; i < 2; i++) {
        children.add(Text('Loop Text \$i'));

        if (i == 1) {
          children.add(Text('This is the last item'));
          return Component.fragment(children);
        }
      }
    }

    final greeting = 'Goodbye';
    children.add(Text('\$greeting World!'));
    return Component.fragment(children);
  }
}
''',
        );
      });

      test('with multi-line complex childs', () async {
        testMigration(
          BuildMethodMigration(),
          input: '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      id: 'my-div',
      classes: 'my-class',
      [
        Text('Hello, World!'),
      ],
    );

    if (true) {
      final greeting = 'Goodbye';
      yield div(
        id: 'another-div',
        classes: 'another-class',
        [
          Text('\$greeting, World!'),
          span(classes: 'nested-span', [Text('Nested Text')]),
        ],
      );
    }
  }
}
''',
          expectedOutput: '''
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    final children = <Component>[];
    children.add(div(
      id: 'my-div',
      classes: 'my-class',
      [
        Text('Hello, World!'),
      ],
    ));

    if (true) {
      final greeting = 'Goodbye';
      children.add(div(
        id: 'another-div',
        classes: 'another-class',
        [
          Text('\$greeting, World!'),
          span(classes: 'nested-span', [Text('Nested Text')]),
        ],
      ));
    }
    return Component.fragment(children);
  }
}
''',
        );
      });

      test('with Builder component', () async {
        testMigration(
          BuildMethodMigration(),
          input: '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Builder(
      builder: (context) sync* {
        yield Text('Hello from Builder!');
      },
    );
  }
}
''',
          expectedOutput: '''
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Text('Hello from Builder!');
      },
    );
  }
}
''',
          expectedWarnings: [],
        );
      });
    });

    test('with Builder.single component', () async {
      testMigration(
        BuildMethodMigration(),
        input: '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Builder.single(
      builder: (context) {
        return Text('Hello from Builder!');
      },
    );
  }
}
''',
        expectedOutput: '''
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Text('Hello from Builder!');
      },
    );
  }
}
''',
        expectedWarnings: [],
      );
    });

    group('fails', () {
      test('with non-generator build method', () async {
        final source = '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) {
    return [Text('Hello, World!')];
  }
}
''';

        testMigration(
          BuildMethodMigration(),
          input: source,
          expectedOutput: source,
          expectedWarnings: [
            isA<MigrationWarning>().having(
              (w) => w.message,
              'message',
              'Cannot migrate MyComponent.build(): Only build methods using sync* or async* can be migrated automatically',
            ),
          ],
        );
      });

      test('with expression body', () async {
        final source = '''
class MyComponent extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) => [Text('Hello, World!')];
}
''';

        testMigration(
          BuildMethodMigration(),
          input: source,
          expectedOutput: source,
          expectedWarnings: [
            isA<MigrationWarning>().having(
              (w) => w.message,
              'message',
              'Cannot migrate MyComponent.build(): Only build methods using sync* or async* can be migrated automatically',
            ),
          ],
        );
      });
    });

    group('skips', () {
      test('with no build method', () async {
        final source = '''
class MyComponent extends StatelessComponent {}
''';

        testMigration(
          BuildMethodMigration(),
          input: source,
          expectedOutput: source,
          expectedMigrations: [],
          expectedWarnings: [],
        );
      });

      test('with non-component class', () async {
        final source = '''
class MyClass {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Text('Hello, World!');
  }
}
''';

        testMigration(
          BuildMethodMigration(),
          input: source,
          expectedOutput: source,
          expectedMigrations: [],
          expectedWarnings: [],
        );
      });

      test('with already migrated build method', () async {
        final source = '''
class MyComponent extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Text('Already migrated');
  }
}
''';

        testMigration(
          BuildMethodMigration(),
          input: source,
          expectedOutput: source,
          expectedMigrations: [],
          expectedWarnings: [],
        );
      });
    });
  });
}
