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
      extractComponent(resolver, reporter, node, indent);
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
      extractComponent(resolver, reporter, node, indent);
    });
  }

  void wrapComponent(CustomLintResolver resolver, ChangeReporter reporter, Expression node, int lineIndent) {
    var content = resolver.source.contents.data;
    var lines = content.substring(node.offset, node.end).split('\n');

    var htmlSource =
        '([\n${''.padLeft(lineIndent)}${lines.map((s) => '  $s').join('\n')},\n${''.padLeft(lineIndent)}])';

    void wrapWith(String name, [List<String>? suggestions]) {
      final cb = reporter.createChangeBuilder(
        priority: 2,
        message: 'Wrap with $name',
      );

      cb.addDartFileEdit((builder) {
        builder.addReplacement(node.sourceRange, (edit) {
          if (suggestions != null) {
            edit.addSimpleLinkedEdit(name, suggestions.first,
                kind: LinkedEditSuggestionKind.METHOD, suggestions: suggestions);
          } else {
            edit.write(name);
          }
          edit.write(htmlSource);
        });
      });
    }

    wrapWith('html...', ['div', 'section', 'ul', 'li', 'h1', 'p', 'span', 'button']);
    wrapWith('div');
    wrapWith('section');
    wrapWith('ul');
    wrapWith('li');

    final cb = reporter.createChangeBuilder(
      priority: 2,
      message: 'Wrap with component...',
    );

    cb.addDartFileEdit((builder) {
      builder.addReplacement(node.sourceRange, (edit) {
        edit.addSimpleLinkedEdit('comp', 'component');
        edit.write('(\n');
        edit.write(''.padLeft(lineIndent, ' '));
        edit.write('  child: ');
        edit.writeln(lines[0]);
        edit.write(lines.skip(1).map((s) => '  $s').join('\n'));
        edit.write(',\n${''.padLeft(lineIndent, ' ')})');
      });
    });

    final cb2 = reporter.createChangeBuilder(
      priority: 2,
      message: 'Wrap with Builder',
    );

    cb2.addDartFileEdit((builder) {
      builder.addReplacement(node.sourceRange, (edit) {
        edit.write('Builder(builder: (context) sync* {\n');
        edit.write(''.padLeft(lineIndent, ' '));
        edit.write('  yield ');
        edit.write(lines[0]);
        edit.write(lines.skip(1).map((s) => '\n  $s').join());
        edit.write(';\n${''.padLeft(lineIndent, ' ')}})');
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
        builder.addReplacement(node.sourceRange, (edit) {
          var child = children.first;
          var childIndent = getLineIndent(resolver.lineInfo, child);
          edit.write(content.substring(child.offset, child.end).reIndent(lineIndent - childIndent, skipFirst: true));
        });
      });
    } else if (node.parent is ListLiteral) {
      final cb = reporter.createChangeBuilder(
        priority: 3,
        message: 'Remove this component',
      );

      cb.addDartFileEdit((builder) {
        builder.addReplacement(node.sourceRange, (edit) {
          for (var child in children) {
            var childIndent = getLineIndent(resolver.lineInfo, child);
            var source = content.substring(child.offset, child.end).reIndent(lineIndent - childIndent, skipFirst: true);

            if (child != children.first) {
              edit.write(''.padLeft(lineIndent));
            }
            edit.write(source);
            if (child != children.last) {
              edit.write(',\n');
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
        builder.addReplacement(node.parent!.sourceRange, (edit) {
          for (var child in children) {
            var childIndent = getLineIndent(resolver.lineInfo, child);
            var source = content.substring(child.offset, child.end).reIndent(lineIndent - childIndent, skipFirst: true);

            if (child != children.first) {
              edit.write(''.padLeft(lineIndent));
            }
            edit.write('yield $source;');
            if (child != children.last) {
              edit.write('\n');
            }
          }
        });
      });
    }
  }

  void extractComponent(CustomLintResolver resolver, ChangeReporter reporter, Expression node, int lineIndent) {
    var content = resolver.source.contents.data;
    var source = content.substring(node.offset, node.end).reIndent(4 - lineIndent, skipFirst: true);

    final cb = reporter.createChangeBuilder(
      priority: 4,
      message: 'Extract component',
    );

    cb.addDartFileEdit((builder) {
      builder.addInsertion(resolver.source.contents.data.length, (edit) {
        edit.write('\nclass ');
        edit.addSimpleLinkedEdit('name', 'MyComponent');
        edit.write(' extends StatelessComponent {\n'
            '  const ');
        edit.addSimpleLinkedEdit('name', 'MyComponent');
        edit.write('();\n'
            '\n'
            '  @override\n'
            '  Iterable<Component> build(BuildContext context) sync* {\n'
            '    yield ');
        edit.write(source);
        edit.write(';\n'
            '  }\n}\n');
      });

      builder.addReplacement(node.sourceRange, (edit) {
        edit.addSimpleLinkedEdit('name', 'MyComponent');
        edit.write('()');
      });
    });
  }
}
