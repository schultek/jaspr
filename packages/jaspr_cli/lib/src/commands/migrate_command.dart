import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:io/ansi.dart';

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
    argParser.addFlag(
      'apply',
      help: 'Apply the proposed changes.',
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
  late final bool apply = argResults!['apply'] as bool;

  static List<Migration> get allMigrations => [
        BuildMethodMigration(),
      ];

  @override
  Future<int> runCommand() async {
    final directories = ['lib', 'web', 'test'];

    final currentJasprVersion = switch (config.pubspecLock) {
      {'packages': {'jaspr': {'version': String version}}} => version,
      _ => '',
    };

    var migrations = allMigrations.where((m) {
      return currentJasprVersion.compareTo(m.minimumJasprVersion) >= 0;
    }).toList();

    if (migrations.isEmpty) {
      logger.write(
          'No migrations available for you current Jaspr version ($currentJasprVersion).');
      return 0;
    }

    if (!apply && !dryRun) {
      stdout.write('Available migrations:\n\n'
          '${migrations.map((m) => '  ${m.name} · ${m.description}\n${m.hint}').join('\n')}\n\n');

      stdout.write(
          'Run with --dry-run to preview all migration changes or --apply to apply them.');

      return 1;
    }

    final results =
        migrations.computeResults(directories, apply, (file, e, st) {
      logger.write('Error processing ${file.path}: $e\n$st',
          level: Level.error);
    });

    final check = green.wrap(styleBold.wrap('✓'));
    final warn = yellow.wrap(styleBold.wrap('⚠'));

    for (final result in results) {
      if (result.reporter._migrations.isEmpty) {
        continue;
      }
      StringBuffer output = StringBuffer();
      output.write('${result.path}\n');

      for (final migration in result.reporter._migrations) {
        output.write(
            '  $check ${migration.migration.name} · ${migration.description}\n');
      }

      stdout.write('$output\n');
    }

    for (final result in results) {
      if (result.reporter._warnings.isEmpty) {
        continue;
      }
      StringBuffer output = StringBuffer();
      output.write('${result.path}\n');

      for (final warning in result.reporter._warnings) {
        output
            .write('  $warn ${warning.migration.name} · ${warning.message}\n');
      }

      stdout.write('$output\n');
    }

    final successCount = results.fold<int>(
        0, (sum, result) => sum + result.reporter._migrations.length);

    final warningCount = results.fold<int>(
        0, (sum, result) => sum + result.reporter._warnings.length);

    logger.write(
        styleBold.wrap(
            'Processed ${results.length} files, applied $successCount migrations, found $warningCount warnings.')!,
        level: Level.info);

    return 0;
  }
}

abstract class Migration {
  String get name;
  String get description;
  String get minimumJasprVersion;
  String get hint;

  void runForUnit(CompilationUnit unit, MigrationReporter reporter);
}

extension MigrationExtension on List<Migration> {
  List<MigrationResult> computeResults(List<String> directories, bool apply,
      void Function(File, Object, StackTrace) onError) {
    final results = <MigrationResult>[];

    for (final path in directories) {
      final dir = Directory(path);
      if (!dir.existsSync()) {
        continue;
      }

      final files = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in files) {
        final content = file.readAsStringSync();
        try {
          final result = parseString(content: content);

          final builder = MigrationBuilder(result.lineInfo);
          final reporter = MigrationReporter(builder);

          for (final migration in this) {
            reporter._currentMigration = migration;
            migration.runForUnit(result.unit, reporter);
          }

          if (reporter._migrations.isEmpty && reporter._warnings.isEmpty) {
            continue;
          }

          results.add(MigrationResult(file.path, content, reporter));

          if (apply) {
            final result = builder._apply(content);
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
  final List<_MigrationInstance> _migrations = [];
  final List<_MigrationWarning> _warnings = [];

  Migration? _currentMigration;

  void reportManualMigrationNeeded(int offset, int length, String message) {
    _warnings
        .add(_MigrationWarning(offset, length, message, _currentMigration!));
  }

  void createMigration(
      String description, void Function(MigrationBuilder builder) migration) {
    _migrations.add(_MigrationInstance(description, _currentMigration!));
    migration(_builder);
  }
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

// class _EditChangeRequest extends _ChangeRequest {
//   _EditChangeRequest(super.offset, super.length, this.edit);

//   final String Function(String) edit;

//   @override
//   String apply(String content, int start, int end) {
//     final text = content.substring(start, end);
//     return content.replaceRange(start, end, edit(text));
//   }
// }

class _MigrationWarning {
  _MigrationWarning(this.offset, this.length, this.message, this.migration);

  final int offset;
  final int length;
  final String message;
  final Migration migration;
}

class _MigrationInstance {
  _MigrationInstance(this.description, this.migration);

  final String description;
  final Migration migration;

  @override
  String toString() => description;
}
