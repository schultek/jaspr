class DiagnosticsNode {
  const DiagnosticsNode({
    required this.name,
    this.properties,
    this.children,
  });

  factory DiagnosticsNode.fromJsonMap(Map<String, Object?> map) {
    return DiagnosticsNode(
      name: map['n'] as String,

      properties: map['p'] == null
          ? null
          : (map['p'] as List<Object?>).map((p) => DiagnosticsProperty.fromJsonValue(p as List<Object?>)).toList(),
      children: map['c'] == null
          ? null
          : (map['c'] as List<Object?>).map((c) => DiagnosticsNode.fromJsonMap(c as Map<String, Object?>)).toList(),
    );
  }

  /// The name of the property or component type.
  final String name;

  /// Properties of a component.
  final List<DiagnosticsProperty>? properties;

  /// Child components.
  final List<DiagnosticsNode>? children;

  /// Serializes this node to a JSON map.
  Map<String, Object?> toJsonMap() {
    return {
      'n': name,

      if (properties != null && properties!.isNotEmpty) 'p': properties!.map((p) => p.toJsonValue()).toList(),
      if (children != null && children!.isNotEmpty) 'c': children!.map((c) => c.toJsonMap()).toList(),
    };
  }
}

class DiagnosticsProperty {
  const DiagnosticsProperty({required this.name, this.value, this.properties});

  factory DiagnosticsProperty.fromJsonValue(List<Object?> value) {
    return DiagnosticsProperty(
      name: value[0] as String,
      value: value[1],
      properties: value[2] == null
          ? null
          : (value[2] as List<Object?>).map((c) => DiagnosticsProperty.fromJsonValue(c as List<Object?>)).toList(),
    );
  }

  final String name;
  final Object? value;
  final List<DiagnosticsProperty>? properties;

  List<Object?> toJsonValue() {
    return [name, value, properties?.map((c) => c.toJsonValue()).toList()];
  }
}

abstract mixin class Diagnosticable {
  const Diagnosticable();

  /// Returns a list of `DiagnosticsProperty` objects describing this object.
  List<DiagnosticsProperty> debugFillProperties() => const [];
}

abstract class DiagnosticableTree extends Diagnosticable {
  const DiagnosticableTree();

  /// Visits all children of this node.
  void debugVisitChildren(void Function(DiagnosticableTree) visitor) {}
}
