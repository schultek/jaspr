import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:io/ansi.dart';

import '../html_spec.dart';
import 'migration_models.dart';

class DomImportMigration implements Migration {
  @override
  String get minimumJasprVersion => '0.22.0';

  @override
  String get name => 'dom_import_migration';
  @override
  String get description => "Adds 'package:jaspr/dom.dart' import where appropriate.";

  @override
  String get hint {
    return styleItalic.wrap(green.wrap("    + import 'package:jaspr/dom.dart';"))!;
  }

  @override
  void runForUnit(MigrationUnitContext context) {
    final domImport = context.unit.directives
        .whereType<ImportDirective>()
        .where((d) => d.uri.stringValue == 'package:jaspr/dom.dart')
        .firstOrNull;

    if (domImport != null) {
      // Already using dom import.
      return;
    }

    final jasprImport = context.unit.directives
        .whereType<ImportDirective>()
        .where((d) => d.uri.stringValue == 'package:jaspr/jaspr.dart')
        .firstOrNull;
    final platformImport = context.unit.directives
        .whereType<ImportDirective>()
        .where(
          (d) =>
              d.uri.stringValue == 'package:jaspr/browser.dart' || //
              d.uri.stringValue == 'package:jaspr/client.dart' ||
              d.uri.stringValue == 'package:jaspr/server.dart',
        )
        .firstOrNull;

    if (jasprImport == null && platformImport == null) {
      // Only run if Jaspr is imported.
      return;
    }

    final visitor = DomApiUsageVisitor();
    context.unit.accept(visitor);
    if (!visitor.usesDomApis) {
      // No need to migrate if no DOM APIs are used.
      return;
    }

    context.reporter.createMigration("Added 'package:jaspr/dom.dart' import.", (builder) {
      builder.insert(
        jasprImport?.offset ?? platformImport!.offset,
        "import 'package:jaspr/dom.dart';\n",
      );
    });
  }

  @override
  List<MigrationResult> runForDirectory(MigrationContext context) {
    return [];
  }
}

class DomApiUsageVisitor extends RecursiveAstVisitor<void> {
  DomApiUsageVisitor();

  bool _useDomApis = false;
  bool get usesDomApis => _useDomApis;

  static final _allTags = {
    for (final group in htmlSpec.values) ...group.keys,
    'raw',
    'RawText',
  };

  static final _domClasses = {'css', 'Styles', 'StyleRule', 'Color', 'Unit'};

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_allTags.contains(node.methodName.name) && node.target == null) {
      _useDomApis = true;
      return;
    } else if (_domClasses.contains(node.methodName.name) && node.target == null) {
      _useDomApis = true;
      return;
    } else if (node.target case SimpleIdentifier id when _domClasses.contains(id.name)) {
      _useDomApis = true;
      return;
    }

    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final constr = node.constructorName;
    if (_allTags.contains(constr.type.name.lexeme) && constr.name == null) {
      _useDomApis = true;
      return;
    } else if (_domClasses.contains(constr.type.name.lexeme)) {
      _useDomApis = true;
      return;
    }

    super.visitInstanceCreationExpression(node);
  }
}
