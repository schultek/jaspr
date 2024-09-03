import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

final funcs = ['p', 'text', 'div', 'img', 'small'];

class TreeAssistProvider extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addMethodInvocation((node) {
      final method = node.methodName.toString();

      if (funcs.contains(method)) {
        _wrapWithComponent(reporter, node);
        _removeComponent(reporter, node);
      }
    });
  }

  void _wrapWithComponent(ChangeReporter reporter, MethodInvocation node) {
    final cb = reporter.createChangeBuilder(
      priority: 1,
      message: 'Wrap with Component',
    );

    cb.addDartFileEdit((builder) {
      builder.addInsertion(node.offset, (editBuilder) {
        editBuilder.write('div([\n');
      });
      builder.addInsertion(node.offset + node.length, (editBuilder) {
        editBuilder.write('\n])');
      });
    });
  }

  void _removeComponent(ChangeReporter reporter, MethodInvocation node) {
    final cb = reporter.createChangeBuilder(
      priority: 1,
      message: 'Remove Component',
    );
    ListLiteral? children;
    for (final a in node.argumentList.arguments) {
      if (a is ListLiteral) {
        children = a;
        break;
      }
    }

    if (children == null) return;

    final newSource = children.childEntities.toList().sublist(1, children.childEntities.length - 1).join(',');

    cb.addDartFileEdit((builder) {
      builder.addReplacement(node.sourceRange, (editBuilder) {
        editBuilder.write(newSource);
      });
    });
  }
}
