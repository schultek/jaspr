// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:jaspr_lints/src/rules/unsafe_imports_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../jaspr_package.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UnsafeImportsServerTest);
    defineReflectiveTests(UnsafeImportsClientTest);
    defineReflectiveTests(UnsafeImportsComponentTest);
  });
}

abstract class UnsafeImportsBaseTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = UnsafeImportsRule(resourceProvider: resourceProvider);
    setUpJasprPackage();
    super.setUp();
  }
}

@reflectiveTest
class UnsafeImportsServerTest extends UnsafeImportsBaseTest {
  @override
  String get testFileName => 'main.server.dart';

  void test_import_js_interop_fails() async {
    await assertDiagnostics(
      '// ignore_for_file: unused_import\n'
      "import 'dart:js_interop';",
      [
        lint(
          34,
          25,
          messageContainsAll: [
            "Unsafe import: 'dart:js_interop' is not available on the server.\nTry using 'package:universal_web/js_interop.dart' instead.",
          ],
        ),
      ],
    );
  }

  void test_import_js_interop_transitive_fails() async {
    final aFile = newFile('$testPackageLibPath/a.dart', "import 'dart:js_interop';");
    final bFile = newFile('$testPackageLibPath/b.dart', "import 'a.dart';\nimport 'package:jaspr/client.dart';");

    final message =
        "Unsafe import: 'b.dart' imports other unsafe libraries which are not available on the server. See below for details.";
    final contextMessageText =
        "Unsafe import 'dart:js_interop'. Try using 'package:universal_web/js_interop.dart' instead.";
    final contextMessageText2 =
        "Unsafe import 'package:jaspr/client.dart'. Try using 'package:jaspr/jaspr.dart' instead.";

    await assertDiagnostics(
      '// ignore_for_file: unused_import\n'
      "import 'b.dart';",
      [
        lint(
          34,
          16,
          messageContainsAll: [message],
          contextMessages: [
            contextMessage(aFile, 7, 17, textContains: [contextMessageText]),
            contextMessage(bFile, 24, 27, textContains: [contextMessageText2]),
          ],
        ),
      ],
    );
  }

  void test_import_io_ok() async {
    await assertNoDiagnostics(
      '// ignore_for_file: unused_import\n'
      "import 'dart:io';",
    );
  }
}

@reflectiveTest
class UnsafeImportsClientTest extends UnsafeImportsBaseTest {
  @override
  String get testFileName => 'main.client.dart';

  void test_import_io_fails() async {
    await assertDiagnostics(
      '// ignore_for_file: unused_import\n'
      "import 'dart:io';",
      [
        lint(
          34,
          17,
          messageContainsAll: [
            "Unsafe import: 'dart:io' is not available on the client.\nTry moving this out of the client scope or use a conditional import.",
          ],
        ),
      ],
    );
  }

  void test_import_io_transitive_fails() async {
    final aFile = newFile('$testPackageLibPath/a.dart', "import 'dart:io';");
    final bFile = newFile('$testPackageLibPath/b.dart', "import 'a.dart';\nimport 'package:jaspr/server.dart';");

    final message =
        "Unsafe import: 'b.dart' imports other unsafe libraries which are not available on the client. See below for details.";
    final contextMessageText =
        "Unsafe import 'dart:io'. Try moving this out of the client scope or use a conditional import.";
    final contextMessageText2 =
        "Unsafe import 'package:jaspr/server.dart'. Try using 'package:jaspr/jaspr.dart' instead.";

    await assertDiagnostics(
      '// ignore_for_file: unused_import\n'
      "import 'b.dart';",
      [
        lint(
          34,
          16,
          messageContainsAll: [message],
          contextMessages: [
            contextMessage(aFile, 7, 9, textContains: [contextMessageText]),
            contextMessage(bFile, 24, 27, textContains: [contextMessageText2]),
          ],
        ),
      ],
    );
  }

  void test_import_js_interop_ok() async {
    await assertNoDiagnostics(
      '// ignore_for_file: unused_import\n'
      "import 'dart:js_interop';",
    );
  }
}

@reflectiveTest
class UnsafeImportsComponentTest extends UnsafeImportsBaseTest {
  @override
  String get testFileName => 'component.dart';

  void test_client_component_import_io_fails() async {
    await assertDiagnostics(
      '// ignore_for_file: unused_import\n'
      "import 'package:jaspr/jaspr.dart';\n"
      "import 'dart:io';\n\n"
      '@client\n'
      'class MyComponent extends Component {}',
      [
        lint(
          69,
          17,
          messageContainsAll: [
            "Unsafe import: 'dart:io' is not available on the client.\nTry moving this out of the client scope or use a conditional import.",
          ],
        ),
      ],
    );
  }

  void test_client_component_import_io_transitive_fails() async {
    final aFile = newFile('$testPackageLibPath/a.dart', "import 'dart:io';");
    final bFile = newFile('$testPackageLibPath/b.dart', "import 'a.dart';\nimport 'package:jaspr/server.dart';");

    final message =
        "Unsafe import: 'b.dart' imports other unsafe libraries which are not available on the client. See below for details.";
    final contextMessageText =
        "Unsafe import 'dart:io'. Try moving this out of the client scope or use a conditional import.";
    final contextMessageText2 =
        "Unsafe import 'package:jaspr/server.dart'. Try using 'package:jaspr/jaspr.dart' instead.";

    await assertDiagnostics(
      '// ignore_for_file: unused_import\n'
      "import 'package:jaspr/jaspr.dart';\n"
      "import 'b.dart';\n\n"
      '@client\n'
      'class MyComponent extends Component {}',
      [
        lint(
          69,
          16,
          messageContainsAll: [message],
          contextMessages: [
            contextMessage(aFile, 7, 9, textContains: [contextMessageText]),
            contextMessage(bFile, 24, 27, textContains: [contextMessageText2]),
          ],
        ),
      ],
    );
  }
}

/*
class ScopesTest extends UnsafeImportsBaseTest {
  @override
  String get testFileName => 'main.server.dart';

  void test_scopes_file_is_created() {}
}

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
          'serverScopeRoots': unorderedEquals([
            {
              'path': '$projectPath/lib/main.server.dart',
              'name': 'main',
              'line': 4,
              'character': 6,
            },
            {
              'path': '$projectPath/lib/other.server.dart',
              'name': 'main',
              'line': 4,
              'character': 6,
            },
          ]),
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
    */
