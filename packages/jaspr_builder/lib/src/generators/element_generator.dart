import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

import 'class_generator.dart';
import 'function_generator.dart';

typedef ResolverFn = bool Function(DartType type);

abstract class ElementGenerator<T extends Element> {
  final T element;
  final ResolverFn canResolve;
  ElementGenerator(this.element, this.canResolve);

  String generate();

  Iterable<Element> getTransitiveElements({bool recursive = false});

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
    } else if (t is InterfaceType) {
      if (t.typeArguments.isNotEmpty && canResolve(t.element.thisType)) {
        var tt = t.element.name;
        var tp = t.typeArguments.map((t) => typeName(t));
        return '$tt<${tp.join(', ')}>${t.nullabilitySuffix != NullabilitySuffix.none ? '?' : ''}';
      }
    }

    return 'dynamic';
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
  Iterable<Element> getTransitiveElements({bool recursive = false}) => [];
}
