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
  String get description =>
      "Migrates 'package:jaspr/jaspr.dart' imports to 'package:jaspr/dom.dart' where appropriate.";

  @override
  String get hint {
    return '${styleItalic.wrap(red.wrap("    - import 'package:jaspr/jaspr.dart';"))!}\n'
        '${styleItalic.wrap(green.wrap("    + import 'package:jaspr/dom.dart';"))!}';
  }

  @override
  void runForUnit(CompilationUnit unit, MigrationReporter reporter) {
    final domImport = unit.directives
        .whereType<ImportDirective>()
        .where((d) => d.uri.stringValue == 'package:jaspr/dom.dart')
        .firstOrNull;

    if (domImport != null) {
      // Already using dom import.
      return;
    }

    final jasprImport = unit.directives
        .whereType<ImportDirective>()
        .where((d) => d.uri.stringValue == 'package:jaspr/jaspr.dart')
        .firstOrNull;
    final platformImport = unit.directives
        .whereType<ImportDirective>()
        .where(
          (d) =>
              d.uri.stringValue == 'package:jaspr/browser.dart' || //
              d.uri.stringValue == 'package:jaspr/server.dart',
        )
        .firstOrNull;

    if (jasprImport == null && platformImport == null) {
      // Only run if Jaspr is imported.
      return;
    }

    final visitor = DomApiUsageVisitor();
    unit.accept(visitor);
    if (!visitor.usesDomApis) {
      // No need to migrate if no DOM APIs are used.
      return;
    }

    if (jasprImport != null && !visitor.usesDocumentApi) {
      reporter.createMigration("Changed 'package:jaspr/jaspr.dart' import to 'package:jaspr/dom.dart'.", (builder) {
        builder.replace(
          jasprImport.uri.offset,
          jasprImport.uri.length,
          "'package:jaspr/dom.dart'",
        );
      });
    } else {
      reporter.createMigration("Added 'package:jaspr/dom.dart' import.", (builder) {
        builder.insert(
          platformImport?.offset ?? jasprImport!.offset,
          "import 'package:jaspr/dom.dart';\n",
        );
      });
    }
  }
}

class DomApiUsageVisitor extends RecursiveAstVisitor<void> {
  DomApiUsageVisitor();

  bool _useDomApis = false;
  bool get usesDomApis => _useDomApis;

  bool get usesDocumentApi => _useDocumentApi;
  bool _useDocumentApi = false;

  static final _allTags = {
    for (final group in htmlSpec.values) ...group.keys,
    'raw',
    'RawText',
    'DomValidator',
  };

  static final _domClasses = {'css', 'Styles', 'StyleRule', 'Color', 'Unit'};

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_allTags.contains(node.methodName.name) && node.target == null) {
      _useDomApis = true;
    } else if (_domClasses.contains(node.methodName.name) && node.target == null) {
      _useDomApis = true;
    } else if (node.target case SimpleIdentifier id when _domClasses.contains(id.name)) {
      _useDomApis = true;
    }

    if (node.target case SimpleIdentifier id when id.name == 'Document') {
      _useDocumentApi = true;
    }

    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final constr = node.constructorName;
    if (_allTags.contains(constr.type.name.lexeme) && constr.name == null) {
      _useDomApis = true;
    } else if (_domClasses.contains(constr.type.name.lexeme)) {
      _useDomApis = true;
    }

    if (constr.type.name.lexeme == 'Document') {
      _useDocumentApi = true;
    }

    super.visitInstanceCreationExpression(node);
  }
}
