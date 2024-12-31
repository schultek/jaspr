import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class ImportAssistProvider extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addImportDirective((node) {
      if (!target.coveredBy(node.sourceRange)) {
        return;
      }

      var unit = node.parent;
      if (unit is! CompilationUnit || unit.declaredElement == null) return;

      var fileName = resolver.source.shortName;
      if (fileName.endsWith('.dart')) fileName = fileName.substring(0, fileName.length - 5);

      ImportDirective? importTarget = unit.directives
          .whereType<ImportDirective>()
          .where((d) => d.uri.stringValue == '$fileName.imports.dart')
          .firstOrNull;

      var elements = <Element>[];
      if (node.element case var libraryElement?) {
        var visitor = GatherUsedImportedElementsVisitor(unit.declaredElement!.library);
        unit.accept(visitor);
        elements = visitor.usedElements.elements
            .followedBy(visitor.usedElements.usedExtensions)
            .where((e) => libraryElement.namespace.get(e.name ?? '') == e)
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
      builder.addSimpleInsertion(node.name2.end, 'OrStubbed');
    }
  }
}

class GatherUsedImportedElementsVisitor extends RecursiveAstVisitor<void> {
  GatherUsedImportedElementsVisitor(this.library);

  final LibraryElement library;
  final usedElements = _UsedElements();

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    var element = node.staticElement;
    if (element != null) {
      usedElements.elements.add(element);
    }
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitExtensionOverride(ExtensionOverride node) {
    var element = node.element;
    usedElements.usedExtensions.add(element);
      super.visitExtensionOverride(node);
  }
}

class _UsedElements {
  final elements = <Element>{};
  final usedExtensions = <Element>{};
}