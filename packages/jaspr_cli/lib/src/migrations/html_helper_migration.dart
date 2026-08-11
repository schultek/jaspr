import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:io/ansi.dart';

import 'migration_models.dart';

class HtmlHelperMigration implements Migration {
  @override
  String get minimumJasprVersion => '0.22.0';

  @override
  String get name => 'html_helper_migration';
  @override
  String get description =>
      'Migrates usages of `text()` and `fragment()` helpers to (Component)`.text()` and (Component)`.fragment()`. ';

  @override
  String get hint {
    return '${styleItalic.wrap(red.wrap('    - text(...), fragment(...)'))!}\n'
        '${styleItalic.wrap(green.wrap('    + .text(...), .fragment(...)'))!}';
  }

  @override
  void runForUnit(MigrationUnitContext context) {
    if (!context.unit.directives.any(
      (d) => d is ImportDirective && (d.uri.stringValue?.startsWith('package:jaspr/') ?? false),
    )) {
      // Only run if Jaspr is imported.
      return;
    }

    final texts = <SourceRange>[];
    final fragments = <SourceRange>[];
    final raw = <SourceRange>[];

    context.unit.accept(
      HelperVisitor(
        onText: texts.add,
        onFragment: fragments.add,
        onRaw: raw.add,
      ),
    );

    final useDotShorthands = context.features.contains('dot-shorthands');

    if (texts.isNotEmpty) {
      final replacement = useDotShorthands ? '.text' : 'Component.text';
      context.reporter.createMigration('Replaced text() with $replacement()', (builder) {
        for (final node in texts) {
          builder.replace(node.offset, node.length, replacement);
        }
      });
    }

    if (fragments.isNotEmpty) {
      final replacement = useDotShorthands ? '.fragment' : 'Component.fragment';
      context.reporter.createMigration('Replaced fragment() with $replacement()', (builder) {
        for (final node in fragments) {
          builder.replace(node.offset, node.length, replacement);
        }
      });
    }

    if (raw.isNotEmpty) {
      context.reporter.createMigration('Replaced raw() with RawText()', (builder) {
        for (final node in raw) {
          builder.replace(node.offset, node.length, 'RawText');
        }
      });
    }
  }

  @override
  List<MigrationResult> runForDirectory(MigrationContext context) {
    return [];
  }
}

class HelperVisitor extends RecursiveAstVisitor<void> {
  HelperVisitor({
    required this.onText,
    required this.onFragment,
    required this.onRaw,
  });

  final void Function(SourceRange node) onText;
  final void Function(SourceRange node) onFragment;
  final void Function(SourceRange node) onRaw;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final onHelper = switch (node.methodName.name) {
      'text' => onText,
      'fragment' => onFragment,
      'raw' => onRaw,
      _ => null,
    };
    if (onHelper != null && node.target == null && _isSingleOrKey(node.argumentList)) {
      onHelper(SourceRange(node.methodName.offset, node.methodName.length));
    }
    super.visitMethodInvocation(node);
  }

  /// Whether [args] consists of one positional argument and an optional named 'key' argument.
  static bool _isSingleOrKey(ArgumentList args) => switch (args.arguments) {
    [_] || [Expression(), NamedArgument(name: Token(lexeme: 'key'))] => true,
    _ => false,
  };
}
