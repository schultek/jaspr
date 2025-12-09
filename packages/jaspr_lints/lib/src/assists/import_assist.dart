import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../assist.dart';
import '../utils.dart';
import '../utils/imports_verifier.dart';

abstract class ConvertToPlatformImport extends ResolvedCorrectionProducer {
  ConvertToPlatformImport({required this.platform, required super.context});

  final String platform;

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case final ImportDirective node) {
      var fileName = unitResult.libraryFragment.source.shortName;
      if (fileName.endsWith('.dart')) fileName = fileName.substring(0, fileName.length - 5);

      final ImportDirective? importTarget = unit.directives
          .whereType<ImportDirective>()
          .where((d) => d.uri.stringValue == '$fileName.imports.dart')
          .firstOrNull;

      var elements = <Element>[];
      if (node.libraryImport case final libraryElement?) {
        final visitor = GatherUsedImportedElementsVisitor(unit.declaredFragment!.element);
        unit.accept(visitor);
        elements = visitor.usedElements.elements
            .followedBy(visitor.usedElements.usedExtensions)
            .where((e) => libraryElement.namespace.get2(e.name ?? '') == e)
            .toList();
      }

      final show = elements.map((e) => '#${e.name}').join(', ');

      await builder.addDartFileEdit(file, (builder) {
        final annotation = '@Import.on$platform(\'${node.uri.stringValue}\', show: [$show])\n';

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
  }
}

class ConvertToWebImport extends ConvertToPlatformImport {
  ConvertToWebImport({required super.context}) : super(platform: 'Web');

  @override
  AssistKind get assistKind => JasprAssistKind.convertToWebImport;
}

class ConvertToServerImport extends ConvertToPlatformImport {
  ConvertToServerImport({required super.context}) : super(platform: 'Server');

  @override
  AssistKind get assistKind => JasprAssistKind.convertToServerImport;
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
