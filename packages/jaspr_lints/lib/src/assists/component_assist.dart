import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class ComponentAssistProvider extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addCompilationUnit((node) {
      var hasJasprImport = false;

      for (var dir in node.directives) {
        if (dir.offset > target.end) {
          return;
        }
        if (dir is ImportDirective && (dir.uri.stringValue?.startsWith('package:jaspr/') ?? false)) {
          hasJasprImport = true;
        }
      }

      for (var dec in node.declarations) {
        if (target.offset >= dec.offset && target.end <= dec.end) {
          return;
        }
      }

      var nameSuggestion = resolver.path.split('/').last;
      if (nameSuggestion.endsWith('.dart')) nameSuggestion = nameSuggestion.substring(0, nameSuggestion.length - 5);

      nameSuggestion = nameSuggestion.split('_').map((s) => s.substring(0, 1).toUpperCase() + s.substring(1)).join();

      reporter.createChangeBuilder(priority: 1, message: 'Create StatelessComponent').addDartFileEdit((builder) {
        builder.addInsertion(target.end == 0 ? 1 : target.end, (edit) {
          edit.write('class ');
          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write(' extends StatelessComponent {\n'
              '  const ');

          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write('({super.key});\n\n  @override\n  Iterable<Component> build(BuildContext context) sync* {\n'
              '    yield ');
          edit.addSimpleLinkedEdit('child', "div([])");
          edit.write(';\n  }\n}\n');
        });

        if (!hasJasprImport) {
          builder.addInsertion(node.directives.lastOrNull?.end ?? 0, (edit) {
            edit.write("\nimport 'package:jaspr/jaspr.dart';");
          });
        }
      });

      reporter.createChangeBuilder(priority: 2, message: 'Create StatefulComponent').addDartFileEdit((builder) {
        builder.addInsertion(target.end == 0 ? 1 : target.end, (edit) {
          edit.write('class ');
          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write(' extends StatefulComponent {\n'
              '  const ');

          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write('({super.key});\n\n  @override\n  State createState() => ');
          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write('State();\n}\n\nclass ');
          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write('State extends State<');
          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write('> {\n\n  @override\n  Iterable<Component> build(BuildContext context) sync* {\n'
              '    yield ');
          edit.addSimpleLinkedEdit('child', "div([])");
          edit.write(';\n  }\n}\n');
        });

        if (!hasJasprImport) {
          builder.addInsertion(node.directives.lastOrNull?.end ?? 0, (edit) {
            edit.write("\nimport 'package:jaspr/jaspr.dart';");
          });
        }
      });

      reporter.createChangeBuilder(priority: 3, message: 'Create InheritedComponent').addDartFileEdit((builder) {
        builder.addInsertion(target.end == 0 ? 1 : target.end, (edit) {
          edit.write('class ');
          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write(' extends InheritedComponent {\n'
              '  const ');

          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write('({super.child, super.children, super.key});\n\n  static ');
          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write(' of(BuildContext context) {\n    final ');
          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write('? result = context.dependOnInheritedComponentOfExactType<');
          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write('>();\n    assert(result != null, \'No ');
          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write(
              ' found in context.\');\n    return result!;\n  }\n\n  @override\n  bool updateShouldNotify(covariant ');

          edit.addSimpleLinkedEdit('name', nameSuggestion);
          edit.write(' oldComponent) {\n    return false;\n  }\n}\n');
        });

        if (!hasJasprImport) {
          builder.addInsertion(node.directives.lastOrNull?.end ?? 0, (edit) {
            edit.write("\nimport 'package:jaspr/jaspr.dart';");
          });
        }
      });
    });
  }
}
