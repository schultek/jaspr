// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:jaspr_lints/src/rules/prefer_html_components_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../jaspr_package.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferHtmlComponentsRuleTest);
  });
}

@reflectiveTest
class PreferHtmlComponentsRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = PreferHtmlComponentsRule();
    setUpJasprPackage();
    super.setUp();
  }

  void test_uses_known_tag() async {
    await assertDiagnostics(
      "import 'package:jaspr/jaspr.dart';\n\n"
      'Component run() {\n'
      "  return Component.element(tag: 'div');\n"
      '}',
      [
        lint(
          63,
          17,
          messageContainsAll: ["Prefer using 'div(...)' over 'Component.element(tag: \"div\", ...)'"],
        ),
      ],
    );
  }

  void test_uses_unknown_tag() async {
    await assertNoDiagnostics(
      "import 'package:jaspr/jaspr.dart';\n\n"
      'Component run() {\n'
      "  return Component.element(tag: 'unknown');\n"
      '}',
    );
  }

  void test_uses_known_tag_dot_shorthand() async {
    await assertDiagnostics(
      "import 'package:jaspr/jaspr.dart';\n\n"
      'Component run() {\n'
      "  return .element(tag: 'div');\n"
      '}',
      [
        lint(
          63,
          8,
          messageContainsAll: ["Prefer using 'div(...)' over 'Component.element(tag: \"div\", ...)'"],
        ),
      ],
    );
  }

  void test_uses_unknown_tag_dot_shorthand() async {
    await assertNoDiagnostics(
      "import 'package:jaspr/jaspr.dart';\n\n"
      'Component run() {\n'
      "  return .element(tag: 'unknown');\n"
      '}',
    );
  }

  void test_uses_known_tag_dot_shorthand_nested() async {
    await assertDiagnostics(
      "import 'package:jaspr/jaspr.dart';\n\n"
      'Component run() {\n'
      '  return div([\n'
      "    .element(tag: 'p'),\n"
      '  ]);\n'
      '}',
      [
        lint(
          73,
          8,
          messageContainsAll: ["Prefer using 'p(...)' over 'Component.element(tag: \"p\", ...)'"],
        ),
      ],
    );
  }
}
