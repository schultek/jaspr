import 'package:analyzer/dart/element/element.dart';

import 'element_generator.dart';
import 'function_generator.dart';

class ClassGenerator extends ElementGenerator<ClassElement> {
  ClassGenerator(ClassElement element, ResolverFn canResolve) : super(element, canResolve);

  late Iterable<FunctionGenerator> members = (() {
    var members = <String, ExecutableElement>{
      for (var e in element.allSupertypes.where((t) => !t.isDartCoreObject && !canResolve(t)).expand((t) => [
            ...t.element.methods.where((m) => m.isPublic && !m.isStatic),
            ...t.element.accessors.where((m) => m.isPublic && !m.isStatic),
          ]))
        e.name: e,
      for (var e in element.methods.where((m) => m.isPublic)) e.name: e,
      for (var e in element.accessors.where((m) => m.isPublic)) e.name: e,
      for (var e in element.constructors.where((c) => !c.isSynthetic)) e.name: e,
    };

    return members.values.map((m) => FunctionGenerator(m, canResolve));
  })();

  @override
  String generate() {
    if (element.isEnum) {
      return 'enum ${element.name} {\n'
          '${element.fields.map((f) => f.name).join(', ')}'
          '}';
    }

    var typeArgs = element.typeParameters.isNotEmpty
        ? '<${element.typeParameters.map((e) => e.getDisplayString(withNullability: true)).join(', ')}>'
        : '';

    var abstractStr = element.isAbstract ? 'abstract ' : '';
    var extendsStr = element.supertype != null && canResolve(element.supertype!)
        ? ' extends ${element.supertype!.getDisplayString(withNullability: true)}'
        : '';

    var mixins = element.mixins.where(canResolve).map((t) => t.getDisplayString(withNullability: true));
    var mixinStr = mixins.isNotEmpty ? ' with ${mixins.join(', ')}' : '';

    var interfaces = element.interfaces.where(canResolve).map((t) => t.getDisplayString(withNullability: true));
    var interfaceStr = interfaces.isNotEmpty ? ' implements ${interfaces.join(', ')}' : '';

    return '${abstractStr}class ${element.name}$typeArgs$extendsStr$mixinStr$interfaceStr {\n'
        "${members.map((m) => m.generate()).join('\n')}"
        "}";
  }

  @override
  Iterable<Element> getTransitiveElements({bool recursive = false}) {
    return [
      if (recursive) ...members.expand((g) => g.getTransitiveElements()),
      //if (element.supertype != null && !element.supertype!.isDartCoreObject) element.supertype!.element,
      //...element.mixins.map((t) => t.element),
      //..element.interfaces.map((t) => t.element),
    ];
  }
}
