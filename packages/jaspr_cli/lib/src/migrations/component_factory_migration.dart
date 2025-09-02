import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:io/ansi.dart';

import 'migration_models.dart';

class ComponentFactoryMigration implements Migration {
  @override
  String get minimumJasprVersion => '0.21.0';

  @override
  String get name => 'component_factory_migration';
  @override
  String get description =>
      'Migrates `Text`, `DomComponent` and `Fragment` to `Component.text`, `Component.element`, `Component.fragment` respectively.';

  @override
  String get hint {
    return '${styleItalic.wrap(red.wrap('    - return DomComponent(tag: ...)'))!}\n'
        '${styleItalic.wrap(green.wrap('    + return Component.element(tag: ...)'))!}';
  }

  @override
  void runForUnit(CompilationUnit unit, MigrationReporter reporter) {
    final texts = <SourceRange>[];
    final domComponents = <SourceRange>[];
    final fragments = <(SourceRange, ArgumentList)>[];
    final wrapDomComponents = <SourceRange>[];

    if (!unit.directives
        .any((d) => d is ImportDirective && (d.uri.stringValue?.startsWith('package:jaspr/') ?? false))) {
      // Only run if jaspr is imported.
      return;
    }

    unit.accept(ComponentVisitor(onText: (node) {
      texts.add(node);
    }, onDomComponent: (node) {
      domComponents.add(node);
    }, onWrapDomComponent: (node) {
      wrapDomComponents.add(node);
    }, onFragment: (node, arguments) {
      fragments.add((node, arguments));
    }));

    if (texts.isNotEmpty) {
      reporter.createMigration('Replaced Text() with Component.text()', (builder) {
        for (final node in texts) {
          builder.replace(node.offset, node.length, 'Component.text');
        }
      });
    }

    if (domComponents.isNotEmpty) {
      reporter.createMigration('Replaced DomComponent() with Component.element()', (builder) {
        for (final node in domComponents) {
          builder.replace(node.offset, node.length, 'Component.element');
        }
      });
    }

    if (wrapDomComponents.isNotEmpty) {
      reporter.createMigration('Replaced DomComponent.wrap() with Component.wrapElement()', (builder) {
        for (final node in wrapDomComponents) {
          builder.replace(node.offset, node.length, 'Component.wrapElement');
        }
      });
    }

    if (fragments.isNotEmpty) {
      reporter.createMigration('Replaced Fragment() with Component.fragment()', (builder) {
        for (final (node, arguments) in fragments) {
          builder.replace(node.offset, node.length, 'Component.fragment');
          final childrenArg = arguments.arguments
              .where((arg) => arg is NamedExpression && arg.name.label.name == 'children')
              .firstOrNull as NamedExpression?;
          if (childrenArg != null) {
            final end = childrenArg.expression.offset;
            builder.delete(childrenArg.name.offset, end - childrenArg.name.offset);
          }
        }
      });
    }
  }
}

class ComponentVisitor extends RecursiveAstVisitor<void> {
  ComponentVisitor({
    required this.onText,
    required this.onDomComponent,
    required this.onWrapDomComponent,
    required this.onFragment,
  });

  final void Function(SourceRange node) onText;
  final void Function(SourceRange node) onDomComponent;
  final void Function(SourceRange node) onWrapDomComponent;
  final void Function(SourceRange node, ArgumentList arguments) onFragment;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'Text' && node.target == null) {
      onText(SourceRange(node.methodName.offset, node.methodName.length));
    } else if (node.methodName.name == 'Fragment' && node.target == null) {
      onFragment(SourceRange(node.methodName.offset, node.methodName.length), node.argumentList);
    } else if (node.methodName.name == 'DomComponent' && node.target == null) {
      onDomComponent(SourceRange(node.methodName.offset, node.methodName.length));
    } else if (node.methodName.name == 'wrap' &&
        node.target is SimpleIdentifier &&
        (node.target as SimpleIdentifier).name == 'DomComponent') {
      onWrapDomComponent(SourceRange(node.target!.offset, node.methodName.end - node.target!.offset));
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final constr = node.constructorName;
    if (constr.type.name2.lexeme == 'Text' && constr.name == null) {
      onText(SourceRange(constr.type.offset, constr.type.length));
    } else if (constr.type.name2.lexeme == 'Fragment' && constr.name == null) {
      onFragment(SourceRange(constr.type.offset, constr.type.length), node.argumentList);
    } else if (constr.type.name2.lexeme == 'DomComponent' && constr.name == null) {
      onDomComponent(SourceRange(constr.type.offset, constr.type.length));
    } else if (constr.type.name2.lexeme == 'DomComponent' && constr.name?.name == 'wrap') {
      onWrapDomComponent(SourceRange(constr.type.offset, constr.name!.end - constr.type.offset));
    }
    super.visitInstanceCreationExpression(node);
  }
}
