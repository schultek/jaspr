import 'dart:math';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:io/ansi.dart';

import 'migration_models.dart';

class BuildMethodMigration implements Migration {
  @override
  String get minimumJasprVersion => '0.21.0';

  @override
  String get name => 'build_method_migration';
  @override
  String get description => 'Migrates the build() to return a single child instead of using the sync* / yield syntax.';

  @override
  String get hint {
    return '${styleItalic.wrap(red.wrap('    - Iterable<Component> build(BuildContext context) sync* { yield ... }'))!}\n'
        '${styleItalic.wrap(green.wrap('    + Component build(BuildContext context) { return ... }'))!}';
  }

  bool _isBuildableClass(ClassDeclaration declaration) {
    final superName = declaration.extendsClause?.superclass.name.lexeme;
    return superName == 'StatelessComponent' || superName == 'AsyncStatelessComponent' || superName == 'State';
  }

  bool _isBuildMethod(MethodDeclaration method) {
    return method.name.lexeme == 'build' &&
        (method.returnType?.toSource() == 'Iterable<Component>' ||
            method.returnType?.toSource() == 'Stream<Component>');
  }

  @override
  void runForUnit(MigrationContext context) {
    for (final declaration in context.unit.declarations) {
      if (declaration is ClassDeclaration) {
        if (!_isBuildableClass(declaration)) {
          continue;
        }
        for (final member in declaration.members) {
          if (member is MethodDeclaration) {
            if (!_isBuildMethod(member)) {
              continue;
            }

            _migrateBuildMethod(member, declaration.name.lexeme, context.reporter);
          }
        }
      }
    }
  }

  void _migrateBuildMethod(MethodDeclaration node, String className, MigrationReporter reporter) {
    if (node.body.keyword == null) {
      reporter.reportManualMigrationNeeded(
        node.offset,
        node.length,
        'Cannot migrate $className.build(): Only build methods using sync* or async* can be migrated automatically',
      );
      return;
    }
    if (node.body is! BlockFunctionBody) {
      reporter.reportManualMigrationNeeded(
        node.offset,
        node.length,
        'Cannot migrate $className.build(): Only build methods with a block function body can be migrated automatically',
      );
      return;
    }

    final firstReturningStatement = (node.body as BlockFunctionBody).block.statements.indexWhere(_isReturningStatement);
    if (firstReturningStatement == -1) {
      reporter.reportManualMigrationNeeded(
        node.offset,
        node.length,
        'Cannot migrate $className.build(): No "yield" statement found, please migrate manually',
      );
      return;
    }

    reporter.createMigration('Migrated build() method of $className class', (builder) {
      if (node.returnType case final returnType?) {
        if (returnType.toSource() == 'Iterable<Component>') {
          builder.replace(returnType.offset, returnType.length, 'Component');
        } else if (returnType.toSource() == 'Stream<Component>') {
          builder.replace(returnType.offset, returnType.length, 'Future<Component>');
        }
      }

      _migrateFunctionBody(node.body, builder);
    });
  }

  void _migrateFunctionBody(FunctionBody node, MigrationBuilder builder) {
    final keyword = node.keyword;
    if (keyword == null || node is! BlockFunctionBody) {
      return;
    }

    final firstReturningStatement = node.block.statements.indexWhere(_isReturningStatement);
    if (firstReturningStatement == -1) {
      return;
    }

    final toMigrate = node.block.statements.sublist(firstReturningStatement);

    if (keyword.lexeme == 'sync') {
      builder.delete(keyword.offset, keyword.length);
    }

    if (node.star != null) {
      final end = node.star!.next?.offset ?? node.star!.end;
      builder.delete(node.star!.offset, end - node.star!.offset);
    }

    if (toMigrate.every(_canMigrateDeclaratively)) {
      int getChildCount(Statement s) {
        if (s is YieldStatement) return s.star == null ? 1 : 2;
        if (s is Block) {
          return s.statements.fold(0, (count, child) => count + getChildCount(child));
        }
        if (s is ForStatement) return 2;
        if (s is IfStatement) {
          var count = getChildCount(s.thenStatement);
          if (s.elseStatement != null) {
            count = max(count, getChildCount(s.elseStatement!));
          }
          return count;
        }
        return 0;
      }

      if (toMigrate.fold(0, (count, child) => count + getChildCount(child)) == 1) {
        void replaceYieldWithReturn(Statement s) {
          if (s is YieldStatement) {
            builder.replace(s.yieldKeyword.offset, s.yieldKeyword.length, 'return');
          } else if (s is Block) {
            for (var child in s.statements) {
              replaceYieldWithReturn(child);
            }
          } else if (s is ForStatement) {
            replaceYieldWithReturn(s.body);
          } else if (s is IfStatement) {
            replaceYieldWithReturn(s.thenStatement);
            if (s.elseStatement != null) {
              replaceYieldWithReturn(s.elseStatement!);
            }
          }
        }

        toMigrate.forEach(replaceYieldWithReturn);
      } else {
        builder.insert(toMigrate.first.offset, 'return Component.fragment([\n      ');
        builder.indent(toMigrate.first.offset, toMigrate.last.end - toMigrate.first.offset, '  ');

        void replaceStatementWithElement(Statement s, [bool addComma = true]) {
          if (s is YieldStatement) {
            final end = s.yieldKeyword.next?.offset ?? s.yieldKeyword.end;
            builder.delete(s.yieldKeyword.offset, end - s.yieldKeyword.offset);
            if (s.star != null) {
              final starEnd = s.star!.next?.offset ?? s.star!.end;
              builder.replace(s.star!.offset, starEnd - s.star!.offset, '...');
            }
            if (addComma) {
              builder.replace(s.semicolon.offset, s.semicolon.length, ',');
            } else {
              builder.delete(s.semicolon.offset, s.semicolon.length);
            }
          } else if (s is Block) {
            if (s.statements.length == 1) {
              builder.delete(s.leftBracket.offset, s.leftBracket.length);
              replaceStatementWithElement(s.statements.first, addComma);
              builder.delete(s.rightBracket.offset, s.rightBracket.length);
              return;
            }
            builder.replace(s.leftBracket.offset, s.leftBracket.length, '...[');
            for (var child in s.statements) {
              replaceStatementWithElement(child, true);
            }
            builder.replace(s.rightBracket.offset, s.rightBracket.length, ']${addComma ? ',' : ''}');
          } else if (s is ForStatement) {
            replaceStatementWithElement(s.body, addComma);
          } else if (s is IfStatement) {
            replaceStatementWithElement(s.thenStatement, s.elseStatement == null);
            if (s.elseStatement != null) {
              replaceStatementWithElement(s.elseStatement!, addComma);
            }
          }
        }

        toMigrate.forEach(replaceStatementWithElement);
        builder.insert(toMigrate.last.end, '\n    ]);');
      }
    } else {
      final inset = builder.getLineIndent(toMigrate.first);
      builder.insert(toMigrate.first.offset, 'final children = <Component>[];\n${''.padLeft(inset)}');

      void replaceYieldAndReturnWithChildren(Statement s) {
        if (s is YieldStatement) {
          final start = s.yieldKeyword.offset;
          if (s.star != null) {
            final end = s.star!.next?.offset ?? s.star!.end;
            builder.replace(start, end - start, 'children.addAll(');
          } else {
            final end = s.yieldKeyword.next?.offset ?? s.yieldKeyword.end;
            builder.replace(start, end - start, 'children.add(');
          }
          builder.insert(s.semicolon.offset, ')');
        } else if (s is ReturnStatement) {
          builder.insert(s.semicolon.offset, ' Component.fragment(children)');
        } else if (s is Block) {
          for (var child in s.statements) {
            replaceYieldAndReturnWithChildren(child);
          }
        } else if (s is ForStatement) {
          replaceYieldAndReturnWithChildren(s.body);
        } else if (s is IfStatement) {
          replaceYieldAndReturnWithChildren(s.thenStatement);
          if (s.elseStatement != null) {
            replaceYieldAndReturnWithChildren(s.elseStatement!);
          }
        }
      }

      toMigrate.forEach(replaceYieldAndReturnWithChildren);

      if (toMigrate.last is! ReturnStatement) {
        final inset = builder.getLineIndent(toMigrate.last);
        builder.insert(toMigrate.last.end, '\n${''.padLeft(inset)}return Component.fragment(children);');
      }
    }

    node.visitChildren(
      BuilderVisitor(
        onBuilderFunction: (node) {
          _migrateFunctionBody(node, builder);
        },
        onSingleBuilder: (node) {
          builder.delete(node.operator!.offset, node.operator!.length + node.methodName.length);
        },
      ),
    );
  }

  bool _isReturningStatement(Statement s) {
    if (s is YieldStatement) return true;
    if (s is ReturnStatement) return true;
    if (s is Block) return s.statements.any(_isReturningStatement);
    if (s is ForStatement) return _isReturningStatement(s.body);
    if (s is IfStatement) {
      if (_isReturningStatement(s.thenStatement)) return true;
      if (s.elseStatement != null && _isReturningStatement(s.elseStatement!)) {
        return true;
      }
    }
    return false;
  }

  bool _canMigrateDeclaratively(Statement s) {
    return s is YieldStatement ||
        (s is Block && s.statements.every(_canMigrateDeclaratively)) ||
        (s is ForStatement && _canMigrateDeclaratively(s.body)) ||
        (s is IfStatement &&
            _canMigrateDeclaratively(s.thenStatement) &&
            (s.elseStatement == null || _canMigrateDeclaratively(s.elseStatement!)));
  }
}

class BuilderVisitor extends RecursiveAstVisitor<void> {
  BuilderVisitor({required this.onBuilderFunction, required this.onSingleBuilder});

  final void Function(FunctionBody) onBuilderFunction;
  final void Function(MethodInvocation) onSingleBuilder;

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    if (node.parent case FunctionExpression(
      parent: NamedExpression(
        name: Label(label: SimpleIdentifier(name: 'builder')),
        parent: ArgumentList(
          parent: MethodInvocation(
            methodName: SimpleIdentifier(
              name: 'Builder' ||
                  'StatefulBuilder' ||
                  'AsyncBuilder' ||
                  'ListenableBuilder' ||
                  'StreamBuilder' ||
                  'FutureBuilder',
            ),
          ),
        ),
      ),
    )) {
      onBuilderFunction(node);
      return;
    }

    if (node.parent case FunctionExpression(
      parent: NamedExpression(
        name: Label(label: SimpleIdentifier(name: 'builder')),
        parent: ArgumentList(parent: MethodInvocation m),
      ),
    )) {
      if (m case MethodInvocation(
        methodName: SimpleIdentifier(name: 'single'),
        target: SimpleIdentifier(name: 'Builder'),
      )) {
        onSingleBuilder(m);
        return;
      }
    }

    super.visitBlockFunctionBody(node);
  }
}
