import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:io/ansi.dart';

import 'migration_models.dart';

class ComponentApplyMigration implements Migration {
  @override
  String get minimumJasprVersion => '0.24.0';

  @override
  String get name => 'component_apply_migration';
  
  @override
  String get description =>
      'Migrates `Component.wrapElement` to `Component.apply`.';

  @override
  String get hint {
    return '${styleItalic.wrap(red.wrap('    - return Component.wrapElement(...)'))!}\n'
        '${styleItalic.wrap(green.wrap('    + return Component.apply(...)'))!}';
  }

  @override
  void runForUnit(MigrationUnitContext context) {
    if (!context.unit.directives.any(
      (d) => d is ImportDirective && (d.uri.stringValue?.startsWith('package:jaspr/') ?? false),
    )) {
      // Only run if Jaspr is imported.
      return;
    }

    final wrapElements = <(SourceRange, String)>[];

    context.unit.accept(
      _ComponentApplyVisitor(
        onWrapElement: (node, replacement) {
          wrapElements.add((node, replacement));
        },
      ),
    );

    if (wrapElements.isNotEmpty) {
      context.reporter.createMigration('Replaced Component.wrapElement() with Component.apply()', (builder) {
        for (final (node, replacement) in wrapElements) {
          builder.replace(node.offset, node.length, replacement);
        }
      });
    }
  }

  @override
  List<MigrationResult> runForDirectory(MigrationContext context) {
    return [];
  }
}

class _ComponentApplyVisitor extends RecursiveAstVisitor<void> {
  _ComponentApplyVisitor({required this.onWrapElement});

  final void Function(SourceRange node, String replacement) onWrapElement;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'wrapElement' &&
        node.target is SimpleIdentifier &&
        (node.target as SimpleIdentifier).name == 'Component') {
      onWrapElement(SourceRange(node.target!.offset, node.methodName.end - node.target!.offset), 'Component.apply');
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitDotShorthandInvocation(DotShorthandInvocation node) {
    if (node.memberName.name == 'wrapElement') {
      onWrapElement(SourceRange(node.period.offset, node.memberName.end - node.period.offset), '.apply');
    }
    super.visitDotShorthandInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final constr = node.constructorName;
    if (constr.type.name.lexeme == 'Component' && constr.name?.name == 'wrapElement') {
      onWrapElement(SourceRange(constr.type.offset, constr.name!.end - constr.type.offset), 'Component.apply');
    }
    super.visitInstanceCreationExpression(node);
  }
}
