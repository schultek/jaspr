import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:io/ansi.dart';

import '../config.dart';
import 'migration_models.dart';

class EntrypointMigration implements Migration {
  @override
  String get minimumJasprVersion => '0.22.0';

  @override
  String get name => 'entrypoint_migration';
  @override
  String get description => 'Migrates to separate "main.server.dart" and "main.client.dart" entry points.';

  @override
  String get hint {
    return '${styleItalic.wrap(red.wrap('    - main.dart, jaspr_options.dart'))!}\n'
        '${styleItalic.wrap(green.wrap('    + main.server.dart, main.server.options.dart'))!}\n'
        '${styleItalic.wrap(green.wrap('    + main.client.dart, main.client.options.dart'))!}';
  }

  @override
  void runForUnit(MigrationUnitContext context) {
    final optionsImport = context.unit.directives
        .whereType<ImportDirective>()
        .where((d) => d.uri.stringValue?.endsWith('jaspr_options.dart') ?? false)
        .firstOrNull;

    if (optionsImport == null) {
      // Only run if jaspr_options.dart is imported.
      return;
    }

    final jasprImport = context.unit.directives
        .whereType<ImportDirective>()
        .where((d) => d.uri.stringValue?.startsWith('package:jaspr/jaspr.dart') ?? false)
        .firstOrNull;

    context.reporter.createMigration("Replaced 'jaspr_options.dart' import with 'main.server.options.dart'", (builder) {
      builder.replace(optionsImport.uri.offset, optionsImport.uri.length, "'main.server.options.dart'");
      if (jasprImport != null) {
        builder.replace(jasprImport.uri.offset, jasprImport.uri.length, "'package:jaspr/server.dart'");
      }

      final visitor = OptionsVisitor(
        onOptionsIdentifier: (node) {
          builder.replace(node.offset, node.length, 'defaultServerOptions');
        },
      );
      context.unit.visitChildren(visitor);
    });
  }

  @override
  List<MigrationResult> runForDirectory(MigrationContext context) {
    if (context.dir.path != 'lib') return [];

    final results = <MigrationResult>[];

    if (context.project.modeOrNull?.isServerOrStatic ?? false) {
      var mainFile = context.dir.childFile('main.dart');
      var mainServerFile = context.dir.childFile('main.server.dart');
      if (mainFile.existsSync() && !mainServerFile.existsSync()) {
        if (context.apply) {
          mainFile.renameSync(mainServerFile.path);
        }
        results.add(
          MigrationResult(mainFile.path, [
            MigrationInstance("Renamed 'main.dart' file to 'main.server.dart'", this),
          ], []),
        );
      }

      var jasprOptionsFile = context.dir.childFile('jaspr_options.dart');
      if (jasprOptionsFile.existsSync()) {
        if (context.apply) {
          jasprOptionsFile.deleteSync();
        }
        results.add(
          MigrationResult(jasprOptionsFile.path, [
            MigrationInstance("Removed 'jaspr_options.dart' file. Run 'jaspr serve' to re-generate.", this),
          ], []),
        );
      }

      var mainClientFile = context.dir.childFile('main.client.dart');
      if (!mainClientFile.existsSync()) {
        if (context.apply) {
          mainClientFile
            ..createSync()
            ..writeAsStringSync(_mainClientTemplate);
        }
        results.add(
          MigrationResult(mainClientFile.path, [
            MigrationInstance("Created 'main.client.dart' file", this),
          ], []),
        );
      }
    }

    return results;
  }
}

class OptionsVisitor extends RecursiveAstVisitor<void> {
  OptionsVisitor({
    required this.onOptionsIdentifier,
  });

  final void Function(SimpleIdentifier node) onOptionsIdentifier;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == 'defaultJasprOptions') {
      onOptionsIdentifier(node);
    }
  }
}

const String _mainClientTemplate = '''
// The entrypoint for the **client** environment.
//
// The [main] method will only be executed on the client after loading the page.

// Client-specific Jaspr import.
import 'package:jaspr/client.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'main.client.options.dart';

void main() {
  // Initializes the client environment with the generated default options.
  Jaspr.initializeApp(
    options: defaultClientOptions,
  );

  // Starts the app.
  //
  // [ClientApp] automatically loads and renders all components annotated with @client.
  //
  // You can wrap this with additional [InheritedComponent]s to share state across multiple 
  // @client components if needed.
  runApp(
    const ClientApp(),
  );
}
''';
