import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show AnalysisError;
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
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
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
        reporter.atOffset(offset: node.offset, length: node.length, errorCode: code, data: (node, childrenArg));
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
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    if (analysisError.data case (InvocationExpression node, ListLiteral childrenArg)) {
      reporter.createChangeBuilder(message: 'Sort children last', priority: 2).addDartFileEdit((builder) {
        var content = resolver.source.contents.data;
        var lines = content.substring(childrenArg.offset, childrenArg.end);

        builder.addInsertion(node.argumentList.rightParenthesis.offset, (edit) {
          if (node.argumentList.rightParenthesis.previous?.lexeme != ',') {
            edit.write(', ');
          }
          edit.write(lines);
        });

        var nextArg = node.argumentList.arguments[node.argumentList.arguments.indexOf(childrenArg) + 1];
        builder.addDeletion(SourceRange(childrenArg.offset, nextArg.offset - childrenArg.offset));
      });
    }
  }
}
