import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/line_info.dart';

abstract class Migration {
  String get name;
  String get description;
  String get minimumJasprVersion;
  String get hint;

  void runForUnit(MigrationContext context);
}

class MigrationContext {
  MigrationContext(this.unit, this.reporter, this.features);

  final CompilationUnit unit;
  final MigrationReporter reporter;
  final List<String> features;
}

extension MigrationExtension on List<Migration> {
  List<MigrationResult> computeResults(
    List<String> directories,
    bool apply,
    void Function(File, Object, StackTrace) onError, {
    List<String> features = const [],
  }) {
    final results = <MigrationResult>[];

    for (final path in directories) {
      final dir = Directory(path);
      if (!dir.existsSync()) {
        continue;
      }

      final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

      for (final file in files) {
        final content = file.readAsStringSync();
        try {
          final result = parseString(
            content: content,
            featureSet: FeatureSet.latestLanguageVersion(flags: ['dot-shorthands']),
          );

          final builder = MigrationBuilder(result.lineInfo);
          final reporter = MigrationReporter(builder);
          final context = MigrationContext(result.unit, reporter, features);

          for (final migration in this) {
            reporter.run(migration, context);
          }

          if (reporter.migrations.isEmpty && reporter.warnings.isEmpty) {
            continue;
          }

          results.add(MigrationResult(file.path, content, reporter));

          if (apply) {
            final result = builder.apply(content);
            file.writeAsStringSync(result);
          }
        } catch (e, st) {
          onError(file, e, st);
        }
      }
    }

    return results;
  }
}

class MigrationResult {
  MigrationResult(this.path, this.content, this.reporter);

  final String path;
  final String content;
  final MigrationReporter reporter;
}

class MigrationReporter {
  MigrationReporter(this._builder);

  final MigrationBuilder _builder;
  final List<MigrationInstance> migrations = [];
  final List<MigrationWarning> warnings = [];

  Migration? _currentMigration;

  void run(Migration migration, MigrationContext context) {
    _currentMigration = migration;
    migration.runForUnit(context);
  }

  void reportManualMigrationNeeded(int offset, int length, String message) {
    warnings.add(MigrationWarning(offset, length, message, _currentMigration!));
  }

  void createMigration(String description, void Function(MigrationBuilder builder) migration) {
    migrations.add(MigrationInstance(description, _currentMigration!));
    migration(_builder);
  }
}

class MigrationWarning {
  MigrationWarning(this.offset, this.length, this.message, this.migration);

  final int offset;
  final int length;
  final String message;
  final Migration migration;
}

class MigrationInstance {
  MigrationInstance(this.description, this.migration);

  final String description;
  final Migration migration;

  @override
  String toString() => description;
}

class MigrationBuilder {
  MigrationBuilder(this.lineInfo);

  final LineInfo lineInfo;
  final List<ChangeRequest> changes = [];

  int getLineIndent(AstNode node) {
    var lineNumber = lineInfo.getLocation(node.offset).lineNumber - 1;
    var lineOffset = lineInfo.getOffsetOfLine(lineNumber);
    Token token = node.beginToken;
    while (token.previous != null && token.previous!.offset >= lineOffset) {
      token = token.previous!;
    }
    return token.offset - lineOffset;
  }

  void _addChange(ChangeRequest change) {
    final index = changes.indexWhere((c) => c.offset > change.offset);
    if (index == -1) {
      changes.add(change);
    } else {
      changes.insert(index, change);
    }
  }

  void insert(int offset, String text) {
    _addChange(ReplacementChangeRequest(offset, 0, text));
  }

  void replace(int offset, int length, String text) {
    _addChange(ReplacementChangeRequest(offset, length, text));
  }

  void delete(int offset, int length) {
    _addChange(ReplacementChangeRequest(offset, length, ''));
  }

  void indent(int offset, int length, String indent) {
    for (final lineStart in lineInfo.lineStarts) {
      if (lineStart >= offset && lineStart < offset + length) {
        insert(lineStart, indent);
      }
    }
  }

  String apply(String content) {
    int editOffset = 0;
    int contentLength = content.length;

    for (final change in changes) {
      final start = change.offset + editOffset;
      final end = start + change.length;
      content = change.apply(content, start, end);
      editOffset += content.length - contentLength;
      contentLength = content.length;
    }

    return content;
  }
}

abstract class ChangeRequest {
  ChangeRequest(this.offset, this.length);

  final int offset;
  final int length;

  String apply(String content, int start, int end);
}

class ReplacementChangeRequest extends ChangeRequest {
  ReplacementChangeRequest(super.offset, super.length, this.replacement);

  final String replacement;

  @override
  String apply(String content, int start, int end) {
    return content.replaceRange(start, end, replacement);
  }
}

class EditChangeRequest extends ChangeRequest {
  EditChangeRequest(super.offset, super.length, this.edit);

  final String Function(String) edit;

  @override
  String apply(String content, int start, int end) {
    final text = content.substring(start, end);
    return content.replaceRange(start, end, edit(text));
  }
}
