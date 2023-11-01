import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

final funcs = ['p', 'text', 'div', 'img', 'small'];

PluginBase createPlugin() => _JasprLinter();

class _JasprLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [];

  @override
  List<Assist> getAssists() => [_JasprFunctionAssistProvider()];
}

class _JasprFunctionAssistProvider extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addMethodInvocation((node) {
      final method = node.methodName.toString();

      if (target.length != 0) return;
      if (target.offset < node.offset) return;
      if (target.offset > node.offset + method.length) return;

      if (method == 'tw') {
        // Do Tailwind formatting
        final cb = reporter.createChangeBuilder(
          priority: 1,
          message: 'Sort Tailwind classes',
        );

        cb.addDartFileEdit((builder) {});
      }

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
      builder.addReplacement(node.sourceRange, (editBuilder) {
        editBuilder.write(
          'div([${node.toSource()}])',
        );
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

    final newSource = children.childEntities
        .toList()
        .sublist(1, children.childEntities.length - 1)
        .join(',');

    cb.addDartFileEdit((builder) {
      builder.addReplacement(node.sourceRange, (editBuilder) {
        editBuilder.write(newSource);
      });
    });
  }
}
