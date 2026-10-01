import 'package:universal_web/web.dart' as web;

import '../dom/type_checks.dart';
import '../framework/framework.dart';
import 'dom_render_object.dart';
import 'utils.dart';

/// A slot that attaches a child component to a specific DOM node within
/// a [SlottedChildView].
abstract class ChildSlot extends Component {
  const ChildSlot({super.key});

  factory ChildSlot.fromQuery(String query, {required Component child, Key? key}) = QueryChildSlot;

  factory ChildSlot.between({required web.Node start, required web.Node end, required Component child, Key? key}) =
      RangeChildSlot;

  Component get child;

  ChildSlotRenderObject createRenderObject(SlottedDomRenderObject parent);
  bool canUpdate(ChildSlot oldComponent);

  @override
  Element createElement() => ChildSlotElement(this);
}

/// A [ChildSlot] that attaches its child between two given DOM [start] and [end] nodes.
class RangeChildSlot extends ChildSlot {
  const RangeChildSlot({required this.start, required this.end, required this.child, super.key});

  final web.Node start;
  final web.Node end;
  @override
  final Component child;

  @override
  ChildSlotRenderObject createRenderObject(SlottedDomRenderObject parent) {
    return ChildSlotRenderObject.between(parent, start, end);
  }

  @override
  bool canUpdate(ChildSlot oldComponent) {
    return oldComponent is RangeChildSlot && oldComponent.start == start && oldComponent.end == end;
  }
}

/// A [ChildSlot] that attaches its child to the first DOM element matching
/// the given CSS [query].
///
/// The query is resolved when the slot mounts and can match inherited DOM params.
/// Updates keep the resolved element, even if it no longer matches the query.
class QueryChildSlot extends ChildSlot {
  const QueryChildSlot(this.query, {required this.child, super.key});

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
    final parent = parentRenderObjectElement;
    assert(
      parent is SlottedChildViewElement,
      'ChildSlot must be used as a direct child of SlottedChildView.',
    );
    return (parent as SlottedChildViewElement)._createSlotRenderObject(component as ChildSlot);
  }

  @override
  void updateRenderObject(RenderObject renderObject) {}

  @override
  void unmount() {
    super.unmount();
    // The slot's DOM stays in place, so remove the listeners its child added.
    // Otherwise they would keep firing alongside any params the view applies to
    // the leftover elements after this slot is removed.
    _clearEventListeners(this);
  }
}

/// Removes the event listeners of all DOM render objects in the subtree of [e].
void _clearEventListeners(Element e) {
  if (e case RenderObjectElement(renderObject: final DomRenderElement r)) {
    r.events?.forEach((type, binding) {
      binding.clear();
    });
    r.events = null;
  }

  e.visitChildren(_clearEventListeners);
}

/// Component that renders its children into specified DOM nodes (slots).
///
/// Child components are mounted as direct children of this component, but may target
/// specific nested DOM nodes within the component's DOM subtree. This allows for hydrating
/// only specific parts of the DOM tree while having a single coherent component tree.
class SlottedChildView extends Component {
  SlottedChildView({required this.slots, super.key}) : nodes = null;

  SlottedChildView.withNodes({required List<web.Node> this.nodes, required this.slots, super.key});

  final List<web.Node>? nodes;
  final List<ChildSlot> slots;

  @override
  Element createElement() => SlottedChildViewElement(this);
}

class SlottedChildViewElement extends DomRenderObjectElement {
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
    final parentResolver = inheritedDomResolver;
    if (parentResolver == null) {
      return buildOwnChildren();
    }

    final parentDomNode = SlottedDomRenderObject._realNodeOf(
      (renderObject as SlottedDomRenderObject).parent!,
    );

    List<ApplyParams> getParams(RenderObject target) {
      final parentParams = parentResolver(target);
      if (parentParams.isEmpty) return const [];

      if (!parentParams.any((p) => p.target.onlyChildren)) {
        return parentParams;
      }

      // Find ChildSlotRenderObject in target's ancestor chain
      ChildSlotRenderObject? slotRenderObject;
      RenderObject? current = target;
      while (current != null && current != renderObject) {
        if (current is ChildSlotRenderObject) {
          slotRenderObject = current;
          break;
        }
        current = current.parent;
      }

      if (slotRenderObject != null && slotRenderObject.node == parentDomNode) {
        // Direct child slot -> allow all params including onlyChildren: true
        return parentParams;
      } else {
        // Nested slot -> allow only descendant params
        return parentParams.where((p) => !p.target.onlyChildren).toList();
      }
    }

    return [
      for (final slot in buildOwnChildren())
        wrapWithInheritedDomComponent(
          getParams: getParams,
          child: slot,
        ),
    ];
  }

  @override
  List<Component> buildOwnChildren() {
    return component.slots;
  }

  @override
  RenderObject createRenderObject() {
    final parent = parentRenderObjectElement!.renderObject;
    final renderObject = SlottedDomRenderObject.fromNodes(component.nodes, parent as DomRenderObject);
    // The new nodes, such as on mount or reload, don't have the params applied yet.
    markNeedsRender();
    return renderObject;
  }

  /// The params this view applied to the elements it owns.
  final Map<web.HTMLElement, _AppliedParams> _appliedParams = nodeMap();

  /// Whether the inherited params changed since they were last applied.
  ///
  /// This is also set when a new render object is created, before its slots are.
  bool _paramsChanged = false;

  @override
  void markNeedsRender() {
    super.markNeedsRender();
    _paramsChanged = true;
  }

  /// Creates the render object of [slot] and hands it the elements it owns.
  ChildSlotRenderObject _createSlotRenderObject(ChildSlot slot) {
    // The view normally applies changed params after rebuilding its slots,
    // but a query must be able to match them, so apply them first.
    if (_paramsChanged && slot is! RangeChildSlot) {
      updateRenderObject(renderObject as SlottedDomRenderObject);
    }
    final slotRenderObject = slot.createRenderObject(renderObject as SlottedDomRenderObject);
    // Resolve the target before removing any values its query could match.
    // Release only the nodes being handed over, before the child hydrates them.
    _releaseParams(slotRenderObject);
    return slotRenderObject;
  }

  /// Applies the inherited params to the elements owned by this view.
  ///
  /// This view owns all elements outside of its attached slots, at any depth.
  /// Elements inside a slot are owned by the slot's child,
  /// which applies the inherited params to its own elements,
  /// so this view never modifies them.
  @override
  void updateRenderObject(SlottedDomRenderObject renderObject) {
    _paramsChanged = false;
    _resetAppliedParams();

    final params = inheritedDomParamsFor(renderObject)?.reversed.toList(growable: false);
    if (params == null || params.isEmpty) return;

    _visitOwnedElements(
      renderObject,
      descendants: params.any((p) => !p.target.onlyChildren),
      (element, isRoot) {
        for (final param in params) {
          if ((isRoot || !param.target.onlyChildren) && _isMatchingElement(param.target, element)) {
            _updateElementParams(element, param);
          }
        }
      },
    );
  }

  /// Calls [visit] for each element owned by this view, in document order.
  ///
  /// The callback's `isRoot` argument is `true` for
  /// elements that are direct children of the view.
  /// Their descendants are only visited if [descendants] is `true`.
  void _visitOwnedElements(
    SlottedDomRenderObject renderObject,
    void Function(web.HTMLElement element, bool isRoot) visit, {
    required bool descendants,
  }) {
    // The start and end nodes of range slots, and the elements whose children are slotted.
    final slotRanges = nodeMap<web.Node, web.Node>();
    final slottedParents = nodeSet<web.Node>();
    for (final slot in renderObject._slots) {
      if (slot._range case (:final start, :final end)) {
        slotRanges[start] = end;
      } else {
        slottedParents.add(slot.node);
      }
    }

    // Lookups hash the node even if a collection is empty, so skip those.
    final hasSlotRanges = slotRanges.isNotEmpty;
    final hasSlottedParents = slottedParents.isNotEmpty;

    void visitSiblings(web.Node? current, web.Node? last, {required bool isRoot}) {
      while (current != null) {
        final slotEnd = hasSlotRanges ? slotRanges[current] : null;
        if (slotEnd != null) {
          if (current == last) break;
          // Skip the nodes owned by the slot.
          current = slotEnd;
          // The end of this slot can be the start of an adjacent slot.
          if (slotRanges.containsKey(current)) continue;
        } else if (current.isElement) {
          visit(current as web.HTMLElement, isRoot);
          if (descendants && !(hasSlottedParents && slottedParents.contains(current))) {
            visitSiblings(current.firstChild, null, isRoot: false);
          }
        }

        if (current == last) break;
        current = current.nextSibling;
      }
    }

    visitSiblings(renderObject.firstChildNode, renderObject.lastChildNode, isRoot: true);
  }

  bool _isMatchingElement(ApplyTarget target, web.Element element) {
    if (target.tag case final expectedTag? when element.localName != expectedTag) return false;
    if (target.id case final expectedId? when element.id != expectedId) return false;
    if (target.classes case final expectedClasses? when !expectedClasses.every((c) => element.classList.contains(c))) {
      return false;
    }

    return true;
  }

  /// Releases our params on the elements owned by [slot] to its child.
  ///
  /// Reset and forget them before the slot's child hydrates,
  /// so a nested view doesn't treat inherited values as original DOM values.
  void _releaseParams(ChildSlotRenderObject slot) {
    if (slot.toHydrate.isEmpty || _appliedParams.isEmpty) return;

    _appliedParams.removeWhere((element, params) {
      if (!slot._owns(element)) return false;
      _resetElementParams(element, params);
      return true;
    });
  }

  void _resetAppliedParams() {
    _appliedParams.forEach(_resetElementParams);
    _appliedParams.clear();
  }

  void _resetElementParams(web.HTMLElement element, _AppliedParams params) {
    // Remove attributes left empty, rather than leaving behind attributes
    // such as `id=""` that the element didn't have before.
    if (params.id != null && element.id == params.id) {
      element.removeAttribute('id');
    }

    if (params.classes case final appliedClasses? when appliedClasses.isNotEmpty) {
      for (final c in appliedClasses) {
        element.classList.remove(c);
      }
      if (element.classList.length == 0) {
        element.removeAttribute('class');
      }
    }

    if (params.styles case final appliedStyles? when appliedStyles.isNotEmpty) {
      for (final e in appliedStyles.entries) {
        element.style.removeProperty(e.key);
      }
      if (element.style.length == 0) {
        // Read the attribute first, so the browser syncs the pending style changes into it.
        // Otherwise, it can sync them afterwards and add back an empty `style` attribute.
        element.getAttribute('style');
        element.removeAttribute('style');
      }
    }

    if (params.attributes case final appliedAttributes?) {
      for (final e in appliedAttributes.entries) {
        element.removeAttribute(e.key);
      }
    }

    if (params.eventBindings case final appliedEvents?) {
      for (final binding in appliedEvents.values) {
        binding.clear();
      }
    }
  }

  void _updateElementParams(web.HTMLElement element, ApplyParams newParams) {
    final params = _appliedParams[element];

    String? appliedId = params?.id;
    List<String>? appliedClasses = params?.classes;
    Map<String, String>? appliedStyles = params?.styles;
    Map<String, String>? appliedAttributes = params?.attributes;
    Map<String, EventBinding>? appliedEvents = params?.eventBindings;

    if (newParams.id case final newId?) {
      if (element.id.isEmpty) {
        element.id = newId;
        appliedId = newId;
      }
    }

    if (newParams.classes case final newClasses?) {
      appliedClasses ??= [];
      for (final c in newClasses) {
        if (!element.classList.contains(c)) {
          element.classList.add(c);
          appliedClasses.add(c);
        }
      }
    }

    if (newParams.styles case final newStyles?) {
      appliedStyles ??= {};
      for (final e in newStyles.entries) {
        if (element.style.getPropertyValue(e.key).isEmpty) {
          element.style.setProperty(e.key, e.value);
          appliedStyles[e.key] = e.value;
        }
      }
    }

    if (newParams.attributes case final newAttributes?) {
      appliedAttributes ??= {};
      for (final e in newAttributes.entries) {
        if (!element.hasAttribute(e.key)) {
          element.setAttribute(e.key, e.value);
          appliedAttributes[e.key] = e.value;
        }
      }
    }

    if (newParams.events case final newEvents?) {
      appliedEvents ??= {};
      for (final e in newEvents.entries) {
        if (!appliedEvents.containsKey(e.key)) {
          appliedEvents[e.key] = EventBinding(element, e.key, e.value);
        }
      }
    }

    _appliedParams[element] = _AppliedParams(
      target: newParams.target,
      id: appliedId,
      classes: appliedClasses,
      styles: appliedStyles,
      attributes: appliedAttributes,
      events: appliedEvents,
    );
  }

  @override
  void unmount() {
    // Each slot clears the listeners of its own subtree when it unmounts.
    _resetAppliedParams();
    super.unmount();
  }
}

class _AppliedParams extends ApplyParams {
  _AppliedParams({
    required super.target,
    super.id,
    super.classes,
    super.styles,
    super.attributes,
    Map<String, EventBinding>? events,
  }) : eventBindings = events;

  final Map<String, EventBinding>? eventBindings;
}

class SlottedDomRenderObject extends DomRenderFragment {
  SlottedDomRenderObject._(DomRenderObject parent, {this.firstChildNode, this.lastChildNode}) : super(parent, []);

  factory SlottedDomRenderObject.fromNodes(List<web.Node>? nodes, DomRenderObject parent) {
    final nodesToAdd = nodes ?? [if (parent is HydratableDomRenderObject) ...parent.toHydrate];

    if (nodesToAdd.isEmpty) {
      return SlottedDomRenderObject._(parent)..isAttached = true;
    }

    final firstNode = nodesToAdd.first;
    final lastNode = nodesToAdd.last;
    assert(firstNode.parentNode == lastNode.parentNode, 'All nodes must share the same parent.');
    final object = SlottedDomRenderObject._(parent, firstChildNode: firstNode, lastChildNode: lastNode);
    if (parent is HydratableDomRenderObject) {
      final startIndex = parent.toHydrate.indexOf(firstNode);
      final endIndex = parent.toHydrate.indexOf(lastNode);
      if (startIndex != -1 && endIndex != -1 && startIndex <= endIndex) {
        parent.toHydrate.removeRange(startIndex, endIndex + 1);
      }
    }
    if (_realNodeOf(parent).contains(firstNode)) {
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

  /// The currently attached slots, which own the nodes they contain.
  final Set<ChildSlotRenderObject> _slots = {};

  @override
  void attach(covariant RenderObject child, {covariant RenderObject? after}) {
    if (child is ChildSlotRenderObject) {
      assert(
        isAttached ? _realNodeOf(parent!).contains(child.node) : node.contains(child.node),
        'Cannot attach a child that is not already part of the component fragment.',
      );
      child.parent = this;
      child.finalize();
      _slots.add(child);
      return;
    }
    throw UnsupportedError('SlottedDomRenderObject cannot have children attached to them.');
  }

  @override
  void remove(covariant RenderObject child) {
    if (child is ChildSlotRenderObject) {
      _slots.remove(child);
      child.parent = null;
      return;
    }
    throw UnsupportedError('SlottedDomRenderObject cannot have children removed from them.');
  }

  static web.Node _realNodeOf(DomRenderObject object) {
    if (object is DomRenderFragment) {
      return _realNodeOf(object.parent!);
    }
    return object.node;
  }
}

class ChildSlotRenderObject extends DomRenderObject
    with MultiChildDomRenderObject, HydratableDomRenderObject
    implements RenderFragment {
  /// Creates a slot that owns all children of [node].
  ChildSlotRenderObject(this.node, DomRenderObject parent) : _range = null {
    this.parent = parent;
    toHydrate = [...node.childNodes.toIterable()];
  }

  /// Creates a slot that owns the nodes between [start] and [end].
  ChildSlotRenderObject.between(DomRenderObject parent, web.Node start, web.Node end)
    : node = start.parentElement!,
      _range = (start: start, end: end) {
    this.parent = parent;
    toHydrate = [];
    web.Node? curr = start.nextSibling;
    while (curr != null && curr != end) {
      toHydrate.add(curr);
      curr = curr.nextSibling;
    }
  }

  @override
  final web.Element node;

  /// The nodes around the nodes owned by this slot,
  /// or `null` if this slot owns all children of [node].
  final ({web.Node start, web.Node end})? _range;

  /// The node after which the children of this slot are placed,
  /// or `null` to place them at the start of [node].
  web.Node? get beforeStart => _range?.start;

  /// Whether [other] is one of the nodes owned by this slot, or inside one of them.
  bool _owns(web.Node other) {
    if (_range case (:final start, :final end)) {
      const following = web.Node.DOCUMENT_POSITION_FOLLOWING;
      const containedBy = web.Node.DOCUMENT_POSITION_CONTAINED_BY;
      // Ancestors of the range precede start, and nodes inside start are outside the range.
      return (start.compareDocumentPosition(other) & (following | containedBy)) == following &&
          (end.compareDocumentPosition(other) & web.Node.DOCUMENT_POSITION_PRECEDING) != 0;
    }
    return other != node && node.contains(other);
  }

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    attachChild(child, after, startNode: beforeStart);
  }

  @override
  void remove(DomRenderObject child) {
    removeChild(child);
  }
}
