import 'dart:html' as html;

import '../../../browser.dart';

class PlatformHead extends Component {
  const PlatformHead(this.children, {super.key});

  final List<Component> children;

  @override
  Element createElement() => HeadElement(this);
}

class HeadElement extends MultiChildRenderObjectElement {
  HeadElement(super.component);

  @override
  RenderObject createRenderObject() {
    return HeadRenderObject();
  }

  @override
  void updateRenderObject() {}

  @override
  Iterable<Component> build() {
    return (component as PlatformHead).children;
  }
}

class HeadRenderObject extends DomRenderObject {
  HeadRenderObject() {
    node = html.Text('');
    toHydrate = _headNodes;
  }

  static final html.HeadElement _head = html.document.head!;

  static final (html.Node, html.Node) _headBoundary = () {
    var iterator = html.NodeIterator(_head, html.NodeFilter.SHOW_COMMENT);

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
      _head.insertBefore(start, end);
    }
    if (end == null) {
      end = html.Comment('/');
      _head.insertBefore(end, start.nextNode);
    }
    return (start, end);
  }();

  static final List<html.Node> _headNodes = () {
    var nodes = <html.Node>[];
    html.Node? curr = _headBoundary.$1.nextNode;
    while (curr != null && curr != _headBoundary.$2) {
      nodes.add(curr);
      curr = curr.nextNode;
    }
    return nodes;
  }();

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    try {
      var childNode = child.node;
      if (childNode == null) return;

      var afterNode = after?.node;
      if (afterNode == null && childNode.parentNode == _head) {
        // Keep child in current place.
        return;
      }

      var beforeNode = afterNode?.nextNode;
      if (beforeNode == null || beforeNode.parentNode != _head) {
        beforeNode = _headBoundary.$2;
      }
      _head.insertBefore(childNode, beforeNode);
    } finally {
      child.finalize();
    }
  }

  @override
  void finalize() {
    html.window.requestAnimationFrame((highResTime) {
      super.finalize();
    });
  }
}
