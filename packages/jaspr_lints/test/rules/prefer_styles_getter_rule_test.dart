// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:jaspr_lints/src/rules/prefer_styles_getter_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../jaspr_package.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferStylesGetterRuleTest);
  });
}

@reflectiveTest
class PreferStylesGetterRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferStylesGetterRule();
    setUpJasprPackage();
    super.setUp();
  }

  void test_uses_global_variable() async {
    await assertDiagnostics(
      "import 'package:jaspr/dom.dart';\n\n"
      '@css\n'
      'final styles = [\n'
      '  StyleRule(),\n'
      '];',
      [
        lint(39, 12),
      ],
    );
  }

  void test_uses_static_field() async {
    await assertDiagnostics(
      "import 'package:jaspr/dom.dart';\n\n"
      'class MyComponent {\n'
      '  @css\n'
      '  static final styles = [\n'
      '    StyleRule(),\n'
      '  ];\n'
      '}',
      [
        lint(63, 19),
      ],
    );
  }

  void test_uses_global_getter() async {
    await assertNoDiagnostics(
      "import 'package:jaspr/dom.dart';\n\n"
      '@css\n'
      'List<StyleRule> get styles => [\n'
      '  StyleRule(),\n'
      '];',
    );
  }

  void test_uses_static_getter() async {
    await assertNoDiagnostics(
      "import 'package:jaspr/dom.dart';\n\n"
      'class MyComponent {\n'
      '  @css\n'
      '  static List<StyleRule> get styles => [\n'
      '    StyleRule(),\n'
      '  ];\n'
      '}',
    );
  }
}
