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
    final view = parentRenderObjectElement as SlottedChildViewElement;
    final renderObject = this.renderObject as ChildSlotRenderObject;
    super.unmount();
    view._reclaimSlot(renderObject);
  }
}

/// Component that renders its children into specified DOM nodes (slots).
///
/// Child components are mounted as direct children of this component, but may target
/// specific nested DOM nodes within the component's DOM subtree. This allows for hydrating
/// only specific parts of the DOM tree while having a single coherent component tree.
///
/// When a slot is removed, its DOM nodes stay in place as static content, without the
/// listeners or inherited params its child added. Like other static content in this view,
/// they then receive the inherited params from this view instead.
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
    final renderObject = this.renderObject as SlottedDomRenderObject;

    // The view normally applies changed params after rebuilding its slots,
    // but a query must be able to match them, so apply them first.
    // That includes the elements of removed slots, which released their params when deactivated.
    final queriedRemovedSlots = slot is RangeChildSlot ? const <ChildSlotRenderObject>{} : renderObject._removedSlots;
    if (slot is! RangeChildSlot && (_paramsChanged || queriedRemovedSlots.isNotEmpty)) {
      _applyParams(renderObject, includeRemovedSlots: queriedRemovedSlots.isNotEmpty);
    }
    final slotRenderObject = slot.createRenderObject(renderObject);

    // Resolve the target before removing any values its query could match.
    // Then release the nodes being handed over, before the child hydrates them,
    // and the nodes of removed slots, which this view only takes over once they unmount.
    _releaseParams([
      if (slotRenderObject.toHydrate.isNotEmpty) slotRenderObject,
      ...queriedRemovedSlots,
    ]);
    return slotRenderObject;
  }

  /// Applies the inherited params to the elements owned by this view.
  ///
  /// This view owns all elements outside of its slots, at any depth.
  /// Elements inside a slot are owned by the slot's child,
  /// which applies the inherited params to its own elements,
  /// so this view never modifies them.
  /// A removed slot keeps its elements until it unmounts.
  @override
  void updateRenderObject(SlottedDomRenderObject renderObject) {
    _applyParams(renderObject);
  }

  /// Applies the inherited params to the elements owned by this view,
  /// as well as to the elements of removed slots if [includeRemovedSlots] is `true`.
  void _applyParams(SlottedDomRenderObject renderObject, {bool includeRemovedSlots = false}) {
    _paramsChanged = false;
    _resetAppliedParams();

    final params = inheritedDomParamsFor(renderObject)?.reversed.toList(growable: false);
    if (params == null || params.isEmpty) return;

    _visitOwnedElements(
      renderObject,
      descendants: params.any((p) => !p.target.onlyChildren),
      includeRemovedSlots: includeRemovedSlots,
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
  /// The elements of removed slots are only visited if [includeRemovedSlots] is `true`.
  void _visitOwnedElements(
    SlottedDomRenderObject renderObject,
    void Function(web.HTMLElement element, bool isRoot) visit, {
    required bool descendants,
    required bool includeRemovedSlots,
  }) {
    // The start and end nodes of range slots, and the elements whose children are slotted.
    final slotRanges = nodeMap<web.Node, web.Node>();
    final slottedParents = nodeSet<web.Node>();
    final skippedSlots = includeRemovedSlots
        ? renderObject._slots
        : renderObject._slots.followedBy(renderObject._removedSlots);
    for (final slot in skippedSlots) {
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

  /// Releases our params on the elements owned by [slots].
  ///
  /// Reset and forget them before a slot's child hydrates the elements,
  /// so a nested view doesn't treat inherited values as original DOM values.
  void _releaseParams(List<ChildSlotRenderObject> slots) {
    if (slots.isEmpty || _appliedParams.isEmpty) return;

    _appliedParams.removeWhere((element, params) {
      if (!slots.any((slot) => slot._owns(element))) return false;
      _resetElementParams(element, params);
      return true;
    });
  }

  void _resetAppliedParams() {
    _appliedParams.forEach(_resetElementParams);
    _appliedParams.clear();
  }

  void _resetElementParams(web.HTMLElement element, _AppliedParams params) {
    element.removeValues(
      id: params.id,
      classes: params.classes,
      styles: params.styles?.keys,
      attributes: params.attributes?.keys,
    );

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

  /// Takes over the nodes of a removed [slot] once it unmounted.
  ///
  /// Its descendants already released the values they rendered when they were deactivated,
  /// so apply the params once every slot removed in this build has unmounted.
  void _reclaimSlot(ChildSlotRenderObject slot) {
    final renderObject = this.renderObject as SlottedDomRenderObject;
    if (renderObject._removedSlots.remove(slot) && renderObject._removedSlots.isEmpty) {
      updateRenderObject(renderObject);
    }
  }

  /// Resets the values this view applied, since its DOM can stay in place,
  /// such as when it's in a removed slot of another view, or the root component is detached.
  ///
  /// Whatever takes over the DOM next would otherwise treat them as original values.
  /// If this view is reactivated instead, such as when moved with a global key,
  /// its dependency on the inherited params makes it apply them again.
  @override
  void deactivate() {
    _resetAppliedParams();
    // Its slots unmount along with it, so it doesn't take over their nodes.
    (renderObject as SlottedDomRenderObject)._removedSlots.clear();
    super.deactivate();
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

  /// The slots removed during the current build, which still own the nodes they contained.
  ///
  /// The view takes over their nodes once they unmount, after any element
  /// moved out of them with a global key has left.
  final Set<ChildSlotRenderObject> _removedSlots = {};

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
      _removedSlots.remove(child);
      return;
    }
    throw UnsupportedError('SlottedDomRenderObject cannot have children attached to them.');
  }

  @override
  void remove(covariant RenderObject child) {
    if (child is ChildSlotRenderObject) {
      _slots.remove(child);
      _removedSlots.add(child);
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
