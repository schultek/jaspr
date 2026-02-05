import 'dart:io';

import 'package:jaspr_cli/src/daemon/daemon.dart';
import 'package:jaspr_cli/src/domains/scopes_domain.dart';
import 'package:jaspr_cli/src/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDaemon extends Mock implements Daemon {
  MockDaemon();
}

class FakeLogger extends Fake implements Logger {
  FakeLogger();

  @override
  void write(String message, {Tag? tag, Level level = Level.info, ProgressState? progress}) {
    print('[$level]${tag != null ? '[$tag]' : ''} $message');
  }
}

void main() {
  late MockDaemon daemon;
  late ScopesDomain domain;

  late String projectPath;

  setUp(() async {
    domain = ScopesDomain(daemon = MockDaemon(), FakeLogger());
  });

  tearDown(() async {
    domain.dispose();
    try {
      await Directory(projectPath).delete(recursive: true);
    } catch (_) {}
  });

  Future<void> expectScopesResult(Object? data) async {
    await untilCalled(
      () => daemon.send(
        any(
          that: predicate<Map<String, Object?>>(
            (map) => map['event'] == 'scopes.status' && (map['params'] as Map<String, Object?>)[projectPath] == false,
          ),
        ),
      ),
    );

    final messages = verify(() => daemon.send(captureAny())).captured;
    expect(messages.length, 3);
    expect(
      messages[0],
      equals({
        'event': 'scopes.status',
        'params': {projectPath: true},
      }),
    );

    expect(
      messages[1],
      equals({
        'event': 'scopes.result',
        'params': data,
      }),
    );

    expect(
      messages[2],
      equals({
        'event': 'scopes.status',
        'params': {projectPath: false},
      }),
    );
  }

  group('scopes domain', () {
    test('analyzes simple scopes', () async {
      projectPath = setUpProject({
        'main.server.dart': '''
import 'package:jaspr/jaspr.dart';
import 'app.dart';

void main() {
  runApp(App());
}
''',
        'app.dart': '''
import 'package:jaspr/jaspr.dart';
import 'page.dart';

@client
class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Page();
  }
}
''',
        'page.dart': '''
import 'package:jaspr/jaspr.dart';

class Page extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return text('Hello, World!');
  }
}
''',
      });
      await domain.registerScopes({
        'folders': [projectPath],
      });

      await expectScopesResult({
        '$projectPath/lib/app.dart': {
          'components': ['App'],
          'clientScopeRoots': [
            {
              'path': '$projectPath/lib/app.dart',
              'name': 'App',
              'line': 5,
              'character': 7,
            },
          ],
          'serverScopeRoots': [
            {
              'path': '$projectPath/lib/main.server.dart',
              'name': 'main',
              'line': 4,
              'character': 6,
            },
          ],
        },
        '$projectPath/lib/page.dart': {
          'components': ['Page'],
          'clientScopeRoots': [
            {
              'path': '$projectPath/lib/app.dart',
              'name': 'App',
              'line': 5,
              'character': 7,
            },
          ],
          'serverScopeRoots': [
            {
              'path': '$projectPath/lib/main.server.dart',
              'name': 'main',
              'line': 4,
              'character': 6,
            },
          ],
        },
      });
    });

    test('analyzes multiple server entrypoints', () async {
      projectPath = setUpProject({
        'main.server.dart': '''
import 'package:jaspr/jaspr.dart';
import 'app.dart';

void main() {
  runApp(App());
}
''',
        'other.server.dart': '''
import 'package:jaspr/jaspr.dart';
import 'page.dart';

void main() {
  runApp(Page());
}
''',
        'app.dart': '''
import 'package:jaspr/jaspr.dart';
import 'page.dart';

@client
class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Page();
  }
}
''',
        'page.dart': '''
import 'package:jaspr/jaspr.dart';

class Page extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return text('Hello, World!');
  }
}
''',
      });
      await domain.registerScopes({
        'folders': [projectPath],
      });

      await expectScopesResult({
        '$projectPath/lib/app.dart': {
          'components': ['App'],
          'clientScopeRoots': [
            {
              'path': '$projectPath/lib/app.dart',
              'name': 'App',
              'line': 5,
              'character': 7,
            },
          ],
          'serverScopeRoots': [
            {
              'path': '$projectPath/lib/main.server.dart',
              'name': 'main',
              'line': 4,
              'character': 6,
            },
          ],
        },
        '$projectPath/lib/page.dart': {
          'components': ['Page'],
          'clientScopeRoots': [
            {
              'path': '$projectPath/lib/app.dart',
              'name': 'App',
              'line': 5,
              'character': 7,
            },
          ],
          'serverScopeRoots': [
            {
              'path': '$projectPath/lib/other.server.dart',
              'name': 'main',
              'line': 4,
              'character': 6,
            },
            {
              'path': '$projectPath/lib/main.server.dart',
              'name': 'main',
              'line': 4,
              'character': 6,
            },
          ],
        },
      });
    });

    test('analyzes unallowed imports', () async {
      projectPath = setUpProject({
        'main.server.dart': '''
import 'package:jaspr/jaspr.dart';
import 'app.dart';

void main() {
  runApp(App());
}
''',
        'app.dart': '''
import 'package:jaspr/server.dart';
import 'package:web/web.dart';

@client
class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return text('Hello, World!');
  }
}
''',
      });
      await domain.registerScopes({
        'folders': [projectPath],
      });

      await expectScopesResult({
        '$projectPath/lib/app.dart': {
          'components': ['App'],
          'clientScopeRoots': [
            {
              'path': '$projectPath/lib/app.dart',
              'name': 'App',
              'line': 5,
              'character': 7,
            },
          ],
          'serverScopeRoots': [
            {
              'path': '$projectPath/lib/main.server.dart',
              'name': 'main',
              'line': 4,
              'character': 6,
            },
          ],
          'invalidDependencies': [
            {
              'uri': 'package:jaspr/server.dart',
              'invalidOnClient': {
                'uri': 'package:jaspr/server.dart',
                'target': 'package:jaspr/server.dart',
                'line': 1,
                'character': 1,
                'length': 35,
              },
            },
            {
              'uri': 'package:web/web.dart',
              'invalidOnServer': {
                'uri': 'package:web/web.dart',
                'target': 'package:web/web.dart',
                'line': 2,
                'character': 1,
                'length': 30,
              },
            },
          ],
        },
      });
    });
  });
}

String setUpProject(Map<String, String> files) {
  final tempDir = Directory.systemTemp.createTempSync('jaspr_test_project_');
  final projectPath = tempDir.path;

  Directory('$projectPath/lib').createSync(recursive: true);

  File('$projectPath/pubspec.yaml').writeAsStringSync('''
name: project
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  jaspr: any
jaspr:
  mode: server
''');

  for (final entry in files.entries) {
    final file = File('$projectPath/lib/${entry.key}');
    file.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
  }

  Process.runSync('dart', ['pub', 'get'], workingDirectory: projectPath);

  return projectPath;
}
