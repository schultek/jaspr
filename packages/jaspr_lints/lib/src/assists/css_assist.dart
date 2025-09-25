import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

class CssAssistProvider extends DartAssist {
  @override
  void run(CustomLintResolver resolver, ChangeReporter reporter, CustomLintContext context, SourceRange target) {
    var config = readJasprConfig(resolver.path);
    if (config['mode'] != 'server' && config['mode'] != 'static') {
      return;
    }

    context.registry.addInvocationExpression((node) {
      if (!target.coveredBy(node.function.sourceRange)) {
        return;
      }
      if (isComponentType(node.staticType)) {
        if (node.staticInvokeType case FunctionType t when hasClassesParameter(t.formalParameters)) {
          final indent = getLineIndent(resolver.lineInfo, node);
          addStyles(resolver, reporter, node, indent, node.argumentList);
        }
      }

      final css = getCssInvocation(node);
      if (css != null) {
        final indent = getLineIndent(resolver.lineInfo, node);
        convertToNested(resolver, reporter, css, indent);
      }
    });
    context.registry.addInstanceCreationExpression((node) {
      if (!target.coveredBy(node.constructorName.sourceRange)) {
        return;
      }
      if (!isComponentType(node.staticType)) {
        return;
      }
      if (!hasClassesParameter(node.constructorName.element?.formalParameters)) {
        return;
      }
      final indent = getLineIndent(resolver.lineInfo, node);
      addStyles(resolver, reporter, node, indent, node.argumentList);
    });
  }

  InvocationExpression? getCssInvocation(InvocationExpression node) {
    var parent = node.function.parent;
    if (parent is MethodInvocation) {
      var target = parent.realTarget;
      if (target is InvocationExpression) {
        return getCssInvocation(target);
      }
    }
    if (node.function case SimpleIdentifier(name: 'css', staticType: final InterfaceType type)) {
      if (type.element.name == 'CssUtility' &&
          type.element.library.identifier == 'package:jaspr/src/foundation/styles/css.dart') {
        return node;
      }
    }
    return null;
  }

  void addStyles(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    Expression node,
    int lineIndent,
    ArgumentList argumentList,
  ) {
    var comp = findParentComponent(node);
    if (comp == null) {
      return;
    }

    var idArg = argumentList.arguments.whereType<NamedExpression>().where((e) => e.name.label.name == 'id').firstOrNull;
    var idVal = idArg?.expression is StringLiteral ? (idArg!.expression as StringLiteral).stringValue : null;

    var classesArg = argumentList.arguments
        .whereType<NamedExpression>()
        .where((e) => e.name.label.name == 'classes')
        .firstOrNull;
    var classesVal = classesArg?.expression is StringLiteral
        ? (classesArg!.expression as StringLiteral).stringValue?.split(' ').first
        : null;

    var styles = comp.$1.members
        .where((m) => m.metadata.where((a) => a.name.name == 'css').isNotEmpty)
        .map(
          (m) => switch (m) {
            MethodDeclaration(body: BlockFunctionBody body) =>
              body.block.statements.whereType<ReturnStatement>().firstOrNull?.expression,
            MethodDeclaration(body: ExpressionFunctionBody body) => body.expression,
            FieldDeclaration() => m.fields.variables.first.initializer,
            _ => null,
          },
        )
        .whereType<ListLiteral>()
        .firstOrNull;

    reporter.createChangeBuilder(priority: 1, message: 'Add styles').addDartFileEdit((builder) {
      void writeCssRule(DartEditBuilder edit) {
        edit.write('  css(\'');
        if (idVal != null) {
          edit.write('#$idVal');
        } else if (classesVal != null) {
          edit.write('.$classesVal');
        } else {
          edit.write('.');
          edit.addSimpleLinkedEdit('className', 'classname');
        }
        edit.write('\').styles(),\n  ');
      }

      if (styles == null) {
        builder.addInsertion(comp.$2.end, (edit) {
          edit.write('\n\n  @css\n  static List<StyleRule> get styles => [\n  ');
          writeCssRule(edit);
          edit.write('];');
        });
      } else {
        builder.addInsertion(styles.rightBracket.offset, (edit) {
          writeCssRule(edit);
        });
      }

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
  }

  void convertToNested(CustomLintResolver resolver, ChangeReporter reporter, InvocationExpression css, int lineIndent) {
    if (css.argumentList.arguments.length != 1) {
      return;
    }

    var selector = css.argumentList.arguments.first;
    var chain = getFullChain(css.parent);

    var start = selector.end;
    var end = chain?.end ?? css.end;

    reporter.createChangeBuilder(priority: 1, message: 'Convert to nested styles').addDartFileEdit((builder) {
      var content = resolver.source.contents.data.substring(start, end);
      content = content.split('\n').join('\n  ');
      builder.addReplacement(SourceRange(start, end - start), (edit) {
        edit.write(', [\n${''.padLeft(lineIndent)}  css(\'&\'');
        edit.write(content);
        edit.write(',\n${''.padLeft(lineIndent)}])');
      });
    });
  }

  MethodInvocation? getFullChain(AstNode? node) {
    if (node is MethodInvocation) {
      return getFullChain(node.parent) ?? node;
    } else {
      return null;
    }
  }
}
