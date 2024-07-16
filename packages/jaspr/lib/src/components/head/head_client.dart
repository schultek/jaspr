import 'dart:html' as html;

import '../../../browser.dart';

class PlatformHead extends ProxyComponent {
  const PlatformHead({required super.children, super.key});

  @override
  Element createElement() => HeadElement(this);
}

class HeadElement extends ProxyRenderObjectElement {
  HeadElement(super.component);

  @override
  RenderObject createRenderObject() {
    return HeadRenderObject(depth);
  }

  @override
  void updateRenderObject() {}

  @override
  void activate() {
    super.activate();
    (renderObject as HeadRenderObject).depth = depth;
  }

  @override
  void detachRenderObject() {
    super.detachRenderObject();
    (renderObject as HeadRenderObject).unregister();
  }
}

class HeadAdapter {
  HeadAdapter._();

  static HeadAdapter instance = HeadAdapter._();

  static final html.HeadElement head = html.document.head!;

  static final (html.Node, html.Node) headBoundary = () {
    final iterator = html.NodeIterator(head, html.NodeFilter.SHOW_COMMENT);

    html.Node? start;
    html.Node? end;

    html.Comment? currNode;
    while ((currNode = iterator.nextNode() as html.Comment?) != null) {
      final value = currNode!.nodeValue ?? '';
      if (value == r'$') {
        start = currNode;
      } else if (value == '/') {
        end = currNode;
      }
    }

    if (start == null) {
      start = html.Comment(r'$');
      head.insertBefore(start, end);
    }
    if (end == null) {
      end = html.Comment('/');
      head.insertBefore(end, start.nextNode);
    }
    return (start, end);
  }();

  static Iterable<html.Node> get liveHeadNodes sync* {
    html.Node? curr = headBoundary.$1.nextNode;
    while (curr != null && curr != headBoundary.$2) {
      yield curr;
      curr = curr.nextNode;
    }
  }

  static final Map<String, html.Node> initialKeyedHeadNodes = {
    for (var node in liveHeadNodes)
      if (keyFor(node) case String key) key: node,
  };

  static String? keyFor(html.Node node) {
    return switch (node) {
      html.Element(id: final String id) when id.isNotEmpty => id,
      html.Element(tagName: 'TITLE' || 'BASE') => '__${node.tagName}',
      html.Element(tagName: 'META', attributes: {'name': final String name}) => '__meta:$name',
      _ => null,
    };
  }

  final List<HeadRenderObject> _headRenderObjects = [];
  bool _needsResorting = true;

  void update() {
    if (_needsResorting) {
      _headRenderObjects.sort((a, b) => a._depth - b._depth);
      _needsResorting = false;
    }

    final Map<String, html.Node> keyedNodes = Map.of(initialKeyedHeadNodes);
    final List<html.Node> children = List.of(initialKeyedHeadNodes.values);

    for (final renderObject in _headRenderObjects) {
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

    html.Node? current = headBoundary.$1.nextNode;

    for (final node in children) {
      if (current == null || current == headBoundary.$2) {
        head.insertBefore(node, current);
      } else if (current == node) {
        current = current.nextNode;
      } else if (keyFor(node) != null && keyFor(node) == keyFor(current)) {
        current.replaceWith(node);
        current = node.nextNode;
      } else {
        head.insertBefore(node, current);
      }
    }

    while (current != null && current != headBoundary.$2) {
      final next = current.nextNode;
      current.remove();
      current = next;
    }
  }

  void register(HeadRenderObject renderObject) {
    _headRenderObjects.add(renderObject);
    _needsResorting = true;
  }

  void unregister(HeadRenderObject renderObject) {
    _headRenderObjects.remove(renderObject);
    update();
  }
}

class HeadRenderObject extends DomRenderObject {
  HeadRenderObject(this._depth) {
    node = html.Text('');
    HeadAdapter.instance.register(this);
  }

  final List<html.Node> children = [];

  int _depth;
  int get depth => _depth;
  set depth(int depth) {
    if (_depth == depth) return;
    _depth = depth;
    HeadAdapter.instance._needsResorting = true;
    HeadAdapter.instance.update();
  }

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    try {
      final childNode = child.node;
      if (childNode == null) return;

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
      HeadAdapter.instance.update();
    } finally {
      child.finalize();
    }
  }

  @override
  void remove(DomRenderObject child) {
    super.remove(child);
    children.remove(child.node);
    HeadAdapter.instance.update();
  }

  void unregister() {
    HeadAdapter.instance.unregister(this);
  }
}
