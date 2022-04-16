import 'package:analyzer/dart/element/element.dart';
import 'package:jaspr_builder/src/generators/function_generator.dart';

import 'element_generator.dart';

class ClassGenerator extends ElementGenerator<ClassElement> {
  ClassGenerator(ClassElement element, ResolverFn canResolve) : super(element, canResolve);

  late var members = (() {
    var members = {
      ...element.methods,
      ...element.accessors,
    };
    var superMembers = element.allSupertypes
        .where((t) => !t.isDartCoreObject)
        .expand((t) => [...t.element.methods, ...t.element.accessors].where((m) => !m.isStatic));
    for (var m in superMembers) {
      if (members.every((e) => e.name != m.name)) {
        members.add(m);
      }
    }
    return members.where((m) => m.isPublic).map((m) => FunctionGenerator(m, canResolve));
  })();

  @override
  String generate() {
    if (element.isEnum) {
      return 'enum ${element.name} {\n'
          '${element.fields.map((f) => f.name).join(', ')}'
          '}';
    }

    return 'class ${element.name} {\n'
        "${members.map((m) => m.generate()).join('\n')}"
        "}";
  }

  @override
  Iterable<Element> getTransitiveElements() {
    return [
      ...members.expand((g) => g.getTransitiveElements()),
    ];
  }
}
