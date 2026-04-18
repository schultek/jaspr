import 'package:universal_web/web.dart' as web;

import '../../foundation/constants.dart';
import '../../foundation/diagnostics.dart';
import '../../framework/framework.dart';

sealed class TreeElement {
  String? get id;
}

class LocalElement extends TreeElement {
  LocalElement(this.element);

  static LocalElement? forId(String id) {
    if (_idToElement[id]?.target case final element?) {
      return LocalElement(element);
    }
    return null;
  }

  final Element element;

  static final Expando<Element> nodeRegistry = Expando<Element>();

  static final Map<String, WeakReference<Element>> _idToElement = {};
  static final Expando<String> _elementToId = Expando<String>();
  static int _nextId = 0;

  @override
  String get id => toId(element);

  static String toId(Element element) {
    var id = _elementToId[element];
    if (id == null) {
      id = '\$${kIsWeb ? 'c' : 's'}${_nextId++}';
      _elementToId[element] = id;
      _idToElement[id] = WeakReference(element);
    }
    return id;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is LocalElement && other.element == element);
  }

  @override
  int get hashCode => element.hashCode;
}

class RemoteElement extends TreeElement {
  RemoteElement({
    required this.name,
    this.parent,
    required this.properties,
    required this.children,
    this.node,
  }) {
    if (id case final id?) {
      _idToElement[id] = WeakReference(this);
    }
  }

  factory RemoteElement.fromDiagnosticsNode(DiagnosticsNode node, {RemoteElement? parent}) {
    final element = RemoteElement(
      name: node.name,
      parent: parent,
      properties: node.properties ?? [],
      children: [],
    );

    if (node.children case final children?) {
      element.children.addAll([
        for (final child in children) RemoteElement.fromDiagnosticsNode(child, parent: element),
      ]);
    }
    return element;
  }

  static RemoteElement? forId(String id) {
    return _idToElement[id]?.target;
  }

  final String name;
  final RemoteElement? parent;
  final List<DiagnosticsProperty> properties;
  final List<RemoteElement> children;

  web.Element? node;

  static final Expando<RemoteElement> nodeRegistry = Expando<RemoteElement>();

  static final Map<String, WeakReference<RemoteElement>> _idToElement = {};

  @override
  late final String? id = properties.where((p) => p.name == 'id').firstOrNull?.value.toString();
}

extension DomTag on List<DiagnosticsProperty> {
  String? getTagForDomElement() {
    return where(
      (p) => p.name == 'component',
    ).firstOrNull?.properties?.where((p) => p.name == 'tag').firstOrNull?.value.toString();
  }
}
