import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
// ignore: depend_on_referenced_packages
import 'package:analyzer_plugin/protocol/protocol_common.dart' show LinkedEditSuggestionKind;

import '../assist.dart';
import '../utils.dart';

abstract class WrapWithAssist extends ResolvedCorrectionProducer {
  WrapWithAssist({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node
        case NamedType(parent: ConstructorName(parent: InstanceCreationExpression node)) ||
            SimpleIdentifier(parent: ConstructorName(parent: InstanceCreationExpression node))) {
      if (!isComponentType(node.staticType)) {
        return;
      }

      final indent = utils.getLinePrefix(node.offset);
      final lines = getRangeText(node.sourceRange).split('\n');

      await builder.addDartFileEdit(file, (builder) {
        builder.addReplacement(node.sourceRange, (edit) {
          wrapLines(edit, lines, indent);
        });
      });
    }
  }

  void wrapLines(DartEditBuilder edit, List<String> lines, String indent);
}

class WrapWithHtml extends WrapWithAssist {
  WrapWithHtml({required super.context});

  @override
  AssistKind get assistKind => JasprAssistKind.wrapWithHtml;

  @override
  void wrapLines(DartEditBuilder edit, List<String> lines, String indent) {
    edit.addSimpleLinkedEdit(
      'html',
      'div',
      kind: LinkedEditSuggestionKind.METHOD,
      suggestions: ['div', 'span', 'p', 'section', 'ul', 'li', 'h1', 'button', 'a'],
    );
    edit.write('([\n$indent${lines.map((s) => '  $s').join('\n')},\n$indent])');
  }
}

class WrapWithComponent extends WrapWithAssist {
  WrapWithComponent({required super.context});

  @override
  AssistKind get assistKind => JasprAssistKind.wrapWithComponent;

  @override
  void wrapLines(DartEditBuilder edit, List<String> lines, String indent) {
    edit.addSimpleLinkedEdit('comp', 'MyComponent');
    edit.write('(\n');
    edit.write(indent);
    edit.write('  child: ');
    edit.write(lines[0]);
    edit.write(lines.skip(1).map((s) => '\n  $s').join());
    edit.write(',\n$indent)');
  }
}

class WrapWithBuilder extends WrapWithAssist {
  WrapWithBuilder({required super.context});

  @override
  AssistKind get assistKind => JasprAssistKind.wrapWithBuilder;

  @override
  void wrapLines(DartEditBuilder edit, List<String> lines, String indent) {
    edit.write('Builder(builder: (context) {\n');
    edit.write(indent);
    edit.write('  return ');
    edit.write(lines[0]);
    edit.write(lines.skip(1).map((s) => '\n  $s').join());
    edit.write(';\n$indent})');
  }
}

class RemoveComponent extends ResolvedCorrectionProducer {
  RemoveComponent({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => JasprAssistKind.removeComponent;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node
        case NamedType(parent: ConstructorName(parent: InstanceCreationExpression node)) ||
            SimpleIdentifier(parent: ConstructorName(parent: InstanceCreationExpression node))) {
      if (!isComponentType(node.staticType)) {
        return;
      }

      final indent = utils.getLinePrefix(node.offset);

      var children = <AstNode>[
        for (var arg in node.argumentList.arguments)
          if (arg is NamedExpression)
            if (arg.name.label.name == 'child' && isComponentType(arg.staticType))
              arg.expression
            else if (arg.name.label.name == 'children' && arg.expression is ListLiteral)
              ...(arg.expression as ListLiteral).elements
            else
              ...[]
          else if (arg is ListLiteral)
            ...arg.elements,
      ];

      if (children.isEmpty) {
        return;
      }

      if (children.length == 1 && children.single is Expression) {
        await builder.addDartFileEdit(file, (builder) {
          builder.addReplacement(node.sourceRange, (edit) {
            var child = children.first;
            var childIndent = utils.getLinePrefix(child.offset);
            edit.write(getRangeText(child.sourceRange).reIndent(indent.length - childIndent.length, skipFirst: true));
          });
        });
      } else if (node.parent is ListLiteral) {
        await builder.addDartFileEdit(file, (builder) {
          builder.addReplacement(node.sourceRange, (edit) {
            for (var child in children) {
              var childIndent = utils.getLinePrefix(child.offset);
              var source = getRangeText(
                child.sourceRange,
              ).reIndent(indent.length - childIndent.length, skipFirst: true);

              if (child != children.first) {
                edit.write(indent);
              }
              edit.write(source);
              if (child != children.last) {
                edit.write(',\n');
              }
            }
          });
        });
      } else if (node.parent is ReturnStatement) {
        await builder.addDartFileEdit(file, (builder) {
          builder.addReplacement(node.constructorName.sourceRange, (edit) {
            edit.write('Component.fragment');
          });
        });
      }
    }
  }
}

class ExtractComponent extends ResolvedCorrectionProducer {
  ExtractComponent({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => JasprAssistKind.extractComponent;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node
        case NamedType(parent: ConstructorName(parent: InstanceCreationExpression node)) ||
            SimpleIdentifier(parent: ConstructorName(parent: InstanceCreationExpression node))) {
      if (!isComponentType(node.staticType)) {
        return;
      }

      final indent = utils.getLinePrefix(node.offset);
      final source = getRangeText(node.sourceRange).reIndent(4 - indent.length, skipFirst: true);

      await builder.addDartFileEdit(file, (builder) {
        builder.addReplacement(node.sourceRange, (edit) {
          edit.addSimpleLinkedEdit('comp', 'MyComponent');
          edit.write('()');
        });

        builder.addInsertion(unit.end, (edit) {
          edit.write('\nclass ');
          edit.addSimpleLinkedEdit('comp', 'MyComponent');
          edit.write(
            ' extends StatelessComponent {\n'
            '  const ',
          );
          edit.addSimpleLinkedEdit('comp', 'MyComponent');
          edit.write(
            '();\n'
            '\n'
            '  @override\n'
            '  Component build(BuildContext context) {\n'
            '    return ',
          );
          edit.write(source);
          edit.write(
            ';\n'
            '  }\n}\n',
          );
        });
      });
    }
  }
}
