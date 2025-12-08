import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/source_range.dart';

import '../assist.dart';
import '../utils.dart';

class AddStyles extends ResolvedCorrectionProducer {
  AddStyles({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => JasprAssistKind.addStyles;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final config = readJasprConfig(file);
    if (config == null || (config['mode'] != 'server' && config['mode'] != 'static')) {
      return;
    }
    if (node
        case NamedType(parent: ConstructorName(parent: final InstanceCreationExpression node)) ||
            SimpleIdentifier(parent: ConstructorName(parent: final InstanceCreationExpression node))) {
      if (!isComponentType(node.staticType)) {
        return;
      }
      if (!hasClassesParameter(node.constructorName.element?.formalParameters)) {
        return;
      }

      await addStyles(builder, node, node.argumentList);
    }
  }

  Future<void> addStyles(
    ChangeBuilder builder,
    Expression node,
    ArgumentList argumentList,
  ) async {
    final comp = findParentComponent(node);
    if (comp == null) {
      return;
    }

    final idArg = argumentList.arguments
        .whereType<NamedExpression>()
        .where((e) => e.name.label.name == 'id')
        .firstOrNull;
    final idVal = idArg?.expression is StringLiteral ? (idArg!.expression as StringLiteral).stringValue : null;

    final classesArg = argumentList.arguments
        .whereType<NamedExpression>()
        .where((e) => e.name.label.name == 'classes')
        .firstOrNull;
    final classesVal = classesArg?.expression is StringLiteral
        ? (classesArg!.expression as StringLiteral).stringValue?.split(' ').first
        : null;

    final styles = comp.$1.members
        .where((m) => m.metadata.where((a) => a.name.name == 'css').isNotEmpty)
        .map(
          (m) => switch (m) {
            MethodDeclaration(body: final BlockFunctionBody body) =>
              body.block.statements.whereType<ReturnStatement>().firstOrNull?.expression,
            MethodDeclaration(body: final ExpressionFunctionBody body) => body.expression,
            FieldDeclaration() => m.fields.variables.first.initializer,
            _ => null,
          },
        )
        .whereType<ListLiteral>()
        .firstOrNull;

    await builder.addDartFileEdit(file, (builder) {
      void writeCssRule(DartEditBuilder edit) {
        edit.write('  css(\'');
        if (idVal != null) {
          edit.write('#$idVal');
        } else if (classesVal != null) {
          edit.write('.$classesVal');
        } else {
          edit.write('.');
          edit.addSimpleLinkedEdit('className', 'myclass');
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
            edit.addSimpleLinkedEdit('className', 'myclass');
            edit.write(' \${');
          });
          builder.addInsertion(classesArg.expression.end, (edit) {
            edit.write("}'");
          });
        } else {
          builder.addInsertion(idArg?.end ?? argumentList.leftParenthesis.end, (edit) {
            edit.write("classes: '");
            edit.addSimpleLinkedEdit('className', 'myclass');
            edit.write("', ");
          });
        }
      }
    });
  }
}

class ConvertToNestedStyles extends ResolvedCorrectionProducer {
  ConvertToNestedStyles({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => JasprAssistKind.convertToNestedStyles;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final config = readJasprConfig(file);
    if (config == null || (config['mode'] != 'server' && config['mode'] != 'static')) {
      return;
    }
    if (node case SimpleIdentifier(parent: final MethodInvocation node)) {
      final css = getCssInvocation(node);
      if (css != null) {
        final indent = utils.getLinePrefix(node.offset);
        await convertToNested(builder, css, indent);
      }
    }
  }

  InvocationExpression? getCssInvocation(InvocationExpression node) {
    final parent = node.function.parent;
    if (parent is MethodInvocation) {
      final target = parent.realTarget;
      if (target is InvocationExpression) {
        return getCssInvocation(target);
      }
    }
    if (node.function case SimpleIdentifier(name: 'css', staticType: final InterfaceType type)) {
      if (type.element.name == 'CssUtility' &&
          type.element.library.identifier == 'package:jaspr/src/dom/styles/css.dart') {
        return node;
      }
    }
    return null;
  }

  Future<void> convertToNested(ChangeBuilder builder, InvocationExpression css, String lineIndent) async {
    if (css.argumentList.arguments.length != 1) {
      return;
    }

    final selector = css.argumentList.arguments.first;
    final chain = getFullChain(css.parent);

    final start = selector.end;
    final end = chain?.end ?? css.end;

    await builder.addDartFileEdit(file, (builder) {
      final content = getRangeText(SourceRange(start, end - start)).split('\n').join('\n  ');
      builder.addReplacement(SourceRange(start, end - start), (edit) {
        edit.write(', [\n$lineIndent  css(\'&\'');
        edit.write(content);
        edit.write(',\n$lineIndent])');
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
