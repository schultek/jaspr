import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

extension TransitiveTypeElements on DartType {
  Iterable<Element> get transitiveElements {
    var t = this;
    if (t is ParameterizedType) {
      return [
        if (!_standardType()) element!,
        ...t.typeArguments.expand((t) => t.transitiveElements),
      ];
    } else if (t is VoidType || t is DynamicType) {
      return [];
    } else if (t is TypeParameterType) {
      return t.bound.transitiveElements;
    } else if (t is FunctionType) {
      return [
        ...t.returnType.transitiveElements,
        ...t.parameters.expand((p) => p.type.transitiveElements),
        ...t.typeFormals.expand((t) => t.bound?.transitiveElements ?? []),
      ];
    } else {
      print("UNSUPPORTED ${t.runtimeType}");
      return [if (t.element != null) t.element!];
    }
  }

  bool _standardType() {
    if (element?.library?.isInSdk ?? true) {
      return ['dart.core', 'dart.async'].contains(element?.library?.name);
    }
    return false;
  }
}

extension ElementNode on Element {
  AstNode? get node {
    var result = session?.getParsedLibraryByElement(library!);
    if (result is ParsedLibraryResult) {
      return result.getElementDeclaration(this)?.node;
    } else {
      return null;
    }
  }
}