// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:jaspr_lints/src/rules/styles_ordering_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../jaspr_package.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(StylesOrderingRuleTest);
  });
}

@reflectiveTest
class StylesOrderingRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = StylesOrderingRule();
    setUpJasprPackage();
    super.setUp();
  }

  // --- Styles() constructor tests ---

  void test_constructor_correct_order() async {
    await assertNoDiagnostics(
      "import 'package:jaspr/dom.dart';\n\n"
      'Styles run() {\n'
      '  return Styles(display: "block", width: "100px", color: "red");\n'
      '}',
    );
  }

  void test_constructor_wrong_order() async {
    await assertDiagnostics(
      "import 'package:jaspr/dom.dart';\n\n"
      'Styles run() {\n'
      '  return Styles(color: "red", display: "block", width: "100px");\n'
      '}',
      [
        lint(79, 16),
      ],
    );
  }

  void test_constructor_single_param() async {
    await assertNoDiagnostics(
      "import 'package:jaspr/dom.dart';\n\n"
      'Styles run() {\n'
      '  return Styles(color: "red");\n'
      '}',
    );
  }

  // --- styles() method tests ---

  void test_method_correct_order() async {
    await assertNoDiagnostics(
      "import 'package:jaspr/dom.dart';\n\n"
      'void run() {\n'
      '  css.styles(display: "block", width: "100px", color: "red");\n'
      '}',
    );
  }

  void test_method_wrong_order() async {
    await assertDiagnostics(
      "import 'package:jaspr/dom.dart';\n\n"
      'void run() {\n'
      '  css.styles(color: "red", display: "block", width: "100px");\n'
      '}',
      [
        lint(74, 16),
      ],
    );
  }
}
