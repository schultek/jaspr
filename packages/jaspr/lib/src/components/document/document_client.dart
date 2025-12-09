import 'package:universal_web/web.dart' as web;

import '../../../client.dart';
import '../../client/utils.dart';
import '../../dom/type_checks.dart';

abstract class Document implements Component {
  /// Attaches a set of attributes to the `<html>` element.
  ///
  /// This can be used at any point in the component tree and is supported both on the
  /// server during pre-rendering and on the client.
  ///
  /// Can be used multiple times in an application where deeper or latter mounted
  /// components will override duplicate attributes from other `.html()` components.
  const factory Document.html({Map<String, String>? attributes, Key? key}) = AttachDocument.html;

  /// Renders metadata and other elements inside the `<head>` of the document.
  ///
  /// Any children are pulled out of the normal rendering tree of the application and rendered instead
  /// inside a special section of the `<head>` element of the document. This is supported both on the
  /// server during pre-rendering and on the client.
  ///
  /// Can be used multiple times in an application where deeper or latter mounted
  /// components will override duplicate elements from other `.head()` components.
  ///
  /// ```dart
  /// Parent(children: [
  ///   Document.head(
  ///     title: "My Title",
  ///     meta: {"description": "My Page Description"}
  ///   ),
  ///   Child(children: [
  ///     Document.head(
  ///       title: "Nested Title"
  ///     ),
  ///   ]),
  /// ]),
  /// ```
  ///
  /// The above configuration of components will result in these elements inside `<head>`:
  ///
  /// ```html
  /// <head>
  ///   <title>Nested Title</title>
  ///   <meta name="description" content="My Page Description">
  /// </head>
  /// ```
  ///
  /// Note that 'deeper or latter' here does not result in a true DFS ordering. Components that are mounted
  /// deeper but prior will override latter but shallower components.
  ///
  /// Elements rendered by nested `.head()` are overridden using the following system:
  /// - elements with an `id` override other elements with the same `id`
  /// - `<title>` and `<base>` elements override other `<title>` or `<base>` elements respectively
  /// - `<meta>` elements override other `<meta>` elements with the same `name`
  const factory Document.head({String? title, Map<String, String>? meta, List<Component>? children, Key? key}) =
      HeadDocument;

  /// Attaches a set of attributes to the `<body>` element.
  ///
  /// This can be used at any point in the component tree and is supported both on the
  /// server during pre-rendering and on the client.
  ///
  /// Can be used multiple times in an application where deeper or latter mounted
  /// components will override duplicate attributes from other `.body()` components.
  const factory Document.body({Map<String, String>? attributes, Key? key}) = AttachDocument.body;
}

class HeadDocument extends StatelessComponent implements Document {
  const HeadDocument({this.title, this.meta, this.children, super.key});

  final String? title;
  final Map<String, String>? meta;
  final List<Component>? children;

  @override
  Component build(BuildContext context) {
    return AttachDocument(
      target: AttachTarget.head,
      attributes: null,
      children: [
        if (title != null) Component.element(tag: 'title', children: [Component.text(title!)]),
        if (meta != null)
          for (final e in meta!.entries)
            Component.element(tag: 'meta', attributes: {'name': e.key, 'content': e.value}),
        ...?children,
      ],
    );
  }
}

enum AttachTarget {
  html(true, false),
  body(true, false),
  head(false, true);

  const AttachTarget(this.attachAttributes, this.attachChildren);
  final bool attachAttributes;
  final bool attachChildren;
}

class AttachDocument extends Component implements Document {
  const AttachDocument.html({this.attributes, super.key}) : target = AttachTarget.html, children = const [];
  const AttachDocument.body({this.attributes, super.key}) : target = AttachTarget.body, children = const [];
  const AttachDocument({required this.target, this.attributes, required this.children});

  final AttachTarget target;
  final Map<String, String>? attributes;
  final List<Component> children;

  @override
  Element createElement() => _AttachElement(this);
}

class _AttachElement extends MultiChildRenderObjectElement {
  _AttachElement(AttachDocument super.component);

  @override
  List<Component> buildChildren() => (component as AttachDocument).children;

  @override
  RenderObject createRenderObject() {
    final AttachDocument(:target, :attributes) = component as AttachDocument;
    return AttachRenderObject(target, depth)..attributes = attributes;
  }

  @override
  void updateRenderObject(AttachRenderObject renderObject) {
    final AttachDocument(:target, :attributes) = component as AttachDocument;
    renderObject
      ..target = target
      ..attributes = attributes;
  }

  @override
  void activate() {
    super.activate();
    (renderObject as AttachRenderObject).depth = depth;
  }

  @override
  void detachRenderObject() {
    super.detachRenderObject();
    final renderObject = this.renderObject as AttachRenderObject;
    AttachAdapter.instanceFor(renderObject._target).unregister(renderObject);
  }
}

class AttachRenderObject extends DomRenderText {
  AttachRenderObject(this._target, this._depth) : super('', null) {
    AttachAdapter.instanceFor(_target).register(this);
  }

  final List<web.Node> children = [];

  AttachTarget _target;
  set target(AttachTarget target) {
    if (_target == target) return;
    AttachAdapter.instanceFor(_target).unregister(this);
    _target = target;
    AttachAdapter.instanceFor(_target).register(this);
    AttachAdapter.instanceFor(_target).update();
  }

  Map<String, String>? _attributes;
  set attributes(Map<String, String>? attrs) {
    if (_attributes == attrs) return;
    _attributes = attrs;
    AttachAdapter.instanceFor(_target).update();
  }

  int _depth;
  int get depth => _depth;
  set depth(int depth) {
    if (_depth == depth) return;
    _depth = depth;
    AttachAdapter.instanceFor(_target).update(needsResorting: true);
  }

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    child.parent = this;

    try {
      final childNode = child.node;

      var afterNode = after?.node;
      if (afterNode == null && children.contains(childNode)) {
        // Keep child in current place.
        return;
      }

      if (afterNode != null && !children.contains(afterNode)) {
        afterNode = null;
      }

      children.remove(childNode);
      children.insert(afterNode != null ? children.indexOf(afterNode) + 1 : 0, childNode);

      AttachAdapter.instanceFor(_target).update();
    } finally {
      child.finalize();
    }
  }

  @override
  void remove(DomRenderObject child) {
    children.remove(child.node);
    child.parent = null;

    AttachAdapter.instanceFor(_target).update();
  }
}

class AttachAdapter {
  AttachAdapter(this.target);

  static AttachAdapter instanceFor(AttachTarget target) {
    return _instances[target] ??= AttachAdapter(target);
  }

  static final Map<AttachTarget, AttachAdapter> _instances = {};

  final AttachTarget target;

  late final web.Element element = web.document.querySelector(target.name)!;

  late final Map<String, String> initialAttributes = element.attributes.toMap();

  late final (web.Node, web.Node) attachWindow = () {
    final iterator = web.document.createNodeIterator(element, 128);

    web.Node? start, end;

    web.Comment? currNode;
    while ((currNode = iterator.nextNode() as web.Comment?) != null) {
      final value = currNode!.nodeValue ?? '';
      if (value == r'$') {
        start = currNode;
      } else if (value == '/') {
        end = currNode;
      }
    }

    if (start == null) {
      start = web.Comment(r'$');
      element.insertBefore(start, end);
    }
    if (end == null) {
      end = web.Comment('/');
      element.insertBefore(end, start.nextSibling);
    }
    return (start, end);
  }();

  Iterable<web.Node> get liveNodes sync* {
    web.Node? curr = attachWindow.$1.nextSibling;
    while (curr != null && curr != attachWindow.$2) {
      yield curr;
      curr = curr.nextSibling;
    }
  }

  late final Map<String, web.Node> initialKeyedNodes = {
    for (var node in liveNodes)
      if (keyFor(node) case String key) key: node,
  };

  String? keyFor(web.Node node) {
    if (!node.isElement) return null;
    return switch (node as web.Element) {
      web.Element(id: final String id) when id.isNotEmpty => id,
      web.Element(tagName: 'TITLE' || 'BASE') => '__${node.tagName}',
      web.Element(tagName: 'META') => switch (node.attributes.getNamedItem('name')) {
        final web.Attr name => '__meta:${name.value}',
        _ => null,
      },
      _ => null,
    };
  }

  final List<AttachRenderObject> _renderObjects = [];
  List<AttachRenderObject> get renderObjects => _renderObjects;
  bool _needsResorting = true;

  void update({bool needsResorting = false}) {
    if (needsResorting || _needsResorting) {
      _renderObjects.sort((a, b) => a.depth - b.depth);
      _needsResorting = false;
    }

    if (target.attachAttributes) {
      final Map<String, String> attributes = initialAttributes;

      for (final renderObject in renderObjects) {
        assert(renderObject._target == target);
        if (renderObject._attributes case final attrs?) {
          attributes.addAll(attrs);
        }
      }

      final attributesToRemove = <String>{};
      for (var i = 0; i < element.attributes.length; i++) {
        attributesToRemove.add(element.attributes.item(i)!.name);
      }
      if (attributes.isNotEmpty) {
        for (final attr in attributes.entries) {
          element.clearOrSetAttribute(attr.key, attr.value);
          attributesToRemove.remove(attr.key);
        }
      }

      if (attributesToRemove.isNotEmpty) {
        for (final name in attributesToRemove) {
          element.removeAttribute(name);
        }
      }
    }

    if (target.attachChildren) {
      final Map<String, web.Node> keyedNodes = Map.of(initialKeyedNodes);
      final List<web.Node> children = List.of(initialKeyedNodes.values);

      for (final renderObject in renderObjects) {
        for (final node in renderObject.children) {
          final key = keyFor(node);
          if (key != null) {
            final shadowedNode = keyedNodes[key];
            keyedNodes[key] = node;
            if (shadowedNode != null) {
              children[children.indexOf(shadowedNode)] = node;
              continue;
            }
          }
          children.add(node);
        }
      }

      web.Node? current = attachWindow.$1.nextSibling;

      for (final node in children) {
        if (current == null || current == attachWindow.$2) {
          element.insertBefore(node, current);
        } else if (current == node) {
          current = current.nextSibling;
        } else if (keyFor(node) != null && keyFor(node) == keyFor(current)) {
          current.parentNode?.replaceChild(node, current);
          current = node.nextSibling;
        } else {
          element.insertBefore(node, current);
        }
      }

      while (current != null && current != attachWindow.$2) {
        final next = current.nextSibling;
        current.parentNode?.removeChild(current);
        current = next;
      }
    }
  }

  void register(AttachRenderObject renderObject) {
    _renderObjects.add(renderObject);
    _needsResorting = true;
  }

  void unregister(AttachRenderObject renderObject) {
    _renderObjects.remove(renderObject);
    update();
  }
}
