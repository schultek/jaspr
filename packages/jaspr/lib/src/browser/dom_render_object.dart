import 'dart:async';
import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../foundation/constants.dart';
import '../foundation/events.dart';
import '../foundation/type_checks.dart';
import '../framework/framework.dart';
import 'utils.dart';

const htmlns = 'http://www.w3.org/1999/xhtml';
const xmlns = {
  'svg': 'http://www.w3.org/2000/svg',
  'math': 'http://www.w3.org/1998/Math/MathML',
};

abstract class DomRenderObject implements RenderObject {
  @override
  web.Node get node;

  @override
  DomRenderObject? parent;

  @override
  RenderElement createChildRenderElement(String tag) {
    return DomRenderElement(tag, this);
  }

  @override
  RenderText createChildRenderText(String text) {
    return DomRenderText(text, this);
  }

  @override
  RenderFragment createChildRenderFragment() {
    return DomRenderFragment()..parent = this;
  }

  web.Node? retakeNode(bool Function(web.Node node) visitNode);

  void attachChild(DomRenderObject child, web.Node? afterNode) {
    child.parent = this;

    if (child is DomRenderFragment && child.isAttached) {
      child.move(this, afterNode);
      return;
    }

    try {
      final childNode = child.node;
      if (childNode.previousSibling == afterNode && childNode.parentNode == node) {
        return;
      }

      if (kVerboseMode) {
        print("Attach node $childNode of $node after $afterNode");
      }

      if (afterNode == null) {
        node.insertBefore(childNode, node.childNodes.item(0));
      } else {
        node.insertBefore(childNode, afterNode.nextSibling);
      }

      assert(childNode.previousSibling == afterNode, 'Child node should have been placed after the specified node.');
    } finally {
      child.finalize();
    }
  }

  void removeChild(DomRenderObject child) {
    if (kVerboseMode) {
      print("Remove child $child of $this");
    }

    assert(node == child.node.parentNode, 'Child node must be a child of this element.');

    node.removeChild(child.node);
    child.parent = null;
  }

  void finalize();
}

mixin HydratableDomRenderObject on DomRenderObject {
  /// List of nodes that are not hydrated yet.
  /// These nodes will be removed when the render object is finalized.
  List<web.Node> toHydrate = [];

  @override
  web.Node? retakeNode(bool Function(web.Node node) visitNode) {
    if (toHydrate.isNotEmpty) {
      for (final e in toHydrate) {
        if (visitNode(e)) {
          toHydrate.remove(e);
          return e;
        }
      }
    }
    return null;
  }

  @override
  void finalize() {
    if (kVerboseMode && toHydrate.isNotEmpty) {
      print("Clear ${toHydrate.length} nodes not hydrated ($toHydrate)");
    }
    for (final node in toHydrate) {
      node.parentNode!.removeChild(node);
    }
    toHydrate.clear();
  }
}

class DomRenderElement extends DomRenderObject with HydratableDomRenderObject implements RenderElement {
  DomRenderElement(String tag, DomRenderObject parent) {
    this.parent = parent;
    _createNode(tag);
  }

  @override
  late final web.Element node;

  Map<String, EventBinding>? events;

  void _createNode(String tag) {
    var namespace = xmlns[tag];
    if (namespace == null && (parent?.node.isElement ?? false)) {
      namespace = (parent?.node as web.Element).namespaceURI;
    }

    final retakeNode = parent?.retakeNode((n) {
      return n.isElement && (n as web.Element).tagName.toLowerCase() == tag;
    });
    if (retakeNode != null) {
      if (kVerboseMode) {
        print("Hydrate html node: $retakeNode");
      }
      node = retakeNode as web.Element;

      toHydrate = retakeNode.childNodes.toIterable().toList();
      return;
    }

    node = _createElement(tag, namespace);
    if (kVerboseMode) {
      web.console.log("Create html node: $node".toJS);
    }
  }

  web.Element _createElement(String tag, String? namespace) {
    if (namespace != null && namespace != htmlns) {
      return web.document.createElementNS(namespace, tag);
    }
    return web.document.createElement(tag);
  }

  @override
  void update(String? id, String? classes, Map<String, String>? styles, Map<String, String>? attributes,
      Map<String, EventCallback>? events) {
    late Set<String> attributesToRemove;

    attributesToRemove = {};
    for (var i = 0; i < node.attributes.length; i++) {
      attributesToRemove.add(node.attributes.item(i)!.name);
    }

    node.clearOrSetAttribute('id', id);
    node.clearOrSetAttribute('class', classes == null || classes.isEmpty ? null : classes);
    node.clearOrSetAttribute('style',
        styles == null || styles.isEmpty ? null : styles.entries.map((e) => '${e.key}: ${e.value}').join('; '));

    if (attributes != null && attributes.isNotEmpty) {
      for (final attr in attributes.entries) {
        if (attr.key == 'value' && node.isHtmlInputElement && (node as web.HTMLInputElement).value != attr.value) {
          if (kVerboseMode) {
            print("Set input value: ${attr.value}");
          }
          (node as web.HTMLInputElement).value = attr.value;
          continue;
        }

        if (attr.key == 'value' && node.isHtmlSelectElement && (node as web.HTMLSelectElement).value != attr.value) {
          if (kVerboseMode) {
            print("Set select value: ${attr.value}");
          }
          (node as web.HTMLSelectElement).value = attr.value;
          continue;
        }

        node.clearOrSetAttribute(attr.key, attr.value);
      }
    }

    attributesToRemove.removeAll(['id', 'class', 'style', ...?attributes?.keys]);
    if (attributesToRemove.isNotEmpty) {
      for (final name in attributesToRemove) {
        node.removeAttribute(name);
        if (kVerboseMode) {
          print("Remove attribute: $name");
        }
      }
    }

    if (events != null && events.isNotEmpty) {
      final prevEventTypes = this.events?.keys.toSet();
      this.events ??= <String, EventBinding>{};
      final dataEvents = this.events!;
      events.forEach((type, fn) {
        prevEventTypes?.remove(type);
        final currentBinding = dataEvents[type];
        if (currentBinding != null) {
          currentBinding.fn = fn;
        } else {
          dataEvents[type] = EventBinding(node, type, fn);
        }
      });
      prevEventTypes?.forEach((type) {
        dataEvents.remove(type)?.clear();
      });
    } else {
      this.events?.forEach((type, binding) {
        binding.clear();
      });
      this.events = null;
    }
  }

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    attachChild(child, after?.node);
  }

  @override
  void remove(DomRenderObject child) {
    removeChild(child);
  }
}

class DomRenderText extends DomRenderObject implements RenderText {
  DomRenderText(String text, DomRenderObject? parent) {
    this.parent = parent;
    _createNode(text);
  }

  @override
  late final web.Text node;

  void _createNode(String text) {
    final retakeNode = parent?.retakeNode((n) {
      return n.isText;
    });

    if (retakeNode != null) {
      if (kVerboseMode) {
        print("Hydrate text node: $retakeNode");
      }
      node = retakeNode as web.Text;
      if (node.textContent != text) {
        node.textContent = text;
        if (kVerboseMode) {
          print("Update text node: $text");
        }
      }
      return;
    }

    node = web.Text(text);
    if (kVerboseMode) {
      print("Create text node: $text");
    }
  }

  @override
  void update(String text) {
    if (node.textContent != text) {
      node.textContent = text;
      if (kVerboseMode) {
        print("Update text node: $text");
      }
    }
  }

  @override
  void attach(covariant RenderObject child, {covariant RenderObject? after}) {
    throw UnsupportedError('Text nodes cannot have children attached to them.');
  }

  @override
  void remove(covariant RenderObject child) {
    throw UnsupportedError('Text nodes cannot have children removed from them.');
  }

  @override
  web.Node? retakeNode(bool Function(web.Node node) visitNode) {
    return null;
  }

  @override
  void finalize() {
    // noop
  }
}

class DomRenderFragment extends DomRenderObject with HydratableDomRenderObject implements RenderFragment {
  DomRenderFragment() : node = web.document.createDocumentFragment() {
    toHydrate = parent is HydratableDomRenderObject ? (parent as HydratableDomRenderObject).toHydrate : [];
  }

  @override
  final web.DocumentFragment node;
  bool isAttached = false;

  web.Node? firstChildNode;
  web.Node? lastChildNode;

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    try {
      child.parent = this;

      final parentNode = isAttached ? parent!.node : node;
      final childNode = child.node;

      assert(parentNode.isElement);

      final afterNode = after?.node ?? (isAttached ? firstChildNode?.previousSibling : null);

      if (childNode.previousSibling == afterNode && childNode.parentNode == parentNode) {
        return;
      }

      if (kVerboseMode) {
        print("Attach node $childNode of $parentNode after $afterNode");
      }

      if (afterNode == null) {
        parentNode.insertBefore(childNode, parentNode.childNodes.item(0));
      } else {
        parentNode.insertBefore(childNode, afterNode.nextSibling);
      }

      if (after?.node == null) {
        firstChildNode = childNode;
      }
      if (after?.node == lastChildNode) {
        lastChildNode = childNode;
      }
    } finally {
      child.finalize();
    }
  }

  void move(DomRenderObject parent, web.Node? afterNode) {
    assert(parent == this.parent, 'Cannot move fragment to a different parent.');
    assert(isAttached, 'Cannot move fragment that is not attached to a parent.');

    if (kVerboseMode) {
      print("Move fragment $this to $parent after $afterNode");
    }

    final parentNode = parent.node;

    if (firstChildNode == null) {
      // If fragment is empty, nothing to move.
      return;
    }

    assert(lastChildNode != null, 'Non-empty attached fragments must have a valid last node reference.');

    if (firstChildNode!.previousSibling == afterNode && firstChildNode!.parentNode == parentNode) {
      return;
    }

    web.Node? currentNode = lastChildNode;
    web.Node? beforeNode = afterNode == null ? parentNode.childNodes.item(0) : afterNode.nextSibling;

    // Move nodes in reverse order for efficient insertion.
    while (currentNode != null) {
      final prevNode = currentNode != firstChildNode ? currentNode.previousSibling : null;

      // Attach to new parent
      parentNode.insertBefore(currentNode, beforeNode);

      beforeNode = currentNode;
      currentNode = prevNode;
    }

    assert(firstChildNode!.previousSibling == afterNode,
        'First child node should have been placed after the specified node.');
  }

  @override
  void remove(DomRenderObject child) {
    if (kVerboseMode) {
      print("Remove child $child of $this");
    }

    final parentNode = isAttached ? parent!.node : node;
    assert(parentNode == child.node.parentNode, 'Child node must be a child of this fragment.');

    parentNode.removeChild(child.node);
    child.parent = null;
  }

  @override
  void finalize() {
    assert(node.childNodes.length == 0, 'Fragment should be empty after finalization.');
    isAttached = true;
  }
}

class RootDomRenderObject extends DomRenderObject with HydratableDomRenderObject {
  RootDomRenderObject(this.node, [List<web.Node>? nodes]) {
    toHydrate = [...nodes ?? node.childNodes.toIterable()];
    beforeStart = toHydrate.firstOrNull?.previousSibling;
  }

  factory RootDomRenderObject.between(web.Node start, web.Node end) {
    final nodes = <web.Node>[];
    web.Node? curr = start.nextSibling;
    while (curr != null && curr != end) {
      nodes.add(curr);
      curr = curr.nextSibling;
    }
    return RootDomRenderObject(start.parentElement!, nodes);
  }

  @override
  final web.Element node;
  late final web.Node? beforeStart;

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    attachChild(child, after?.node ?? beforeStart);
  }

  @override
  void remove(DomRenderObject child) {
    removeChild(child);
  }
}

typedef DomEventCallback = void Function(web.Event event);

class EventBinding {
  final String type;
  DomEventCallback fn;
  StreamSubscription? subscription;

  EventBinding(web.Element element, this.type, this.fn) {
    subscription = web.EventStreamProvider<web.Event>(type).forElement(element).listen((event) {
      fn(event);
    });
  }

  void clear() {
    subscription?.cancel();
    subscription = null;
  }
}

extension AttributeOperation on web.Element {
  void clearOrSetAttribute(String name, String? value) {
    if (value == null) {
      if (!hasAttribute(name)) return;
      if (kVerboseMode) {
        print("Remove attribute: $name");
      }
      removeAttribute(name);
    } else {
      if (getAttribute(name) == value) return;
      if (kVerboseMode) {
        print("Update attribute: $name - $value");
      }
      setAttribute(name, value);
    }
  }
}
