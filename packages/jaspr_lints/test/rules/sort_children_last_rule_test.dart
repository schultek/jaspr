// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:jaspr_lints/src/rules/sort_children_last_rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../jaspr_package.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SortChildrenLastRuleTest);
  });
}

@reflectiveTest
class SortChildrenLastRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = SortChildrenLastRule();
    setUpJasprPackage();
    super.setUp();
  }

  void test_uses_children_first() async {
    await assertDiagnostics(
      "import 'package:jaspr/jaspr.dart';\n\n"
      'Component run() {\n'
      '  return div([p([], id: "test")], classes: "main");\n'
      '}',
      [
        lint(63, 41),
        lint(68, 17),
      ],
    );
  }

  void test_uses_children_last() async {
    await assertNoDiagnostics(
      "import 'package:jaspr/jaspr.dart';\n\n"
      'Component run() {\n'
      '  return div(classes: "main", [p(id: "test", [])]);\n'
      '}',
    );
  }
}
