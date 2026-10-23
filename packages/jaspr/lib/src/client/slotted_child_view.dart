/// @docImport 'client_app.dart';
library;

import 'package:universal_web/web.dart' as web;

import '../dom/type_checks.dart';
import '../framework/framework.dart';
import 'dom_render_object.dart';
import 'utils.dart';

/// A slot of a [SlottedChildView] that renders [child] into part of the view's DOM nodes.
///
/// The [child] hydrates the nodes already in that part,
/// and any nodes it doesn't reuse are removed.
abstract class ChildSlot extends Component {
  /// Initializes [key] for subclasses.
  const ChildSlot({super.key});

  /// Creates a slot that renders [child] as the content of
  /// the first element matching the CSS selector [query].
  ///
  /// Only elements nested in the view's nodes are searched,
  /// not the top-level nodes themselves.
  factory ChildSlot.fromQuery(String query, {required Component child, Key? key}) = _QueryChildSlot;

  /// Creates a slot that renders [child] between the [start] and [end] nodes,
  /// such as two comment markers.
  ///
  /// The [start] and [end] nodes must share a parent and be part of the view's nodes.
  factory ChildSlot.between({required web.Node start, required web.Node end, required Component child, Key? key}) =
      _RangeChildSlot;

  /// The component this slot renders.
  Component get child;

  /// Creates the render object that renders [child] into part of [parent]'s nodes.
  ChildSlotRenderObject createRenderObject(SlottedDomRenderObject parent);

  /// Whether this slot renders into the same DOM nodes as [oldComponent].
  ///
  /// A slot can't be updated with one that renders into different nodes,
  /// so give such slots different [key]s.
  bool canUpdate(ChildSlot oldComponent);

  @override
  Element createElement() => _ChildSlotElement(this);
}

/// A [ChildSlot] that attaches its child between two given DOM [start] and [end] nodes.
class _RangeChildSlot extends ChildSlot {
  const _RangeChildSlot({required this.start, required this.end, required this.child, super.key});

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
    return oldComponent is _RangeChildSlot && oldComponent.start == start && oldComponent.end == end;
  }
}

/// A [ChildSlot] that attaches its child to the first DOM element matching
/// the given CSS [query].
class _QueryChildSlot extends ChildSlot {
  const _QueryChildSlot(this.query, {required this.child, super.key});

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
    return oldComponent is _QueryChildSlot && oldComponent.query == query;
  }
}

class _ChildSlotElement extends MultiChildRenderObjectElement {
  _ChildSlotElement(ChildSlot super.component);

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
      parent is _SlottedChildViewElement,
      'ChildSlot must be used as a direct child of SlottedChildView.',
    );
    return (parent as _SlottedChildViewElement)._createSlotRenderObject(component as ChildSlot);
  }

  @override
  void updateRenderObject(RenderObject renderObject) {}
}

/// A component that takes over existing DOM nodes and renders its [slots] into parts of them.
///
/// The view hydrates only those parts while keeping a single component tree.
/// For example, [ClientApp] uses a view to hydrate each @client component
/// between its markers, leaving the rest of the server-rendered page untouched.
///
/// A [Component.apply] above the view also applies to the matching elements in its nodes.
class SlottedChildView extends Component {
  /// Creates a view that takes over the remaining unhydrated nodes of its parent element.
  SlottedChildView({required this.slots, super.key}) : nodes = null;

  /// Creates a view that takes over [nodes], which must share a parent.
  ///
  /// If [nodes] aren't already in the view's parent element, they're moved to the view's position.
  SlottedChildView.withNodes({required List<web.Node> this.nodes, required this.slots, super.key});

  /// The DOM nodes this view takes over,
  /// or `null` to take over the remaining unhydrated nodes of its parent element.
  ///
  /// Can't change when the view updates.
  final List<web.Node>? nodes;

  /// The slots that render components into parts of this view's nodes.
  final List<ChildSlot> slots;

  @override
  Element createElement() => _SlottedChildViewElement(this);
}

class _SlottedChildViewElement extends DomRenderObjectElement {
  _SlottedChildViewElement(SlottedChildView super.component);

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
    final renderObject = SlottedDomRenderObject._fromNodes(component.nodes, parent as DomRenderObject);
    updateRenderObject(renderObject);
    return renderObject;
  }

  final Map<web.HTMLElement, _AppliedParams> _appliedParams = nodeMap();

  /// Whether the inherited params might have changed since they were last applied.
  ///
  /// This is set whenever this view is marked to render again,
  /// even if the params themselves stayed the same.
  bool _paramsChanged = false;

  @override
  void markNeedsRender() {
    super.markNeedsRender();
    _paramsChanged = true;
  }

  /// Creates the render object for [slot] within this view's nodes.
  ///
  /// New slots are created while this view rebuilds, before it applies its latest params,
  /// so any pending params are applied first in case the slot's query depends on them.
  ChildSlotRenderObject _createSlotRenderObject(ChildSlot slot) {
    final renderObject = this.renderObject as SlottedDomRenderObject;
    // Range slots target their given nodes directly, so they can't depend on the params.
    if (slot is! _RangeChildSlot && _paramsChanged) {
      updateRenderObject(renderObject);
    }
    return slot.createRenderObject(renderObject);
  }

  @override
  void updateRenderObject(SlottedDomRenderObject renderObject) {
    _paramsChanged = false;
    for (final element in _appliedParams.keys) {
      _resetElementParams(element);
    }
    _appliedParams.clear();

    if (inheritedDomParamsFor(renderObject) case final inheritedDomParams? when inheritedDomParams.isNotEmpty) {
      final slotRanges = {
        for (final slot in component.slots)
          if (slot is _RangeChildSlot) slot.start: slot.end,
      };

      web.Node? current = renderObject.firstChildNode;
      while (current != null) {
        if (slotRanges[current] case final endNode?) {
          if (current == renderObject.lastChildNode) break;
          current = endNode;
          // The end of this slot can be the start of an adjacent slot.
          if (slotRanges.containsKey(current)) continue;
          if (current == renderObject.lastChildNode) break;
          current = current.nextSibling;
          continue;
        }

        if (current.isElement) {
          for (final param in inheritedDomParams.reversed) {
            final elements = _findMatchingElements(current as web.Element, param.target);

            for (final element in elements) {
              _updateElementParams(element as web.HTMLElement, param);
            }
          }
        }

        if (current == renderObject.lastChildNode) {
          break;
        }
        current = current.nextSibling;
      }
    }
  }

  List<web.Element> _findMatchingElements(web.Element root, ApplyTarget target) {
    final elements = <web.Element>[];

    if (_isMatchingElement(target, root)) {
      elements.add(root);
    }

    if (!target.onlyChildren) {
      final results = root.querySelectorAll(target.query);
      for (int i = 0; i < results.length; i++) {
        elements.add(results.item(i) as web.Element);
      }
    }

    return elements;
  }

  bool _isMatchingElement(ApplyTarget target, web.Element element) {
    if (target.tag case final expectedTag? when element.localName != expectedTag) return false;
    if (target.id case final expectedId? when element.id != expectedId) return false;
    if (target.classes case final expectedClasses? when !expectedClasses.every((c) => element.classList.contains(c))) {
      return false;
    }

    return true;
  }

  /// Removes the params this view applied to [element],
  /// without leaving behind empty attributes that it didn't have before.
  void _resetElementParams(web.HTMLElement element) {
    final params = _appliedParams[element];
    if (params == null) return;

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
      for (final e in appliedEvents.entries) {
        e.value.clear();
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
    for (final element in _appliedParams.keys) {
      _resetElementParams(element);
    }
    _appliedParams.clear();
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

/// The render object of a [SlottedChildView], which holds the DOM nodes the view takes over.
///
/// Its only children are the [ChildSlotRenderObject]s of the view's slots.
class SlottedDomRenderObject extends DomRenderFragment {
  SlottedDomRenderObject._(DomRenderObject parent, {this.firstChildNode, this.lastChildNode}) : super(parent, []);

  factory SlottedDomRenderObject._fromNodes(List<web.Node>? nodes, DomRenderObject parent) {
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

  /// The first DOM node the view takes over, or `null` if it takes over none.
  @override
  final web.Node? firstChildNode;

  /// The last DOM node the view takes over, or `null` if it takes over none.
  @override
  final web.Node? lastChildNode;

  @override
  void attach(covariant RenderObject child, {covariant RenderObject? after}) {
    if (child is ChildSlotRenderObject) {
      assert(
        isAttached ? _realNodeOf(parent!).contains(child.node) : node.contains(child.node),
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
    if (child is ChildSlotRenderObject) {
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

/// The render object of a [ChildSlot], which renders its children into
/// part of the DOM nodes of a [SlottedChildView].
///
/// Create one in [ChildSlot.createRenderObject],
/// with the view's render object as its parent.
class ChildSlotRenderObject extends DomRenderObject
    with MultiChildDomRenderObject, HydratableDomRenderObject
    implements RenderFragment {
  /// Creates a slot that renders its children as the content of [node],
  /// hydrating the child nodes [node] already has.
  ChildSlotRenderObject(this.node, DomRenderObject parent) {
    this.parent = parent;
    final childNodes = node.childNodes;
    toHydrate = [
      for (var childIndex = 0; childIndex < childNodes.length; childIndex += 1) childNodes.item(childIndex)!,
    ];
    _beforeStart = null;
  }

  /// Creates a slot that renders its children between the sibling nodes [start] and [end],
  /// hydrating the nodes already between them.
  ChildSlotRenderObject.between(DomRenderObject parent, web.Node start, web.Node end) : node = start.parentElement! {
    this.parent = parent;
    toHydrate = [];
    web.Node? curr = start.nextSibling;
    while (curr != null && curr != end) {
      toHydrate.add(curr);
      curr = curr.nextSibling;
    }
    // Place the children after the start node, even if the slot is empty.
    _beforeStart = start;
  }

  /// The element this slot renders its children into.
  ///
  /// For a slot created with [ChildSlotRenderObject.between],
  /// this is the parent of its start and end nodes.
  @override
  final web.Element node;

  /// The node after which the children of this slot are placed,
  /// or `null` to place them at the start of [node].
  late final web.Node? _beforeStart;

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    attachChild(child, after, startNode: _beforeStart);
  }

  @override
  void remove(DomRenderObject child) {
    removeChild(child);
  }
}
