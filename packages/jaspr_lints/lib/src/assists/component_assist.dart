import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../assist.dart';
import '../utils.dart';

abstract class CreateComponentAssist extends ResolvedCorrectionProducer {
  CreateComponentAssist({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case CompilationUnit node) {
      var hasJasprImport = false;

      for (var dir in node.directives) {
        if (dir.end > selectionOffset) {
          return;
        }
        if (dir is ImportDirective && (dir.uri.stringValue?.startsWith('package:jaspr/') ?? false)) {
          hasJasprImport = true;
        }
      }

      for (var dec in node.declarations) {
        if (selectionOffset >= dec.offset && selectionEnd <= dec.end) {
          return;
        }
      }

      var nameSuggestion = file.split('/').last;
      if (nameSuggestion.endsWith('.dart')) nameSuggestion = nameSuggestion.substring(0, nameSuggestion.length - 5);

      nameSuggestion = nameSuggestion.split('_').map((s) => s.substring(0, 1).toUpperCase() + s.substring(1)).join();

      createComponent(builder, nameSuggestion, hasJasprImport);
    }
  }

  void createComponent(ChangeBuilder builder, String nameSuggestion, bool hasJasprImport);
}

class CreateStatelessComponent extends CreateComponentAssist {
  CreateStatelessComponent({required super.context});

  @override
  AssistKind get assistKind => JasprAssistKind.createStatelessComponent;

  @override
  void createComponent(ChangeBuilder builder, String nameSuggestion, bool hasJasprImport) {
    builder.addDartFileEdit(file, (builder) {
      builder.addInsertion(selectionEnd == 0 ? 1 : selectionEnd, (edit) {
        edit.write('class ');
        edit.addSimpleLinkedEdit('name', nameSuggestion);
        edit.write(
          ' extends StatelessComponent {\n'
          '  const ',
        );

        edit.addSimpleLinkedEdit('name', nameSuggestion);
        edit.write(
          '({super.key});\n\n  @override\n  Component build(BuildContext context) {\n'
          '    return ',
        );
        edit.addSimpleLinkedEdit('child', "div([])");
        edit.write(';\n  }\n}\n');
      });
      if (!hasJasprImport) {
        builder.addSimpleInsertion(0, "import 'package:jaspr/jaspr.dart';\n");
      }
    });
  }
}

class CreateStatefulComponent extends CreateComponentAssist {
  CreateStatefulComponent({required super.context});

  @override
  AssistKind get assistKind => JasprAssistKind.createStatefulComponent;

  @override
  void createComponent(ChangeBuilder builder, String nameSuggestion, bool hasJasprImport) {
    builder.addDartFileEdit(file, (builder) {
      builder.addInsertion(selectionEnd == 0 ? 1 : selectionEnd, (edit) {
        edit.write('class ');
        edit.addSimpleLinkedEdit('name', nameSuggestion);
        edit.write(
          ' extends StatefulComponent {\n'
          '  const ',
        );

        edit.addSimpleLinkedEdit('name', nameSuggestion);
        edit.write('({super.key});\n\n  @override\n  State createState() => ');
        edit.addSimpleLinkedEdit('name', nameSuggestion);
        edit.write('State();\n}\n\nclass ');
        edit.addSimpleLinkedEdit('name', nameSuggestion);
        edit.write('State extends State<');
        edit.addSimpleLinkedEdit('name', nameSuggestion);
        edit.write(
          '> {\n\n  @override\n  Component build(BuildContext context) {\n'
          '    return ',
        );
        edit.addSimpleLinkedEdit('child', "div([])");
        edit.write(';\n  }\n}\n');
      });
      if (!hasJasprImport) {
        builder.importLibrary(Uri.parse('package:jaspr/jaspr.dart'));
      }
    });
  }
}

class CreateInheritedComponent extends CreateComponentAssist {
  CreateInheritedComponent({required super.context});

  @override
  AssistKind get assistKind => JasprAssistKind.createInheritedComponent;

  @override
  void createComponent(ChangeBuilder builder, String nameSuggestion, bool hasJasprImport) {
    builder.addDartFileEdit(file, (builder) {
      builder.addInsertion(selectionEnd == 0 ? 1 : selectionEnd, (edit) {
        edit.write('class ');
        edit.addSimpleLinkedEdit('name', nameSuggestion);
        edit.write(
          ' extends InheritedComponent {\n'
          '  const ',
        );

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
          ' found in context.\');\n    return result!;\n  }\n\n  @override\n  bool updateShouldNotify(covariant ',
        );

        edit.addSimpleLinkedEdit('name', nameSuggestion);
        edit.write(' oldComponent) {\n    return false;\n  }\n}\n');
      });
      if (!hasJasprImport) {
        builder.importLibrary(Uri.parse('package:jaspr/jaspr.dart'));
      }
    });
  }
}

abstract class ConvertComponentAssist extends ResolvedCorrectionProducer {
  ConvertComponentAssist({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node
        case final ClassDeclaration node ||
            ExtendsClause(parent: final ClassDeclaration node) ||
            NamedType(parent: ExtendsClause(parent: final ClassDeclaration node))) {
      if (node.extendsClause?.superclass.name.lexeme != 'StatelessComponent') {
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

      await convertComponent(builder, node, buildMethod);
    }
  }

  Future<void> convertComponent(ChangeBuilder builder, ClassDeclaration node, MethodDeclaration? buildMethod);
}

class ConvertToStatefulComponent extends ConvertComponentAssist {
  ConvertToStatefulComponent({required super.context});

  @override
  AssistKind get assistKind => JasprAssistKind.convertToStatefulComponent;

  @override
  Future<void> convertComponent(ChangeBuilder builder, ClassDeclaration node, MethodDeclaration? buildMethod) async {
    await builder.addDartFileEdit(file, (builder) {
      builder.addReplacement(node.extendsClause!.superclass.sourceRange, (edit) {
        edit.write('StatefulComponent');
      });

      var splitToken = buildMethod?.beginToken ?? node.rightBracket;
      var indent = buildMethod != null ? '' : '  ';
      var endIndent = buildMethod != null ? '  ' : '';
      var name = node.name.lexeme;

      builder.addInsertion(splitToken.offset, (edit) {
        edit.write(
          "$indent@override\n  State createState() => ${name}State();\n"
          "}\n\nclass ${name}State extends State<$name> {\n$endIndent",
        );
      });

      buildMethod?.body.visitChildren(
        StateBuildVisitor(node, builder),
      );
    });
  }
}

class ConvertToAsyncStatelessComponent extends ConvertComponentAssist {
  ConvertToAsyncStatelessComponent({required super.context});

  @override
  AssistKind get assistKind => JasprAssistKind.convertToAsyncStatelessComponent;

  @override
  Future<void> convertComponent(ChangeBuilder builder, ClassDeclaration node, MethodDeclaration? buildMethod) async {
    await builder.addDartFileEdit(file, (builder) {
      if (node.parent case CompilationUnit unit) {
        for (var dir in unit.directives) {
          if (dir is ImportDirective && dir.uri.stringValue == 'package:jaspr/jaspr.dart') {
            builder.addDeletion(dir.sourceRange);
          }
        }
      }

      builder.importLibrary(Uri.parse('package:jaspr/server.dart'));

      builder.addSimpleReplacement(node.extendsClause!.superclass.sourceRange, 'AsyncStatelessComponent');

      if (buildMethod != null) {
        if (buildMethod.body.keyword case final keyword?) {
          builder.addSimpleReplacement(keyword.sourceRange, 'async');
        } else {
          builder.addSimpleInsertion(buildMethod.body.offset, 'async ');
        }
        if (buildMethod.returnType != null) {
          builder.addSimpleReplacement(buildMethod.returnType!.sourceRange, 'Future<Component>');
        } else {
          builder.addSimpleInsertion(buildMethod.name.offset, 'Future<Component> ');
        }
      }
    });
  }
}

class StateBuildVisitor extends UnifyingAstVisitor<void> {
  StateBuildVisitor(this.clazz, this.builder);

  final ClassDeclaration clazz;
  final DartFileEditBuilder builder;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    var elem = node.element;
    if (elem == null) return;

    if (elem.enclosingElement == clazz.declaredFragment?.element) {
      builder.addSimpleInsertion(node.offset, 'component.');
    }
  }
}
