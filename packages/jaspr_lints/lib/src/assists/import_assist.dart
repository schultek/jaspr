import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils/imports_verifier.dart';

class ImportAssistProvider extends DartAssist {
  @override
  void run(CustomLintResolver resolver, ChangeReporter reporter, CustomLintContext context, SourceRange target) {
    context.registry.addImportDirective((node) {
      if (!target.coveredBy(node.sourceRange)) {
        return;
      }

      var unit = node.parent;
      if (unit is! CompilationUnit || unit.declaredFragment == null) return;

      var fileName = resolver.source.shortName;
      if (fileName.endsWith('.dart')) fileName = fileName.substring(0, fileName.length - 5);

      ImportDirective? importTarget = unit.directives
          .whereType<ImportDirective>()
          .where((d) => d.uri.stringValue == '$fileName.imports.dart')
          .firstOrNull;

      var elements = <Element>[];
      if (node.libraryImport case var libraryElement?) {
        var visitor = GatherUsedImportedElementsVisitor(unit.declaredFragment!.element);
        unit.accept(visitor);
        elements = visitor.usedElements.elements
            .followedBy(visitor.usedElements.usedExtensions)
            .where((e) => libraryElement.namespace.get2(e.name ?? '') == e)
            .toList();
      }

      var show = elements.map((e) => '#${e.name}').join(', ');

      void convertImport(String name) {
        reporter
            .createChangeBuilder(message: 'Convert to ${name.toLowerCase()}-only import', priority: 1)
            .addDartFileEdit((builder) {
              var annotation = '@Import.on$name(\'${node.uri.stringValue}\', show: [$show])\n';

              if (importTarget != null) {
                builder.addSimpleInsertion(importTarget.importKeyword.offset, annotation);
              } else {
                builder.addSimpleInsertion(
                  unit.directives.lastOrNull?.end ?? 0,
                  '\n${annotation}import \'$fileName.imports.dart\';',
                );
              }

              unit.accept(ReplaceStubbedTypesVisitor(builder, elements));

              builder.addDeletion(node.sourceRange);
            });
      }

      convertImport('Web');
      convertImport('Server');
    });
  }
}

class ReplaceStubbedTypesVisitor extends RecursiveAstVisitor<void> {
  ReplaceStubbedTypesVisitor(this.builder, this.elements);

  final DartFileEditBuilder builder;
  final List<Element> elements;

  @override
  void visitNamedType(NamedType node) {
    if (elements.contains(node.type?.element)) {
      if (node.parent is ConstructorName) return;
      builder.addSimpleInsertion(node.name.end, 'OrStubbed');
    }
  }
}
