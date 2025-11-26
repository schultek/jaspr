import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:file/file.dart';
import 'package:io/ansi.dart';

import 'migration_models.dart';

class ClientImportMigration implements Migration {
  @override
  String get minimumJasprVersion => '0.22.0';

  @override
  String get name => 'client_import_migration';
  @override
  String get description => "Migrates 'package:jaspr/browser.dart' imports to 'package:jaspr/client.dart'.";

  @override
  String get hint {
    return '${styleItalic.wrap(red.wrap("    - import 'package:jaspr/browser.dart';"))!}\n'
        '${styleItalic.wrap(green.wrap("    + import 'package:jaspr/client.dart';"))!}';
  }

  @override
  void runForUnit(MigrationContext context) {
    final browserImport = context.unit.directives
        .whereType<ImportDirective>()
        .where((d) => d.uri.stringValue == 'package:jaspr/browser.dart')
        .firstOrNull;

    if (browserImport != null) {
      context.reporter.createMigration("Changed 'package:jaspr/browser.dart' import to 'package:jaspr/client.dart'.", (
        builder,
      ) {
        builder.replace(
          browserImport.uri.offset,
          browserImport.uri.length,
          "'package:jaspr/client.dart'",
        );

        final visitor = BrowserIdentifierVisitor(
          onAppBindingIdentifier: (node) {
            builder.replace(node.offset, node.length, 'ClientAppBinding');
          },
        );
        context.unit.visitChildren(visitor);
      });
    }

    final browserTestImport = context.unit.directives
        .whereType<ImportDirective>()
        .where((d) => d.uri.stringValue == 'package:jaspr_test/browser_test.dart')
        .firstOrNull;

    if (browserTestImport != null) {
      context.reporter.createMigration(
        "Changed 'package:jaspr_test/browser_test.dart' import to 'package:jaspr_test/client_test.dart'.",
        (builder) {
          builder.replace(
            browserTestImport.uri.offset,
            browserTestImport.uri.length,
            "'package:jaspr_test/client_test.dart'",
          );

          final visitor = BrowserIdentifierVisitor(
            onTestFunction: (node) {
              if (node.name == 'testBrowser') {
                builder.replace(node.offset, node.length, 'testClient');
              }
            },
          );
          context.unit.visitChildren(visitor);
        },
      );
    }
  }

  @override
  List<MigrationResult> runForDirectory(Directory dir, bool apply) {
    return [];
  }
}

class BrowserIdentifierVisitor extends RecursiveAstVisitor<void> {
  BrowserIdentifierVisitor({
    this.onAppBindingIdentifier,
    this.onTestFunction,
  });

  final void Function(SimpleIdentifier node)? onAppBindingIdentifier;
  final void Function(SimpleIdentifier node)? onTestFunction;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == 'BrowserAppBinding' && onAppBindingIdentifier != null) {
      onAppBindingIdentifier!(node);
    }
    if (node.name == 'testBrowser' && onTestFunction != null) {
      onTestFunction!(node);
    }
  }
}
