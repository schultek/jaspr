import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'class_generator.dart';
import 'function_generator.dart';

typedef ResolverFn = bool Function(DartType type);

abstract class ElementGenerator<T extends Element> {
  final T element;
  final ResolverFn canResolve;
  ElementGenerator(this.element, this.canResolve);

  String generate();

  Iterable<Element> getTransitiveElements();

  String typeName(DartType t) {
    if (canResolve(t)) {
      return t.getDisplayString(withNullability: true);
    } else if (t is FunctionType) {
      var rt = typeName(t.returnType);
      var pt = t.normalParameterTypes.map(typeName);
      var ot = t.optionalParameterTypes.map(typeName);
      var nt = t.namedParameterTypes.map((k, v) => MapEntry(k, typeName(v)));

      var p = pt.join(', ');
      if (ot.isNotEmpty) {
        if (p.isNotEmpty) p += ', ';
        p += '[${ot.join(', ')}]';
      } else if (nt.isNotEmpty) {
        if (p.isNotEmpty) p += ', ';
        p += '[${nt.entries.map((e) => '${e.value} ${e.key}').join(', ')}]';
      }

      return '$rt Function($p)';
    } else {
      return 'dynamic';
    }
  }

  static ElementGenerator from(Element e, ResolverFn canResolve) {
    if (e is ClassElement) {
      return ClassGenerator(e, canResolve);
    } else if (e is ExecutableElement) {
      return FunctionGenerator(e, canResolve);
    } else {
      return UnsupportedElementGenerator(e);
    }
  }
}

class UnsupportedElementGenerator extends ElementGenerator {
  UnsupportedElementGenerator(Element element) : super(element, (_) => false);

  @override
  String generate() {
    print("Unsupported element ${element.runtimeType} $element");
    return '// Unsupported element ${element.runtimeType} $element';
  }

  @override
  Iterable<Element> getTransitiveElements() => [];
}

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
