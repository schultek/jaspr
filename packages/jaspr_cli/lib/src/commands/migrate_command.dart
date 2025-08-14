import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:vm_service/vm_service.dart';

import '../logging.dart';
import '../migrations/build_method_migration.dart';
import 'base_command.dart';

class MigrateCommand extends BaseCommand {
  MigrateCommand({super.logger}) {
    argParser.addFlag(
      'dry-run',
      help: 'Preview the proposed changes but make no changes.',
      defaultsTo: false,
    );
  }

  @override
  String get description => 'Migrate Jaspr code to the latest version.';

  @override
  String get name => 'migrate';

  @override
  String get category => 'Tooling';

  late final bool dryRun = argResults!['dry-run'] as bool;

  @override
  Future<int> runCommand() async {
    final directories = ['lib', 'web', 'test'];
    final migrations = <Migration>[
      BuildMethodMigration(),
    ];

    

    for (final path in directories) {
      final dir = Directory(path);
      if (!dir.existsSync()) {
        continue;
      }

      final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
      for (final file in files) {
        final content = file.readAsStringSync();
        try {
        final result = parseString(content: content);

        final builder = MigrationBuilder(result.lineInfo);

        for (final migration in migrations) {
          migration.runForUnit(result.unit, builder);
        }

        if (builder._changes.isEmpty) {
          continue;
        }

        if (dryRun) {
          logger.write('${file.path}: ${builder._changes.length} changes');
        } else {
          final result = builder._apply(content);
          file.writeAsStringSync(result);
          logger.write('${file.path}: ${builder._changes.length} changes applied');
        }
        } catch (e, st) {
          logger.write('Error processing ${file.path}: $e\n$st', level: Level.error);
        }
      }
    }

    return 0;
  }
}

abstract class Migration {
  void runForUnit(CompilationUnit unit, MigrationBuilder builder);
}

class MigrationBuilder {
  MigrationBuilder(this.lineInfo);

  final LineInfo lineInfo;
  final List<_ChangeRequest> _changes = [];

  int getLineIndent(AstNode node) {
    var lineNumber = lineInfo.getLocation(node.offset).lineNumber - 1;
    var lineOffset = lineInfo.getOffsetOfLine(lineNumber);
    Token token = node.beginToken;
    while (token.previous != null && token.previous!.offset >= lineOffset) {
      token = token.previous!;
    }
    return token.offset - lineOffset;
  }

  void _addChange(_ChangeRequest change) {
    final index = _changes.indexWhere((c) => c.offset > change.offset);
    if (index == -1) {
      _changes.add(change);
    } else {
      _changes.insert(index, change);
    }
  }

  void insert(int offset, String text) {
    _addChange(_ReplacementChangeRequest(offset, 0, text));
  }

  void replace(int offset, int length, String text) {
    _addChange(_ReplacementChangeRequest(offset, length, text));
  }

  void delete(int offset, int length) {
    _addChange(_ReplacementChangeRequest(offset, length, ''));
  }

  void indent(int offset, int length, String indent) {
    for (final lineStart in lineInfo.lineStarts) {
      if (lineStart >= offset && lineStart < offset + length) {
        insert(lineStart, indent);
      }
    }
  }

  String _apply(String content) {
    int editOffset = 0;
    int contentLength = content.length;

    for (final change in _changes) {
      final start = change.offset + editOffset;
      final end = start + change.length;
      content = change.apply(content, start, end);
      editOffset += content.length - contentLength;
      contentLength = content.length;
    }

    return content;
  }
}

abstract class _ChangeRequest {
  _ChangeRequest(this.offset, this.length);

  final int offset;
  final int length;

  String apply(String content, int start, int end);
}

class _ReplacementChangeRequest extends _ChangeRequest {
  _ReplacementChangeRequest(super.offset, super.length, this.replacement);

  final String replacement;

  @override
  String apply(String content, int start, int end) {
    return content.replaceRange(start, end, replacement);
  }
}

class _EditChangeRequest extends _ChangeRequest {
  _EditChangeRequest(super.offset, super.length, this.edit);

  final String Function(String) edit;

  @override
  String apply(String content, int start, int end) {
    final text = content.substring(start, end);
    return content.replaceRange(start, end, edit(text));
  }
}
