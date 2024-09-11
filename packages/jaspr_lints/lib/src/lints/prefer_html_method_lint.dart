import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show AnalysisError;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../all_html_tags.dart';
import '../utils.dart';

class PreferHtmlMethodLint extends DartLintRule {
  PreferHtmlMethodLint()
      : super(
          code: LintCode(
            name: 'prefer_html_method',
            problemMessage: 'Prefer a html component method over DomComponent',
            correctionMessage: "Replace 'DomComponent(tag: \"{0}\", ...)' with '{0}(...)'",
          ),
        );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addInstanceCreationExpression((node) {
      if (node.constructorName.type.name2.lexeme != 'DomComponent') {
        return;
      }
      if (!isComponentType(node.staticType)) {
        return;
      }
      var tag = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((n) => n.name.label.name == 'tag')
          .map((n) => n.expression)
          .whereType<SimpleStringLiteral>()
          .firstOrNull
          ?.value;
      if (tag == null || !allHtmlTags.contains(tag)) {
        return;
      }
      reporter.atOffset(
        offset: node.offset,
        length: node.length,
        errorCode: code,
        arguments: [tag],
        data: (node, tag),
      );
    });
  }

  @override
  List<Fix> getFixes() => [PreferHtmlMethodFix()];
}

class PreferHtmlMethodFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    if (analysisError.data case (InstanceCreationExpression node, String tag)) {
      reporter.createChangeBuilder(message: 'Convert to html method', priority: 2).addDartFileEdit((builder) {
        var content = resolver.source.contents.data;

        Expression? childrenArg;
        Expression? childArg;

        for (var argument in node.argumentList.arguments) {
          if (argument is NamedExpression) {
            var name = argument.name.label.name;
            if (name == 'tag') {
              var end = argument.endToken.next?.lexeme == ',' ? argument.endToken.next!.end : argument.end;
              builder.addDeletion(SourceRange(argument.offset, end - argument.offset));
            } else if (name == 'children') {
              builder.addDeletion(argument.name.sourceRange);
              childrenArg = argument.expression;
            } else if (name == 'child') {
              var end = argument.endToken.next?.lexeme == ',' ? argument.endToken.next!.end : argument.end;
              builder.addDeletion(SourceRange(argument.offset, end - argument.offset));
              childArg = argument.expression;
            }
          }
        }

        builder.addReplacement(node.constructorName.sourceRange, (edit) {
          edit.write(tag);
        });

        if (childArg != null) {
          var end = childArg.endToken.next?.lexeme == ',' ? childArg.endToken.next!.end : childArg.end;
          var childSource = content.substring(childArg.offset, end);
          if (childrenArg != null) {
            if (childrenArg is ListLiteral) {
              builder.addInsertion(childrenArg.rightBracket.offset, (edit) {
                var hasEndingComma = (childrenArg as ListLiteral).rightBracket.previous?.lexeme == ',';
                if (!hasEndingComma) {
                  edit.write(',');
                }
                edit.write(childSource);
              });
            }
          } else {
            builder.addInsertion(node.argumentList.rightParenthesis.offset, (edit) {
              edit.write('[');
              edit.write(childSource);
              edit.write(']');
            });
          }
        }

        builder.format(node.sourceRange);
      });
    }
  }
}
