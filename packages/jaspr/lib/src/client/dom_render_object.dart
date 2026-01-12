import 'dart:async';
import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../dom/type_checks.dart';
import '../foundation/constants.dart';
import '../framework/framework.dart';
import 'utils.dart';

const _htmlns = 'http://www.w3.org/1999/xhtml';
const _xmlns = {'svg': 'http://www.w3.org/2000/svg', 'math': 'http://www.w3.org/1998/Math/MathML'};

abstract class DomRenderObject implements RenderObject {
  @override
  web.Node get node;

  @override
  DomRenderObject? parent;

  DomRenderObject? previousSibling;
  DomRenderObject? nextSibling;

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
    return DomRenderFragment(this);
  }

  web.Node? retakeNode(bool Function(web.Node node) visitNode);

  void finalize();
}

class DomRenderElement extends DomRenderObject
    with MultiChildDomRenderObject, HydratableDomRenderObject
    implements RenderElement {
  DomRenderElement(String tag, DomRenderObject parent) {
    this.parent = parent;
    _createNode(tag);
  }

  @override
  late final web.Element node;

  Map<String, EventBinding>? events;

  void _createNode(String tag) {
    var namespace = _xmlns[tag];
    if (namespace == null && (parent?.node.isElement ?? false)) {
      namespace = (parent?.node as web.Element).namespaceURI;
    }

    final retakeNode = parent?.retakeNode((n) {
      return n.isElement && (n as web.Element).tagName.toLowerCase() == tag;
    });
    if (retakeNode != null) {
      if (kVerboseMode) {
        print('Hydrate html node: $retakeNode');
      }
      node = retakeNode as web.Element;

      toHydrate = retakeNode.childNodes.toIterable().toList();
      return;
    }

    node = _createElement(tag, namespace);
    if (kVerboseMode) {
      web.console.log('Create html node: $node'.toJS);
    }
  }

  web.Element _createElement(String tag, String? namespace) {
    if (namespace != null && namespace != _htmlns) {
      return web.document.createElementNS(namespace, tag);
    }
    return web.document.createElement(tag);
  }

  @override
  void update(
    String? id,
    String? classes,
    Map<String, String>? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events,
  ) {
    final Set<String> originalAttributes = {
      for (var i = 0; i < node.attributes.length; i++) node.attributes.item(i)!.name,
    };

    node.clearOrSetAttribute('id', id);
    node.clearOrSetAttribute('class', classes == null || classes.isEmpty ? null : classes);
    node.clearOrSetAttribute(
      'style',
      styles == null || styles.isEmpty ? null : styles.entries.map((e) => '${e.key}: ${e.value}').join('; '),
    );

    if (attributes != null && attributes.isNotEmpty) {
      for (final MapEntry(key: attrName, value: attrValue) in attributes.entries) {
        if (attrName == 'value') {
          if (node.isHtmlSelectElement) {
            final nodeAsSelectElement = node as web.HTMLSelectElement;
            if (nodeAsSelectElement.value != attrValue) {
              if (kVerboseMode) {
                print('Set select value: $attrValue');
              }
              nodeAsSelectElement.value = attrValue;
            }
            continue;
          }

          if (node.isHtmlInputElement) {
            final nodeAsInputElement = node as web.HTMLInputElement;
            if (nodeAsInputElement.value != attrValue) {
              if (kVerboseMode) {
                print('Set input value: $attrValue');
              }
              nodeAsInputElement.value = attrValue;
            }
            continue;
          }
        } else if (attrName == 'checked') {
          if (node.isHtmlInputElement) {
            final nodeAsInputElement = node as web.HTMLInputElement;
            if (nodeAsInputElement.type case 'checkbox' || 'radio') {
              final shouldBeChecked = attrValue == 'true';
              if (nodeAsInputElement.checked != shouldBeChecked) {
                if (kVerboseMode) {
                  print('Set input checked: $shouldBeChecked');
                }
                nodeAsInputElement.checked = shouldBeChecked;
                if (!shouldBeChecked && node.hasAttribute('checked')) {
                  // Remove the attribute if unchecked to avoid HTML5 validation issues.
                  nodeAsInputElement.removeAttribute('checked');
                }
              }
              continue;
            }
          }
        } else if (attrName == 'indeterminate') {
          if (node.isHtmlInputElement) {
            final nodeAsInputElement = node as web.HTMLInputElement;
            if (nodeAsInputElement.type == 'checkbox') {
              final shouldBeIndeterminate = attrValue == 'true';
              if (nodeAsInputElement.indeterminate != shouldBeIndeterminate) {
                if (kVerboseMode) {
                  print('Set input indeterminate: $shouldBeIndeterminate');
                }
                nodeAsInputElement.indeterminate = shouldBeIndeterminate;
                if (!shouldBeIndeterminate && node.hasAttribute('indeterminate')) {
                  // Remove the attribute if unchecked to avoid HTML5 validation issues.
                  nodeAsInputElement.removeAttribute('indeterminate');
                }
              }
              continue;
            }
          }
        }

        node.clearOrSetAttribute(attrName, attrValue);
      }
    }

    final attributesToRemove = originalAttributes.difference({'id', 'class', 'style', ...?attributes?.keys});
    for (final name in attributesToRemove) {
      node.removeAttribute(name);
      if (kVerboseMode) {
        print('Removed attribute: $name');
      }
    }

    if (events != null && events.isNotEmpty) {
      final dataEvents = this.events ??= <String, EventBinding>{};
      final prevEventTypes = dataEvents.keys.toSet();
      events.forEach((type, fn) {
        prevEventTypes.remove(type);
        final currentBinding = dataEvents[type];
        if (currentBinding != null) {
          currentBinding.fn = fn;
        } else {
          dataEvents[type] = EventBinding(node, type, fn);
        }
      });
      for (final type in prevEventTypes) {
        dataEvents.remove(type)?.clear();
      }
    } else {
      if (this.events case final existingEvents?) {
        for (final binding in existingEvents.values) {
          binding.clear();
        }
        this.events = null;
      }
    }
  }

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    attachChild(child, after);
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
        print('Hydrate text node: $retakeNode');
      }
      node = retakeNode as web.Text;
      if (node.textContent != text) {
        node.textContent = text;
        if (kVerboseMode) {
          print('Update text node: $text');
        }
      }
      return;
    }

    node = web.Text(text);
    if (kVerboseMode) {
      print('Create text node: $text');
    }
  }

  @override
  void update(String text) {
    if (node.textContent != text) {
      node.textContent = text;
      if (kVerboseMode) {
        print('Update text node: $text');
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

class DomRenderFragment extends DomRenderObject
    with MultiChildDomRenderObject, HydratableDomRenderObject
    implements RenderFragment {
  DomRenderFragment(DomRenderObject? parent, [List<web.Node>? toHydrate])
    : node = web.document.createDocumentFragment() {
    this.parent = parent;
    this.toHydrate = toHydrate ?? (parent is HydratableDomRenderObject ? parent.toHydrate : []);
  }

  DomRenderFragment.from(this.node, DomRenderObject? parent) {
    this.parent = parent;
    toHydrate = [...node.childNodes.toIterable()];
  }

  @override
  final web.DocumentFragment node;
  bool isAttached = false;

  DomRenderObject? _firstChild;
  DomRenderObject? _lastChild;

  web.Node? get firstChildNode {
    if (_firstChild case final firstChild?) {
      if (firstChild is DomRenderFragment) {
        return firstChild.lastChildNode;
      }

      return firstChild.node;
    }

    return null;
  }

  web.Node? get lastChildNode {
    if (_lastChild case final lastChild?) {
      if (lastChild is DomRenderFragment) {
        return lastChild.lastChildNode;
      }

      return lastChild.node;
    }

    return null;
  }

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    attachChild(child, after, startNode: firstChildNode?.previousSibling);

    if (after == null) {
      _firstChild = child;
    }
    if (after == _lastChild) {
      _lastChild = child;
    }
  }

  void move(DomRenderObject parent, web.Node targetNode, web.Node? afterNode) {
    assert(parent == this.parent, 'Cannot move fragment to a different parent.');
    assert(isAttached, 'Cannot move fragment that is not attached to a parent.');

    if (kVerboseMode) {
      print('Move fragment to $targetNode after $afterNode');
    }

    final originalFirstChildNode = firstChildNode;
    if (originalFirstChildNode == null) {
      // If fragment is empty, nothing to move.
      return;
    }

    assert(lastChildNode != null, 'Non-empty attached fragments must have a valid last child reference.');

    if (originalFirstChildNode.previousSibling == afterNode && originalFirstChildNode.parentNode == targetNode) {
      return;
    }

    web.Node? currentNode = lastChildNode;
    web.Node? beforeNode = afterNode == null ? targetNode.childNodes.item(0) : afterNode.nextSibling;

    // Move nodes in reverse order for efficient insertion.
    while (currentNode != null) {
      final prevNode = currentNode != firstChildNode ? currentNode.previousSibling : null;

      // Attach to new parent.
      targetNode.insertBefore(currentNode, beforeNode);

      beforeNode = currentNode;
      currentNode = prevNode;
    }

    assert(
      firstChildNode!.previousSibling == afterNode,
      'First child node should have been placed after the specified node.',
    );
  }

  void removeChildren(DomRenderObject parent) {
    assert(parent == this.parent, 'Cannot remove fragment from a different parent.');
    assert(isAttached, 'Cannot remove fragment that is not attached to a parent.');

    if (kVerboseMode) {
      print('Remove fragment $node from ${parent.node}');
    }

    if (firstChildNode == null) {
      // If fragment is empty, nothing to remove.
      return;
    }

    assert(lastChildNode != null, 'Non-empty attached fragments must have a valid last child reference.');

    web.Node? currentNode = lastChildNode;
    web.Node? beforeNode;

    while (currentNode != null) {
      final prevNode = currentNode != firstChildNode ? currentNode.previousSibling : null;

      assert(currentNode.parentNode == parent.node, 'Fragment child must be a child of the parent.');

      // Remove from parent, attach back to fragment.
      node.insertBefore(currentNode, beforeNode);

      beforeNode = currentNode;
      currentNode = prevNode;
    }

    assert(
      firstChildNode == node.childNodes.item(0),
      'First child node should be the first child of the fragment.',
    );
    assert(
      lastChildNode == node.childNodes.item(node.childNodes.length - 1),
      'Last child node should be the last child of the fragment.',
    );

    isAttached = false;
  }

  @override
  void remove(DomRenderObject child) {
    if (!isAttached) {
      removeChild(child);
    } else {
      parent!.remove(child);
    }
  }

  @override
  void finalize() {
    assert(node.childNodes.length == 0, 'Fragment should be empty after finalization.');
    isAttached = true;
  }
}

class RootDomRenderObject extends DomRenderObject with MultiChildDomRenderObject, HydratableDomRenderObject {
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
    attachChild(child, after, startNode: beforeStart);
  }

  @override
  void remove(DomRenderObject child) {
    removeChild(child);
  }
}

mixin MultiChildDomRenderObject on DomRenderObject {
  web.Node get attachTargetNode {
    if (this case DomRenderFragment(isAttached: true)) {
      return (parent as MultiChildDomRenderObject).attachTargetNode;
    }
    return node;
  }

  web.Node? getRealNodeOf(DomRenderObject? after) {
    if (after is DomRenderFragment) {
      if (after.lastChildNode case final node?) {
        return node;
      } else {
        return getRealNodeOf(after.previousSibling);
      }
    }
    if (after != null) {
      return after.node;
    }
    if (this case DomRenderFragment(isAttached: true)) {
      return (parent as MultiChildDomRenderObject).getRealNodeOf(previousSibling);
    }
    return null;
  }

  void attachChild(DomRenderObject child, DomRenderObject? after, {web.Node? startNode}) {
    child.parent = this;

    final targetNode = attachTargetNode;
    final afterNode = getRealNodeOf(after) ?? startNode;

    if (child case DomRenderFragment(isAttached: true)) {
      child.move(this, targetNode, afterNode);
      return;
    }

    try {
      final childNode = child.node;
      if (childNode.previousSibling == afterNode && childNode.parentNode == targetNode) {
        return;
      }

      if (kVerboseMode) {
        print('Attach node $childNode to $targetNode after $afterNode ($after)');
      }

      if (afterNode == null) {
        targetNode.insertBefore(childNode, targetNode.childNodes.item(0));
      } else {
        targetNode.insertBefore(childNode, afterNode.nextSibling);
      }

      if (child is! DomRenderFragment) {
        assert(
          childNode.previousSibling == afterNode,
          'Child node should have been placed after the specified node.',
        );
      } else if (child.firstChildNode != null) {
        assert(
          child.firstChildNode?.previousSibling == afterNode,
          'Fragment first child should have been placed after the specified node.',
        );
      }

      final next = after?.nextSibling;
      child.previousSibling = after;
      after?.nextSibling = child;
      child.nextSibling = next;
      next?.previousSibling = child;
    } finally {
      child.finalize();
    }
  }

  void removeChild(DomRenderObject child) {
    if (child case DomRenderFragment(isAttached: true)) {
      child.removeChildren(this);
      child.parent = null;
      return;
    }

    if (kVerboseMode) {
      print('Remove child ${child.node} of $node');
    }

    assert(node == child.node.parentNode, 'Child node must be a child of this element.');

    node.removeChild(child.node);
    child.parent = null;
  }
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
      print('Clear ${toHydrate.length} nodes not hydrated ($toHydrate)');
    }
    for (final node in toHydrate) {
      node.parentNode!.removeChild(node);
    }
    toHydrate.clear();
  }
}

typedef DomEventCallback = void Function(web.Event event);

class EventBinding {
  final String type;
  DomEventCallback fn;
  StreamSubscription<web.Event>? _subscription;

  EventBinding(web.Element element, this.type, this.fn) {
    _subscription = web.EventStreamProvider<web.Event>(type).forElement(element).listen((event) {
      // Do not move to a field initializer: we need fn here to refer to the
      // field and not the constructor parameter.
      fn(event);
    });
  }

  void clear() {
    _subscription?.cancel();
    _subscription = null;
  }
}

extension AttributeOperation on web.Element {
  void clearOrSetAttribute(String name, String? value) {
    if (value == null) {
      if (!hasAttribute(name)) return;
      if (kVerboseMode) {
        print('Remove attribute: $name');
      }
      removeAttribute(name);
    } else {
      if (getAttribute(name) == value) return;
      if (kVerboseMode) {
        print('Update attribute: $name - $value');
      }
      setAttribute(name, value);
    }
  }
}
