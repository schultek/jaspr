import 'dart:math';

import 'package:analyzer/dart/ast/ast.dart';

import '../commands/migrate_command.dart';

class BuildMethodMigration implements Migration {
  bool _isBuildableClass(ClassDeclaration declaration) {
    final superName = declaration.extendsClause?.superclass.name.lexeme;
    return superName == 'StatelessComponent' || superName == 'AsyncStatelessComponents' || superName == 'State';
  }

  bool _isBuildMethod(MethodDeclaration method) {
    return method.name.lexeme == 'build';
  }

  @override
  void runForUnit(CompilationUnit unit, MigrationBuilder builder) {
    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        if (!_isBuildableClass(declaration)) {
          continue;
        }
        for (final member in declaration.members) {
          if (member is MethodDeclaration) {
            if (!_isBuildMethod(member)) {
              continue;
            }

            _migrateBuildMethod(member, builder);
          }
        }
      }
    }
  }

  void _migrateBuildMethod(MethodDeclaration node, MigrationBuilder builder) {
    if (node.body.keyword == null || node.body is! BlockFunctionBody) {
      return;
    }

    final keyword = node.body.keyword!;
    final body = node.body as BlockFunctionBody;

    bool isReturningStatement(Statement s) {
      if (s is YieldStatement) return true;
      if (s is ReturnStatement) return true;
      if (s is Block) return s.statements.any(isReturningStatement);
      if (s is ForStatement) return isReturningStatement(s.body);
      if (s is IfStatement) {
        if (isReturningStatement(s.thenStatement)) return true;
        if (s.elseStatement != null && isReturningStatement(s.elseStatement!)) return true;
      }
      return false;
    }

    final firstReturningStatement = body.block.statements.indexWhere(isReturningStatement);
    if (firstReturningStatement == -1) {
      return;
    }

    final toMigrate = body.block.statements.sublist(firstReturningStatement);

    bool canMigrate(Statement s) {
      return s is YieldStatement ||
          (s is Block && s.statements.every(canMigrate)) ||
          (s is ForStatement && canMigrate(s.body)) ||
          (s is IfStatement &&
              canMigrate(s.thenStatement) &&
              (s.elseStatement == null || canMigrate(s.elseStatement!)));
    }

    if (!toMigrate.every(canMigrate)) {
      return;
    }

    if (node.returnType case final returnType?) {
      if (returnType.toSource() == 'Iterable<Component>') {
        builder.replace(returnType.offset, returnType.length, 'Component');
      } else if (returnType.toSource() == 'Stream<Component>') {
        builder.replace(returnType.offset, returnType.length, 'Future<Component>');
      }
    }

    if (keyword.lexeme == 'sync') {
      builder.delete(keyword.offset, keyword.length);
    }

    if (body.star != null) {
      final end = body.star!.next?.offset ?? body.star!.end;
      builder.delete(body.star!.offset, end - body.star!.offset);
    }

    int getChildCount(Statement s) {
      if (s is YieldStatement) return s.star == null ? 1 : 2;
      if (s is Block) return s.statements.fold(0, (count, child) => count + getChildCount(child));
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
      builder.insert(toMigrate.first.offset, 'return Fragment(children: [\n      ');
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
          builder.delete(s.leftBracket.offset, s.leftBracket.length);
          for (var child in s.statements) {
            replaceStatementWithElement(child, addComma ? true : child != s.statements.last);
          }
          builder.delete(s.rightBracket.offset, s.rightBracket.length);
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
  }
}
