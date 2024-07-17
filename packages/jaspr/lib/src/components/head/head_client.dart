import 'dart:html' as html;

import '../../../browser.dart';
import '../attach/attach_client.dart';

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
    HeadAdapter.instance.unregister(renderObject as HeadRenderObject);
  }
}

class HeadRenderObject extends DomRenderObject with AttachRenderObjectMixin {
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
    HeadAdapter.instance.update(needsResorting: true);
  }

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    try {
      var childNode = child.node;
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
}

class HeadAdapter with AttachAdapterMixin<HeadRenderObject> {
  HeadAdapter();

  static HeadAdapter instance = HeadAdapter();

  final html.HeadElement head = html.document.head!;

  late final (html.Node, html.Node) headBoundary = () {
    var iterator = html.NodeIterator(head, html.NodeFilter.SHOW_COMMENT);

    html.Node? start, end;

    html.Comment? currNode;
    while ((currNode = iterator.nextNode() as html.Comment?) != null) {
      var value = currNode!.nodeValue ?? '';
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

  Iterable<html.Node> get liveHeadNodes sync* {
    html.Node? curr = headBoundary.$1.nextNode;
    while (curr != null && curr != headBoundary.$2) {
      yield curr;
      curr = curr.nextNode;
    }
  }

  late final Map<String, html.Node> initialKeyedHeadNodes = {
    for (var node in liveHeadNodes)
      if (keyFor(node) case String key) key: node,
  };

  String? keyFor(html.Node node) {
    return switch (node) {
      html.Element(id: String id) when id.isNotEmpty => id,
      html.Element(tagName: "TITLE" || "BASE") => '__${node.tagName}',
      html.Element(tagName: "META", attributes: {'name': String name}) => '__meta:$name',
      _ => null,
    };
  }

  void performUpdate() {
    Map<String, html.Node> keyedNodes = Map.of(initialKeyedHeadNodes);
    List<html.Node> children = List.of(initialKeyedHeadNodes.values);

    for (var renderObject in renderObjects) {
      for (var node in renderObject.children) {
        var key = keyFor(node);
        if (key != null) {
          var shadowedNode = keyedNodes[key];
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

    for (var node in children) {
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
      var next = current.nextNode;
      current.remove();
      current = next;
    }
  }
}
