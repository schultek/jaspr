import 'package:universal_web/web.dart' as web;

import '../dom/type_checks.dart';
import '../framework/framework.dart';
import 'dom_render_object.dart';
import 'utils.dart';

/// A slot that attaches a child component to a specific DOM node within
/// a [SlottedChildView].
abstract class ChildSlot extends Component {
  const ChildSlot();

  factory ChildSlot.fromQuery(String query, {required Component child}) = QueryChildSlot;

  Component get child;

  ChildSlotRenderObject createRenderObject(SlottedDomRenderObject parent);
  bool canUpdate(ChildSlot oldComponent);

  @override
  Element createElement() => ChildSlotElement(this);
}

/// A [ChildSlot] that attaches its child to the first DOM element matching
/// the given CSS [query].
class QueryChildSlot extends ChildSlot {
  QueryChildSlot(this.query, {required this.child});

  final String query;
  @override
  final Component child;

  @override
  ChildSlotRenderObject createRenderObject(SlottedDomRenderObject parent) {
    web.Element? target;
    web.Node? current = parent.firstChildNode;
    while (current != null) {
      if (current.isElement) {
        target = (current as web.Element).querySelector(query);
        if (target != null) {
          break;
        }
      }
      if (current == parent.lastChildNode) {
        break;
      }
      current = current.nextSibling;
    }
    assert(target != null, 'No node found for query "$query" in ChildSlot.');
    return ChildSlotRenderObject(target!, parent);
  }

  @override
  bool canUpdate(ChildSlot oldComponent) {
    return oldComponent is QueryChildSlot && oldComponent.query == query;
  }
}

class ChildSlotElement extends MultiChildRenderObjectElement {
  ChildSlotElement(ChildSlot super.component);

  @override
  void update(ChildSlot newComponent) {
    assert(
      newComponent.canUpdate(component as ChildSlot),
      'ChildSlot cannot be updated with a different slot.',
    );
    super.update(newComponent);
  }

  @override
  List<Component> buildChildren() {
    return [
      (component as ChildSlot).child,
    ];
  }

  @override
  ChildSlotRenderObject createRenderObject() {
    final slot = component as ChildSlot;
    final parent = parentRenderObjectElement!.renderObject as SlottedDomRenderObject;
    return slot.createRenderObject(parent);
  }

  @override
  void updateRenderObject(RenderObject renderObject) {}
}

/// Component that renders its children into specified DOM nodes (slots).
///
/// Child components are mounted as direct children of this component, but may target
/// specific nested DOM nodes within the component's DOM subtree. This allows for hydrating
/// only specific parts of the DOM tree while having a single coherent component tree.
class SlottedChildView extends Component {
  SlottedChildView({required this.slots, super.key}) : nodes = null;

  // ignore: unused_element - for future use by server components.
  SlottedChildView._withNodes({required List<web.Node> this.nodes, required this.slots});

  final List<web.Node>? nodes;
  final List<ChildSlot> slots;

  @override
  Element createElement() => SlottedChildViewElement(this);
}

class SlottedChildViewElement extends MultiChildRenderObjectElement {
  SlottedChildViewElement(SlottedChildView super.component);

  @override
  SlottedChildView get component => super.component as SlottedChildView;

  @override
  void update(SlottedChildView newComponent) {
    assert(
      newComponent.nodes == component.nodes,
      'SlottedChildView cannot be updated with different nodes.',
    );
    super.update(newComponent);
  }

  @override
  List<Component> buildChildren() {
    return component.slots;
  }

  @override
  RenderObject createRenderObject() {
    final parent = parentRenderObjectElement!.renderObject;
    return SlottedDomRenderObject.fromNodes(component.nodes, parent as DomRenderObject);
  }

  @override
  void updateRenderObject(RenderObject renderObject) {}

  @override
  void unmount() {
    super.unmount();
    _clearEventListeners(this);
  }

  static void _clearEventListeners(Element e) {
    if (e case RenderObjectElement(renderObject: final DomRenderElement r)) {
      r.events?.forEach((type, binding) {
        binding.clear();
      });
      r.events = null;
    }

    e.visitChildren(_clearEventListeners);
  }
}

class SlottedDomRenderObject extends DomRenderFragment {
  SlottedDomRenderObject._(
    DomRenderObject? parent, {
    this.firstChildNode,
    this.lastChildNode,
  }) : super(parent, []);

  factory SlottedDomRenderObject.fromNodes(List<web.Node>? nodes, DomRenderObject? parent) {
    final nodesToAdd = nodes ?? [if (parent is HydratableDomRenderObject) ...parent.toHydrate];

    if (nodesToAdd.isEmpty) {
      return SlottedDomRenderObject._(parent)..isAttached = true;
    }

    final firstNode = nodesToAdd.first;
    final lastNode = nodesToAdd.last;
    assert(firstNode.parentNode == lastNode.parentNode, 'All nodes must share the same parent.');
    final object = SlottedDomRenderObject._(parent, firstChildNode: firstNode, lastChildNode: lastNode);
    if (parent != null && parent.node.contains(firstNode)) {
      if (parent is HydratableDomRenderObject) {
        final startIndex = parent.toHydrate.indexOf(firstNode);
        final endIndex = parent.toHydrate.indexOf(lastNode);
        if (startIndex != -1 && endIndex != -1 && startIndex <= endIndex) {
          parent.toHydrate.removeRange(startIndex, endIndex + 1);
        }
      }
      object.isAttached = true;
    } else {
      for (final node in nodesToAdd) {
        object.node.appendChild(node);
      }
    }
    return object;
  }

  @override
  final web.Node? firstChildNode;

  @override
  final web.Node? lastChildNode;

  @override
  void attach(covariant RenderObject child, {covariant RenderObject? after}) {
    if (child is ChildSlotRenderObject) {
      assert(
        isAttached ? parent!.node.contains(child.node) : node.contains(child.node),
        'Cannot attach a child that is not already part of the component fragment.',
      );
      child.parent = this;
      child.finalize();
      return;
    }
    throw UnsupportedError('SlottedDomRenderObject cannot have children attached to them.');
  }

  @override
  void remove(covariant RenderObject child) {
    throw UnsupportedError('SlottedDomRenderObject cannot have children removed from them.');
  }
}

class ChildSlotRenderObject extends DomRenderObject with MultiChildDomRenderObject, HydratableDomRenderObject {
  ChildSlotRenderObject(this.node, SlottedDomRenderObject parent, [List<web.Node>? nodes]) {
    this.parent = parent;
    toHydrate = [...nodes ?? node.childNodes.toIterable()];
    beforeStart = toHydrate.firstOrNull?.previousSibling;
  }

  factory ChildSlotRenderObject.between(SlottedDomRenderObject parent, web.Node start, web.Node end) {
    final nodes = <web.Node>[];
    web.Node? curr = start.nextSibling;
    while (curr != null && curr != end) {
      nodes.add(curr);
      curr = curr.nextSibling;
    }
    return ChildSlotRenderObject(start.parentElement!, parent, nodes);
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
