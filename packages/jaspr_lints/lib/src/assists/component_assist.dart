import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
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
          builder.addSimpleInsertion(0, "import 'package:jaspr/jaspr.dart';\n");
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
          builder.importLibrary(Uri.parse('package:jaspr/jaspr.dart'));
        }
      });

      reporter.createChangeBuilder(priority: 3, message: 'Create InheritedComponent').addDartFileEdit((builder) {
        if (!hasJasprImport) {
          builder.importLibrary(Uri.parse('package:jaspr/jaspr.dart'));
        }

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
      });
    });

    context.registry.addClassDeclaration((node) {
      if (target.offset < node.offset || target.end > node.leftBracket.end) {
        return;
      }
      if (node.extendsClause?.superclass.name2.lexeme != 'StatelessComponent') {
        return;
      }

      MethodDeclaration? buildMethod;
      List<String> members = [];
      for (var m in node.members) {
        if (m is MethodDeclaration && m.name.lexeme == "build") {
          buildMethod = m;
        } else if (m is FieldDeclaration) {
          members.addAll(m.fields.variables.map((v) => v.name.lexeme));
        }
      }

      reporter.createChangeBuilder(priority: 1, message: 'Convert to StatefulComponent').addDartFileEdit((builder) {
        builder.addReplacement(node.extendsClause!.superclass.sourceRange, (edit) {
          edit.write('StatefulComponent');
        });

        var splitToken = buildMethod?.beginToken ?? node.rightBracket;
        var indent = buildMethod != null ? '' : '  ';
        var endIndent = buildMethod != null ? '  ' : '';
        var name = node.name.lexeme;

        builder.addInsertion(splitToken.offset, (edit) {
          edit.write("${indent}@override\n  State createState() => ${name}State();\n"
              "}\n\nclass ${name}State extends State<$name> {\n$endIndent");
        });

        buildMethod?.body.visitChildren(StateBuildVisitor(builder, node));
      });

      if (buildMethod != null && buildMethod.body.keyword != null) {
        reporter
            .createChangeBuilder(priority: 1, message: 'Convert to AsyncStatelessComponent')
            .addDartFileEdit((builder) {
          if (node.parent case CompilationUnit unit) {
            for (var dir in unit.directives) {
              if (dir is ImportDirective && dir.uri.stringValue == 'package:jaspr/jaspr.dart') {
                builder.addDeletion(dir.sourceRange);
              }
            }
          }

          builder.importLibrary(Uri.parse('package:jaspr/server.dart'));

          builder.addSimpleReplacement(node.extendsClause!.superclass.sourceRange, 'AsyncStatelessComponent');
          builder.addSimpleReplacement(buildMethod!.body.keyword!.sourceRange, 'async');
          if (buildMethod.returnType != null) {
            builder.addSimpleReplacement(buildMethod.returnType!.sourceRange, 'Stream<Component>');
          } else {
            builder.addSimpleInsertion(buildMethod.name.offset, 'Stream<Component> ');
          }
        });
      }
    });
  }
}

class StateBuildVisitor extends UnifyingAstVisitor {
  StateBuildVisitor(this.builder, this.clazz);

  final DartFileEditBuilder builder;
  final ClassDeclaration clazz;

  @override
  visitSimpleIdentifier(SimpleIdentifier node) {
    var elem = node.staticElement;
    if (elem == null) return;

    if (elem.enclosingElement == clazz.declaredElement) {
      builder.addSimpleInsertion(node.offset, 'component.');
    }
  }
}
