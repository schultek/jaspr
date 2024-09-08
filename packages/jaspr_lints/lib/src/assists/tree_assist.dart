import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:jaspr_lints/src/utils.dart';

class TreeAssistProvider extends DartAssist {
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
      final indent = getLineIndent(resolver.lineInfo, node);
      wrapComponent(resolver, reporter, node, indent);
      removeComponent(resolver, reporter, node, indent, node.argumentList);
    });
    context.registry.addInstanceCreationExpression((node) {
      if (!target.coveredBy(node.constructorName.sourceRange)) {
        return;
      }
      if (!isComponentType(node.staticType)) {
        return;
      }
      final indent = getLineIndent(resolver.lineInfo, node);
      wrapComponent(resolver, reporter, node, indent);
      removeComponent(resolver, reporter, node, indent, node.argumentList);
    });
  }

  void wrapComponent(CustomLintResolver resolver, ChangeReporter reporter, Expression node, int lineIndent) {
    var content = resolver.source.contents.data;
    var lines = content.substring(node.offset, node.end).split('\n');

    var htmlSource =
        '([\n${''.padLeft(lineIndent)}${lines.map((s) => '  ' + s).join('\n')},\n${''.padLeft(lineIndent)}])';

    void wrapWith(String name, [List<String>? suggestions]) {
      final cb = reporter.createChangeBuilder(
        priority: 2,
        message: 'Wrap with $name',
      );

      cb.addDartFileEdit((builder) {
        builder.addReplacement(node.sourceRange, (editBuilder) {
          if (suggestions != null) {
            editBuilder.addSimpleLinkedEdit(name, suggestions.first,
                kind: LinkedEditSuggestionKind.METHOD, suggestions: suggestions);
          } else {
            editBuilder.write(name);
          }
          editBuilder.write(htmlSource);
        });
      });
    }

    wrapWith('html...', ['div', 'section', 'ul', 'li', 'h1', 'p', 'span', 'button']);
    wrapWith('div');
    wrapWith('section');
    wrapWith('ul');
    wrapWith('li');

    final cb2 = reporter.createChangeBuilder(
      priority: 2,
      message: 'Wrap with component...',
    );

    cb2.addDartFileEdit((builder) {
      builder.addReplacement(node.sourceRange, (editBuilder) {
        editBuilder.addSimpleLinkedEdit('comp', 'component');
        editBuilder.write('(\n');
        editBuilder.write(''.padLeft(lineIndent, ' '));
        editBuilder.write('  child: ');
        editBuilder.writeln(lines[0]);
        editBuilder.write(lines.skip(1).map((s) => '  ' + s).join('\n'));
        editBuilder.write(',\n${''.padLeft(lineIndent, ' ')})');
      });
    });
  }

  void removeComponent(CustomLintResolver resolver, ChangeReporter reporter, Expression node, int lineIndent,
      ArgumentList argumentList) {
    var children = <AstNode>[
      for (var arg in argumentList.arguments)
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

    var content = resolver.source.contents.data;

    if (children.length == 1) {
      final cb = reporter.createChangeBuilder(
        priority: 3,
        message: 'Remove this component',
      );

      cb.addDartFileEdit((builder) {
        builder.addReplacement(node.sourceRange, (editBuilder) {
          var child = children.first;
          var childIndent = getLineIndent(resolver.lineInfo, child);
          editBuilder
              .write(content.substring(child.offset, child.end).reIndent(lineIndent - childIndent, skipFirst: true));
        });
      });
    } else if (node.parent is ListLiteral) {
      final cb = reporter.createChangeBuilder(
        priority: 3,
        message: 'Remove this component',
      );

      cb.addDartFileEdit((builder) {
        builder.addReplacement(node.sourceRange, (editBuilder) {
          for (var child in children) {
            var childIndent = getLineIndent(resolver.lineInfo, child);
            var source = content.substring(child.offset, child.end).reIndent(lineIndent - childIndent, skipFirst: true);

            if (child != children.first) {
              editBuilder.write(''.padLeft(lineIndent));
            }
            editBuilder.write(source);
            if (child != children.last) {
              editBuilder.write(',\n');
            }
          }
        });
      });
    } else if (node.parent is YieldStatement) {
      final cb = reporter.createChangeBuilder(
        priority: 3,
        message: 'Remove this component',
      );

      cb.addDartFileEdit((builder) {
        builder.addReplacement(node.parent!.sourceRange, (editBuilder) {
          for (var child in children) {
            var childIndent = getLineIndent(resolver.lineInfo, child);
            var source = content.substring(child.offset, child.end).reIndent(lineIndent - childIndent, skipFirst: true);

            if (child != children.first) {
              editBuilder.write(''.padLeft(lineIndent));
            }
            editBuilder.write('yield $source;');
            if (child != children.last) {
              editBuilder.write('\n');
            }
          }
        });
      });
    }
  }
}
