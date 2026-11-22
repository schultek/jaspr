/// @docImport 'client_app.dart';
library;

import 'package:meta/meta.dart';
import 'package:universal_web/web.dart' as web;

import '../dom/type_checks.dart';
import '../framework/applied_dom_values.dart';
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
  ///
  /// The [query] must match an element when the slot mounts.
  /// By then, a slot removed in the same update has already lost the
  /// values that a [Component.apply] above the view added within its contents,
  /// so the query can't depend on those values.
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

  /// The nodes currently between [start] and [end].
  Iterable<web.Node> get contentNodes => siblingsUntil(start.nextSibling, end);

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

  web.Element? findTargetElement(SlottedDomRenderObject parent) {
    for (final node in parent._childNodes) {
      if (node.isElement) {
        final target = (node as web.Element).querySelector(query);
        if (target != null) {
          return target;
        }
      }
    }
    return null;
  }

  @override
  ChildSlotRenderObject createRenderObject(SlottedDomRenderObject parent) {
    final target = findTargetElement(parent);
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

  /// The view that last owned this slot's render object.
  ///
  /// A removed render object loses its parent,
  /// so this tracks the old view until a
  /// keyed slot reactivates in a new one or unmounts.
  late _SlottedChildViewElement _view;

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
    final view = _view = parent as _SlottedChildViewElement;
    final slotObject = (component as ChildSlot).createRenderObject(view.renderObject as SlottedDomRenderObject);
    // Keep the view's values in place until the selector has found its target,
    // then release the contents before the child hydrates them.
    // A slot added in an update mounts before the view renders again,
    // so only skip this when the view's last render already left the range alone.
    if (!view._leftRangeAlone(slotObject)) {
      view._releaseSlotContent(slotObject);
    }
    return slotObject;
  }

  @override
  void updateRenderObject(RenderObject renderObject) {}

  @override
  void activate() {
    super.activate();
    final view = parentRenderObjectElement as _SlottedChildViewElement;
    if (view != _view) {
      // A keyed slot keeps its render object when it moves to a new view,
      // so hand over the existing contents before its children reactivate.
      final slotObject = renderObject as ChildSlotRenderObject;
      (_view.renderObject as SlottedDomRenderObject)._slots.remove(slotObject);
      _view = view;
      view._releaseSlotContent(slotObject);
    }
  }

  @override
  void deactivate() {
    // Only the outermost departing slot releases inherited values. Its walk
    // includes nested slots and preserves applies introduced inside this slot.
    if (!_view._releasedByEnclosingSlot) {
      _view._releaseInheritedValues(this);
    }
    super.deactivate();
  }

  @override
  void unmount() {
    _view._reclaimSlot(renderObject as ChildSlotRenderObject);
    super.unmount();
  }
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
  List<Component> buildChildren() => component.slots;

  @override
  RenderObject createRenderObject() {
    final parent = parentRenderObjectElement!.renderObject;
    final renderObject = SlottedDomRenderObject._fromNodes(component.nodes, parent as DomRenderObject);
    updateRenderObject(renderObject);
    return renderObject;
  }

  bool _didHydrate = false;

  /// The values and listeners this view added to each of its static elements.
  final Map<web.Element, _StaticDomValues> _appliedParams = nodeMap();

  /// Whether a departing slot that encloses this view has
  /// already released the values from applies above that slot's view,
  /// both in this view's slots and on its static elements,
  /// leaving the values from applies within that slot in place.
  bool _releasedByEnclosingSlot = false;

  /// Removes the values that applies above this view contributed
  /// to the DOM elements rendered by [slot].
  ///
  /// A removed slot leaves its DOM in place,
  /// either for this view to take back as static content or for another view to take over,
  /// which tracks only the values it applies itself.
  /// Applies within the slot keep their values.
  ///
  /// As when a DOM component renders without an `open` attribute it had before,
  /// an applied `open` stays on a dialog or details element.
  /// The browser sets that attribute too, such as for `showModal()`,
  /// and removing it from a modal dialog hides the dialog without closing it,
  /// which leaves the rest of the page inert.
  ///
  /// A slot that reactivates instead, such as one moved with a global key,
  /// gets its values back without help: its DOM components depend on the inherited applies,
  /// so they render again when they reactivate,
  /// and rendering sets their attributes on the live DOM rather than diffing against a cache.
  void _releaseInheritedValues(_ChildSlotElement slot) {
    bool fromAboveView(ApplyParams param) => param.source == null || param.source!.depth < depth;

    void release(Element child) {
      if (child is DomElement) {
        final node = child.renderObject.node! as web.Element;
        final values = child.appliedValuesFrom(fromAboveView);
        if (values != null) {
          if (node.isHtmlDialogElement || node.isHtmlDetailsElement) values.attributes?.remove('open');
          values.removeFrom(node);
        }
      } else if (child is _SlottedChildViewElement) {
        child._appliedParams.release(from: fromAboveView);
        child._releasedByEnclosingSlot = true;
      }
      child.visitChildren(release);
    }

    slot.visitChildren(release);
  }

  /// The end node of each range, by its start node,
  /// whose contents the view's last render left alone.
  ///
  /// A range's contents are known before its slot mounts,
  /// so a view with only ranges leaves them alone from the start.
  /// Query slots can depend on newly applied values, including values within ranges,
  /// so other views leave slot contents alone once the slots mount.
  final Map<web.Node, web.Node> _rangesLeftAlone = nodeMap();

  /// Records the ranges that a render applying [params] leaves alone:
  /// every slot, if they're all ranges and there are params to apply, or none otherwise.
  void _updateRangesLeftAlone(List<ApplyParams> params) {
    _rangesLeftAlone.clear();
    // Without params, the view applies nothing, so it has nothing to release either.
    if (params.isEmpty) return;
    final slots = component.slots;
    if (slots.every((slot) => slot is _RangeChildSlot)) {
      for (final slot in slots.cast<_RangeChildSlot>()) {
        _rangesLeftAlone[slot.start] = slot.end;
      }
    }
  }

  /// Whether the view's last render left the range of [slot] alone,
  /// so the view has no values within it to release.
  bool _leftRangeAlone(ChildSlotRenderObject slot) {
    final start = slot._start;
    return start != null && _rangesLeftAlone[start] == slot._end;
  }

  /// Removes the values this view applied within the contents of [slot],
  /// so the slot's child can take them over.
  void _releaseSlotContent(ChildSlotRenderObject slot) {
    if (_appliedParams.isEmpty) return;
    _appliedParams.release(within: slot._contentFilter());
  }

  /// Applies the inherited params to [roots] and their descendants,
  /// except within the contents of the view's slots,
  /// which receive their params from the component tree instead.
  void _applyParams(SlottedDomRenderObject viewObject, Iterable<web.Node> roots, List<ApplyParams> params) {
    if (params.isEmpty) return;

    final isSlotted = _subtreeFilter([
      for (final slot in viewObject._slots) ...slot._contentNodes,
      for (final MapEntry(key: start, value: end) in _rangesLeftAlone.entries) ...siblingsUntil(start.nextSibling, end),
    ]);

    final targets = [
      for (final param in params.reversed)
        if (_selectorFor(param.target) case final selector?) (param: param, selector: selector),
    ];

    final viewParentNode = viewObject.firstChildNode?.parentNode;
    for (final root in roots) {
      if (!root.isElement || isSlotted(root)) continue;
      final isTopLevel = root.parentNode == viewParentNode;
      for (final (:param, :selector) in targets) {
        // Child targets only match the view's top-level nodes.
        if (param.target.onlyChildren && !isTopLevel) continue;
        for (final element in _matches(root as web.Element, selector, onlyRoot: param.target.onlyChildren)) {
          if (!isSlotted(element)) {
            (_appliedParams[element] ??= _StaticDomValues()).apply(element, param);
          }
        }
      }
    }
  }

  @override
  void updateRenderObject(SlottedDomRenderObject renderObject) {
    final params = inheritedDomParamsFor(renderObject);
    if (!_didHydrate && (component.nodes != null || params.isNotEmpty)) {
      _didHydrate = true;
      _hydrateInitialNodes(renderObject);
    }

    _appliedParams.release();
    _updateRangesLeftAlone(params);
    _applyParams(renderObject, renderObject._childNodes, params);
  }

  /// The contents of this view's slots before they mount,
  /// with each query resolved against the DOM as it is now.
  Iterable<web.Node> _initialSlotContents(SlottedDomRenderObject view) sync* {
    for (final slot in component.slots) {
      if (slot is _RangeChildSlot) {
        yield* slot.contentNodes;
      } else if (slot is _QueryChildSlot) {
        final target = slot.findTargetElement(view);
        if (target != null) yield* target.childNodes.toIterable();
      }
    }
  }

  /// Removes the values that the `data-j-apply` markers of this view's static elements record,
  /// which applies above the view added on the server, so the view can apply and track them itself.
  ///
  /// Markers within the slots are left for the components that hydrate them.
  void _hydrateInitialNodes(SlottedDomRenderObject view) {
    final isSlotted = _subtreeFilter(_initialSlotContents(view));
    for (final root in view._childNodes) {
      if (!root.isElement || isSlotted(root)) continue;
      for (final node in _matches(root as web.Element, '[data-j-apply]')) {
        if (isSlotted(node)) continue;
        if (node.getAttribute('data-j-apply') case final marker?) {
          node.removeAttribute('data-j-apply');
          AppliedDomValues.decode(marker).removeFrom(node);
        }
      }
    }
  }

  /// The elements matching [selector] among [root] and,
  /// unless [onlyRoot] is `true`, its descendants.
  List<web.Element> _matches(web.Element root, String selector, {bool onlyRoot = false}) => [
    if (root.matches(selector)) root,
    if (!onlyRoot) ...root.querySelectorAll(selector).toIterable().cast<web.Element>(),
  ];

  /// Builds a CSS selector for [target], or returns `null` if no element can match.
  String? _selectorFor(ApplyTarget target) {
    if (target.tag == '' || (target.classes?.contains('') ?? false)) return null;

    final cssUtils = web.CSS;
    // Target fields are literal names, so escape them before using CSS selector syntax.
    final selector = [
      if (target.tag case final tag?) cssUtils.escape(tag),
      // Element.id is empty for both a missing and an explicitly empty id attribute.
      if (target.id case final id?) id.isEmpty ? ':is(:not([id]), [id=""])' : '#${cssUtils.escape(id)}',
      if (target.classes case final classes?)
        for (final c in classes) '.${cssUtils.escape(c)}',
    ].join();
    return selector.isEmpty ? '*' : selector;
  }

  @override
  void onReload() {
    _appliedParams.release();
    _didHydrate = false;
    super.onReload();
  }

  /// Takes back the nodes that removed slots leave behind
  /// as static content of this view.
  ///
  /// Removed slots are detached from the view and all unmount in the same pass,
  /// so the first one to unmount takes them all back at once.
  /// Taking them back one by one would index the remaining slots again for each.
  void _reclaimSlot(ChildSlotRenderObject slotObject) {
    // An inactive view unmounts along with the slot.
    if (!isActive) return;
    final viewObject = renderObject as SlottedDomRenderObject;
    // Already taken back with an earlier slot of this pass, or never attached, as after a reload.
    if (!viewObject._slots.contains(slotObject)) return;

    final removed = [
      for (final slot in viewObject._slots)
        if (slot == slotObject || slot.parent == null) slot,
    ];
    viewObject._slots.removeAll(removed);
    _applyParams(viewObject, [for (final slot in removed) ...slot._contentNodes], inheritedDomParamsFor(viewObject));
  }

  @override
  void activate() {
    super.activate();
    _releasedByEnclosingSlot = false;
  }

  @override
  void deactivate() {
    // Another view can take over these nodes in the same frame,
    // and it only tracks values that are missing when it applies them.
    if (!_releasedByEnclosingSlot) {
      _appliedParams.release();
    }
    super.deactivate();
  }

  @override
  void unmount() {
    if (_releasedByEnclosingSlot) {
      // Like the DOM components in a removed slot,
      // leave the values from applies within it in place, but stop listening.
      for (final values in _appliedParams.values) {
        values.clearEvents();
      }
      _appliedParams.clear();
    } else {
      _appliedParams.release();
    }
    super.unmount();
  }
}

extension on Map<web.Element, _StaticDomValues> {
  /// Removes and forgets the values and listeners this view applied,
  /// limited to the elements [within] accepts and the applies [from] accepts when given.
  void release({bool Function(web.Node)? within, bool Function(ApplyParams)? from}) {
    removeWhere((element, values) {
      if (within != null && !within(element)) return false;
      values.removeFrom(element, from);
      return values.isEmpty;
    });
  }
}

extension on AppliedDomValues {
  /// Removes these values from [element],
  /// along with any `class` or `style` attribute they leave empty.
  void removeFrom(web.Element element) {
    if (id != null && element.id == id) element.removeAttribute('id');
    if (classes case final names? when names.isNotEmpty) {
      for (final name in names) {
        // `remove` throws for an invalid token, such as an empty name from a malformed marker,
        // but the element can't have one, and `contains` doesn't throw.
        if (element.classList.contains(name)) element.classList.remove(name);
      }
      if (element.classList.length == 0) element.removeAttribute('class');
    }
    if (styles case final names? when names.isNotEmpty) {
      final style = element.inlineStyle;
      if (style != null) {
        for (final name in names) {
          style.removeProperty(name);
        }
        if (style.length == 0) {
          // Sync pending style changes before deleting the empty attribute.
          element.getAttribute('style');
          element.removeAttribute('style');
        }
      }
    }
    if (attributes case final names?) {
      for (final name in names) {
        element.removeAttribute(name);
      }
    }
  }
}

extension on web.Element {
  web.CSSStyleDeclaration? get inlineStyle {
    if (isHtmlElement) return (this as web.HTMLElement).style;
    if (isSvgElement) return (this as web.SVGElement).style;
    return null;
  }
}

/// The values and listeners a view added to one of its static elements,
/// by the apply that added them, leaving out any the element already had,
/// so it removes only its own.
class _StaticDomValues {
  /// The values each apply added, in the order they were added.
  final List<({ApplyParams param, AppliedDomValues values})> _values = [];

  /// The listener for each event type, along with the apply that added it.
  ///
  /// Only the first apply that handles an event type adds a listener for it.
  final Map<String, ({ApplyParams param, EventBinding binding})> _events = {};

  /// Whether no values or listeners remain.
  bool get isEmpty => _values.isEmpty && _events.isEmpty;

  /// Adds the values and listeners of [param] to [node],
  /// skipping any values that [node] already has.
  void apply(web.Element node, ApplyParams param) {
    final added = AppliedDomValues();
    if (param.id case final value? when node.id.isEmpty) {
      node.id = value;
      added.id = value;
    }
    for (final name in param.classes ?? const <String>[]) {
      if (!node.classList.contains(name)) {
        node.classList.add(name);
        (added.classes ??= []).add(name);
      }
    }
    if (param.styles case final properties?) {
      final style = node.inlineStyle;
      if (style != null) {
        for (final MapEntry(:key, :value) in properties.entries) {
          if (style.getPropertyValue(key).isEmpty) {
            style.setProperty(key, value);
            (added.styles ??= []).add(key);
          }
        }
      }
    }
    if (param.attributes case final attrs?) {
      for (final MapEntry(:key, :value) in attrs.entries) {
        if (!node.hasAttribute(key)) {
          node.setAttribute(key, value);
          (added.attributes ??= []).add(key);
        }
      }
    }
    if (!added.isEmpty) _values.add((param: param, values: added));
    if (param.events case final handlers?) {
      for (final MapEntry(:key, :value) in handlers.entries) {
        _events.putIfAbsent(key, () => (param: param, binding: EventBinding(node, key, value)));
      }
    }
  }

  /// Removes the values and listeners that the applies [from] accepts added to [node],
  /// or all of them if [from] is `null`.
  void removeFrom(web.Element node, [bool Function(ApplyParams)? from]) {
    _values.removeWhere((entry) {
      if (from != null && !from(entry.param)) return false;
      entry.values.removeFrom(node);
      return true;
    });
    _events.removeWhere((_, entry) {
      if (from != null && !from(entry.param)) return false;
      entry.binding.clear();
      return true;
    });
  }

  /// Removes the listeners, but leaves the values in place.
  void clearEvents() {
    for (final entry in _events.values) {
      entry.binding.clear();
    }
    _events.clear();
  }
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

  /// The top-level DOM nodes this view takes over.
  Iterable<web.Node> get _childNodes sync* {
    for (var node = firstChildNode; node != null; node = node.nextSibling) {
      yield node;
      if (node == lastChildNode) break;
    }
  }

  /// The slots that render into this view's nodes.
  ///
  /// A removed slot is detached from the view, but stays here until
  /// the removed slots unmount or it moves to another view,
  /// since its nodes can hold globally keyed children until then.
  final Set<ChildSlotRenderObject> _slots = {};

  @override
  void attach(covariant RenderObject child, {covariant RenderObject? after}) {
    if (child is ChildSlotRenderObject) {
      assert(
        isAttached ? _realNodeOf(parent!).contains(child.node) : node.contains(child.node),
        'Cannot attach a child that is not already part of the component fragment.',
      );
      child.parent = this;
      _slots.add(child);
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
    implements RenderChildSlot {
  /// Creates a slot that renders its children as the content of [node],
  /// hydrating the child nodes [node] already has.
  ChildSlotRenderObject(web.Element node, DomRenderObject parent) : this._(node, parent);

  /// Creates a slot that renders its children between the sibling nodes [start] and [end],
  /// hydrating the nodes already between them.
  ChildSlotRenderObject.between(DomRenderObject parent, web.Node start, web.Node end)
    : this._(start.parentElement!, parent, start: start, end: end);

  /// Creates a slot that hydrates all children of [node] or,
  /// when anchors are supplied, only the nodes between them.
  ChildSlotRenderObject._(this.node, DomRenderObject parent, {this._start, this._end}) {
    this.parent = parent;
    toHydrate.addAll(_contentNodes);
  }

  /// The element this slot renders its children into.
  ///
  /// For a slot created with [ChildSlotRenderObject.between],
  /// this is the parent of its start and end nodes.
  @override
  final web.Element node;

  // A keyed slot can move to another view, so check against its current view.
  @internal
  @override
  bool get rendersIntoParent {
    final view = parent;
    return view != null && node == SlottedDomRenderObject._realNodeOf(view);
  }

  /// The node after which children are placed,
  /// even if the range is initially empty,
  /// or `null` to place them at the start of [node].
  final web.Node? _start;

  /// The node before which the contents end,
  /// or `null` if they run to the end of [node].
  final web.Node? _end;

  /// The current contents, which can differ from the nodes originally hydrated.
  Iterable<web.Node> get _contentNodes => siblingsUntil(_start == null ? node.firstChild : _start.nextSibling, _end);

  /// Tests membership in the slot's current contents during one ownership transfer.
  bool Function(web.Node) _contentFilter() {
    if (_start == null) return (other) => other != node && node.contains(other);
    return _subtreeFilter(_contentNodes);
  }

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    attachChild(child, after, startNode: _start);
  }

  @override
  void remove(DomRenderObject child) {
    removeChild(child);
  }
}

/// Indexes the roots once and shares ancestor lookups across membership checks.
bool Function(web.Node) _subtreeFilter(Iterable<web.Node> roots) {
  final inside = nodeMap<web.Node, bool>();
  for (final root in roots) {
    inside[root] = true;
  }
  if (inside.isEmpty) return (_) => false;

  bool contains(web.Node node) {
    final known = inside[node];
    if (known != null) return known;
    final parent = node.parentNode;
    return inside[node] = parent != null && contains(parent);
  }

  return contains;
}
