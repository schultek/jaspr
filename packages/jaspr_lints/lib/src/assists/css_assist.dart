import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

class CssAssistProvider extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addInvocationExpression((node) {
      if (!target.coveredBy(node.function.sourceRange)) {
        return;
      }
      if (!isComponentType(node.staticType)) {
        return;
      }
      if (node.staticInvokeType case FunctionType t when hasClassesParameter(t.parameters)) {
        final indent = getLineIndent(resolver.lineInfo, node);
        addStyles(resolver, reporter, node, indent, node.argumentList);
      }
    });
    context.registry.addInstanceCreationExpression((node) {
      if (!target.coveredBy(node.constructorName.sourceRange)) {
        return;
      }
      if (!isComponentType(node.staticType)) {
        return;
      }
      if (!hasClassesParameter(node.constructorName.staticElement?.parameters)) {
        return;
      }
      final indent = getLineIndent(resolver.lineInfo, node);
      addStyles(resolver, reporter, node, indent, node.argumentList);
    });
  }

  void addStyles(CustomLintResolver resolver, ChangeReporter reporter, Expression node, int lineIndent,
      ArgumentList argumentList) {
    var comp = findParentComponent(node);
    if (comp == null) {
      return;
    }

    var idArg = argumentList.arguments.whereType<NamedExpression>().where((e) => e.name.label.name == 'id').firstOrNull;
    var idVal = idArg?.expression is StringLiteral ? (idArg!.expression as StringLiteral).stringValue : null;

    var classesArg =
        argumentList.arguments.whereType<NamedExpression>().where((e) => e.name.label.name == 'classes').firstOrNull;
    var classesVal = classesArg?.expression is StringLiteral
        ? (classesArg!.expression as StringLiteral).stringValue?.split(' ').first
        : null;

    var styles = comp.$1.members
        .where((m) => m.metadata.where((a) => a.name.name == 'css').isNotEmpty)
        .map((m) => switch (m) {
              MethodDeclaration(body: BlockFunctionBody body) =>
                body.block.statements.whereType<ReturnStatement>().firstOrNull?.expression,
              MethodDeclaration(body: ExpressionFunctionBody body) => body.expression,
              FieldDeclaration() => m.fields.variables.first.initializer,
              _ => null,
            })
        .whereType<ListLiteral>()
        .firstOrNull;

    if (styles == null) {
      final cb = reporter.createChangeBuilder(
        priority: 1,
        message: 'Add styles',
      );

      cb.addDartFileEdit((builder) {
        builder.addInsertion(comp.$2.end, (edit) {
          edit.write('\n\n  @css\n  static final List<StyleRule> styles = [\n    css(\'');
          if (idVal != null) {
            edit.write('#$idVal\').');
          } else if (classesVal != null) {
            edit.write('.$classesVal\').');
          } else {
            edit.write('.');
            edit.addSimpleLinkedEdit('className', 'classname');
            edit.write('\').');
          }
          edit.addSimpleLinkedEdit('styles', 'box',
              kind: LinkedEditSuggestionKind.METHOD,
              suggestions: ['box', 'text', 'background', 'flexbox', 'flexItem', 'grid', 'gridItem', 'list']);
          edit.write('(),\n  ];');
        });

        if (idVal == null && classesVal == null) {
          if (classesArg != null) {
            builder.addInsertion(classesArg.expression.offset, (edit) {
              edit.write("'");
              edit.addSimpleLinkedEdit('className', 'classname');
              edit.write(" \${");
            });
            builder.addInsertion(classesArg.expression.end, (edit) {
              edit.write("}'");
            });
          } else {
            builder.addInsertion(idArg?.end ?? argumentList.leftParenthesis.end, (edit) {
              edit.write("classes: '");
              edit.addSimpleLinkedEdit('className', 'classname');
              edit.write("', ");
            });
          }
        }
      });
    } else {}
  }
}
