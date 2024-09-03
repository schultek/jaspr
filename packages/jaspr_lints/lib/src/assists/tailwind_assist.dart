import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class TailwindAssistProvider extends DartAssist {
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
    });
  }
}
