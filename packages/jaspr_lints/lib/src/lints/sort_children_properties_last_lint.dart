import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

class SortChildrenPropertiesLastLint extends DartLintRule {
  SortChildrenPropertiesLastLint()
    : super(
        code: LintCode(
          name: 'sort_children_properties_last',
          problemMessage: 'Sort children properties last in html component methods.',
          correctionMessage: 'This improves readability and best represents actual html.',
        ),
      );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    context.registry.addInvocationExpression((node) {
      if (!isComponentType(node.staticType)) {
        return;
      }
      ListLiteral? childrenArg;
      var violatesLint = false;
      for (var argument in node.argumentList.arguments) {
        if (argument is ListLiteral && isComponentListType(argument.staticType)) {
          childrenArg = argument;
        } else if (childrenArg != null && argument is NamedExpression) {
          violatesLint = true;
        }
      }
      if (violatesLint) {
        reporter.atOffset(offset: node.offset, length: node.length, diagnosticCode: code, data: (node, childrenArg));
      }
    });
  }

  @override
  List<Fix> getFixes() => [SortChildrenPropertiesLastFix()];
}

class SortChildrenPropertiesLastFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    Diagnostic analysisError,
    List<Diagnostic> others,
  ) {
    if (analysisError.data case (InvocationExpression node, ListLiteral childrenArg)) {
      reporter.createChangeBuilder(message: 'Sort children last', priority: 2).addDartFileEdit((builder) {
        var content = resolver.source.contents.data;

        var nextArg = node.argumentList.arguments[node.argumentList.arguments.indexOf(childrenArg) + 1];

        var start = childrenArg.end;
        var argStart = nextArg.offset;
        var end = node.argumentList.arguments.last.end;

        var divider = content.substring(start, argStart);
        var args = content.substring(argStart, end);

        builder.addInsertion(childrenArg.offset, (edit) {
          edit.write(args);
          edit.write(divider);
        });

        builder.addDeletion(SourceRange(start, end - start));
      });
    }
  }
}
