// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:jaspr_lints/src/rules/unsafe_imports_rule.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../jaspr_package.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UnsafeImportsServerTest);
    defineReflectiveTests(UnsafeImportsClientTest);
    defineReflectiveTests(UnsafeImportsComponentTest);
    defineReflectiveTests(UnsafeImportsStylesTest);
    defineReflectiveTests(ScopesTest);
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

@reflectiveTest
class UnsafeImportsStylesTest extends UnsafeImportsBaseTest {
  @override
  String get testFileName => 'component.dart';

  void test_styles_import_client_fails() async {
    final message =
        'Unsafe @css usage: Importing client-only libraries is not allowed when using @css. See below for details.';
    final contextMessageText =
        "Unsafe import 'package:jaspr/client.dart'. Try using 'package:jaspr/jaspr.dart' instead.";
    final contextMessageText2 =
        "Unsafe import 'dart:js_interop'. Try using 'package:universal_web/js_interop.dart' instead.";

    await assertDiagnostics(
      '// ignore_for_file: unused_import\n'
      "import 'package:jaspr/jaspr.dart';\n"
      "import 'package:jaspr/dom.dart';\n"
      "import 'package:jaspr/client.dart';\n"
      "import 'dart:js_interop';\n\n"
      'class MyComponent extends Component {\n'
      '  @css\n'
      '  static List<StyleRule> get styles => [];\n'
      '}',
      [
        lint(
          205,
          4,
          name: 'unsafe_css',
          messageContainsAll: [message],
          contextMessages: [
            contextMessage(testFile, 109, 27, textContains: [contextMessageText]),
            contextMessage(testFile, 145, 17, textContains: [contextMessageText2]),
          ],
        ),
      ],
    );
  }

  void test_styles_import_client_transitive_fails() async {
    final aFile = newFile('$testPackageLibPath/a.dart', "import 'package:jaspr/client.dart';");
    final bFile = newFile('$testPackageLibPath/b.dart', "import 'a.dart';\nimport 'dart:js_interop';");

    final message =
        'Unsafe @css usage: Importing client-only libraries is not allowed when using @css. See below for details.';
    final contextMessageText =
        "Unsafe import 'package:jaspr/client.dart'. Try using 'package:jaspr/jaspr.dart' instead.";
    final contextMessageText2 =
        "Unsafe import 'dart:js_interop'. Try using 'package:universal_web/js_interop.dart' instead.";

    await assertDiagnostics(
      '// ignore_for_file: unused_import\n'
      "import 'package:jaspr/jaspr.dart';\n"
      "import 'package:jaspr/dom.dart';\n"
      "import 'b.dart';\n\n"
      'class MyComponent extends Component {\n'
      '  @css\n'
      '  static List<StyleRule> get styles => [];\n'
      '}',
      [
        lint(
          160,
          4,
          name: 'unsafe_css',
          messageContainsAll: [message],
          contextMessages: [
            contextMessage(aFile, 7, 27, textContains: [contextMessageText]),
            contextMessage(bFile, 24, 17, textContains: [contextMessageText2]),
          ],
        ),
      ],
    );
  }
}

@reflectiveTest
class ScopesTest extends UnsafeImportsBaseTest {
  Future<Object?> getScopesFor(Map<String, String> files) async {
    final entrypoints = <String>[];
    for (final file in files.entries) {
      newFile('$testPackageLibPath/${file.key}', file.value);
      if (file.key.endsWith('.server.dart')) {
        entrypoints.add(file.key);
      }
    }

    for (final entrypoint in entrypoints) {
      final convertedPath = convertPath('$testPackageLibPath/$entrypoint');
      await resolveFile(convertedPath);
    }

    final scopesFile = resourceProvider.getFile(convertPath('$testPackageRootPath/.dart_tool/jaspr/scopes.json'));
    return jsonDecode(scopesFile.readAsStringSync());
  }

  Future<void> test_simple_scopes() async {
    final actualScopes = await getScopesFor({
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

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Page();
  }
}
      ''',
      'page.dart': '''
import 'package:jaspr/jaspr.dart';
import 'button.dart';

@client
class Page extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Button();
  }
}
      ''',
      'button.dart': '''
import 'package:jaspr/jaspr.dart';

class Button extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return text('Click me');
  }
}
      ''',
    });

    final expectedScopes = {
      'locations': {
        '0': {'path': '$testPackageLibPath/app.dart', 'name': 'App', 'line': 4, 'char': 7, 'length': 3},
        '1': {'path': '$testPackageLibPath/main.server.dart', 'name': 'main', 'line': 4, 'char': 6, 'length': 4},
        '2': {'path': '$testPackageLibPath/page.dart', 'name': 'Page', 'line': 5, 'char': 7, 'length': 4},
        '3': {'path': '$testPackageLibPath/button.dart', 'name': 'Button', 'line': 3, 'char': 7, 'length': 6},
      },
      'scopes': {
        '$testPackageLibPath/app.dart': {
          'components': ['0'],
          'serverScopeRoots': ['1'],
        },
        '$testPackageLibPath/page.dart': {
          'components': ['2'],
          'serverScopeRoots': ['1'],
          'clientScopeRoots': ['2'],
        },
        '$testPackageLibPath/button.dart': {
          'components': ['3'],
          'serverScopeRoots': ['1'],
          'clientScopeRoots': ['2'],
        },
      },
    };

    expect(actualScopes, equals(expectedScopes));
  }

  void test_multi_server_entrypoints() async {
    final actualScopes = await getScopesFor({
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

    final expectedScopes = {
      'locations': {
        '0': {'path': '$testPackageLibPath/app.dart', 'name': 'App', 'line': 5, 'char': 7, 'length': 3},
        '1': {'path': '$testPackageLibPath/main.server.dart', 'name': 'main', 'line': 4, 'char': 6, 'length': 4},
        '2': {'path': '$testPackageLibPath/page.dart', 'name': 'Page', 'line': 3, 'char': 7, 'length': 4},
        '3': {'path': '$testPackageLibPath/other.server.dart', 'name': 'main', 'line': 4, 'char': 6, 'length': 4},
      },
      'scopes': {
        '$testPackageLibPath/app.dart': {
          'components': ['0'],
          'serverScopeRoots': ['1'],
          'clientScopeRoots': ['0'],
        },
        '$testPackageLibPath/page.dart': {
          'components': ['2'],
          'serverScopeRoots': unorderedEquals(['1', '3']),
          'clientScopeRoots': ['0'],
        },
      },
    };

    expect(actualScopes, equals(expectedScopes));
  }

  void test_multi_client_components() async {
    final actualScopes = await getScopesFor({
      'main.server.dart': '''
import 'package:jaspr/jaspr.dart';
import 'home.dart';
import 'about.dart';

void main() {
  runApp(Home());
  runApp(About());
}
''',
      'home.dart': '''
import 'package:jaspr/jaspr.dart';
import 'button.dart';

@client
class Home extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Button();
  }
}
''',
      'about.dart': '''
import 'package:jaspr/jaspr.dart';
import 'button.dart';

@client
class About extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Button();
  }
}
''',
      'button.dart': '''
import 'package:jaspr/jaspr.dart';

class Button extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return text('Click me!');
  }
}
''',
    });

    final expectedScopes = {
      'locations': {
        '0': {'path': '$testPackageLibPath/home.dart', 'name': 'Home', 'line': 5, 'char': 7, 'length': 4},
        '1': {'path': '$testPackageLibPath/main.server.dart', 'name': 'main', 'line': 5, 'char': 6, 'length': 4},
        '2': {'path': '$testPackageLibPath/about.dart', 'name': 'About', 'line': 5, 'char': 7, 'length': 5},
        '3': {'path': '$testPackageLibPath/button.dart', 'name': 'Button', 'line': 3, 'char': 7, 'length': 6},
      },
      'scopes': {
        '$testPackageLibPath/home.dart': {
          'components': ['0'],
          'serverScopeRoots': ['1'],
          'clientScopeRoots': ['0'],
        },
        '$testPackageLibPath/about.dart': {
          'components': ['2'],
          'serverScopeRoots': ['1'],
          'clientScopeRoots': ['2'],
        },
        '$testPackageLibPath/button.dart': {
          'components': ['3'],
          'serverScopeRoots': ['1'],
          'clientScopeRoots': unorderedEquals(['0', '2']),
        },
      },
    };

    expect(actualScopes, equals(expectedScopes));
  }
}
