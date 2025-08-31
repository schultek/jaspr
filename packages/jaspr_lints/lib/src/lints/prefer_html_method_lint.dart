import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show AnalysisError;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../all_html_tags.dart';
import '../utils.dart';

enum ComponentType { text, element, fragment }

class PreferHtmlMethodLint extends DartLintRule {
  PreferHtmlMethodLint()
      : super(
          code: LintCode(
            name: 'prefer_html_methods',
            problemMessage: "Prefer using '{0}(...)' over 'Component.element(tag: \"{0}\", ...)'",
          ),
        );

  final textCode = LintCode(
    name: 'prefer_html_methods',
    problemMessage: "Prefer using 'text(...)' over 'Component.text(...)'",
  );

  final fragmentCode = LintCode(
    name: 'prefer_html_methods',
    problemMessage: "Prefer using 'fragment(...)' over 'Component.fragment(children: ...)'",
  );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addInstanceCreationExpression((node) {
      if (node.constructorName.type.name2.lexeme != 'Component') {
        return;
      }
      if (!isComponentType(node.staticType)) {
        return;
      }
      if (node.isConst) {
        // Allow when used with const.
        return;
      }
      if (node.constructorName.name?.name == 'element') {
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
          offset: node.constructorName.offset,
          length: node.constructorName.length,
          errorCode: code,
          arguments: [tag],
          data: (ComponentType.element, node, tag),
        );
      }
      if (node.constructorName.name?.name == 'text') {
        reporter.atOffset(
          offset: node.constructorName.offset,
          length: node.constructorName.length,
          errorCode: textCode,
          data: (ComponentType.text, node),
        );
      }
      if (node.constructorName.name?.name == 'fragment') {
        reporter.atOffset(
          offset: node.constructorName.offset,
          length: node.constructorName.length,
          errorCode: fragmentCode,
          data: (ComponentType.fragment, node),
        );
      }
    });
  }

  @override
  List<Fix> getFixes() => [
    PreferHtmlMethodFix()
  ];
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
    if (analysisError.data case (ComponentType.element, InstanceCreationExpression node, String tag)) {
      reporter.createChangeBuilder(message: 'Convert to $tag() method', priority: 2).addDartFileEdit((builder) {
        for (var argument in node.argumentList.arguments) {
          if (argument is NamedExpression) {
            var name = argument.name.label.name;
            if (name == 'tag') {
              int end;
              if (argument.endToken.next case final next? when next.lexeme == ',') {
                end = next.next?.offset ?? next.end;
              } else {
                end = argument.endToken.next?.offset ?? argument.end;
              }
              builder.addDeletion(SourceRange(argument.offset, end - argument.offset));
            } else if (name == 'children') {
              var end = argument.name.endToken.next?.offset ?? argument.end;
              builder.addDeletion(SourceRange(argument.name.offset, end - argument.name.offset));
            }
          }
        }

        builder.addSimpleReplacement(node.constructorName.sourceRange, tag);
      });
    } else if (analysisError.data case (ComponentType.text, InstanceCreationExpression node)) {
      reporter.createChangeBuilder(message: 'Convert to text() method', priority: 2).addDartFileEdit((builder) {
        builder.addSimpleReplacement(node.constructorName.sourceRange, 'text');
      });
    } else if (analysisError.data case (ComponentType.fragment, InstanceCreationExpression node)) {
      reporter.createChangeBuilder(message: 'Convert to fragment() method', priority: 2).addDartFileEdit((builder) {
        for (var argument in node.argumentList.arguments) {
          if (argument is NamedExpression) {
            var name = argument.name.label.name;
            if (name == 'children') {
              var end = argument.name.endToken.next?.offset ?? argument.end;
              builder.addDeletion(SourceRange(argument.name.offset, end - argument.name.offset));
            }
          }
        }

        builder.addSimpleReplacement(node.constructorName.sourceRange, 'fragment');
      });
    }
  }
}
