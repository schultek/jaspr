// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport '../components/basic.dart';
/// @docImport '../components/notification_listener.dart';
/// @docImport '../foundation/change_notifier.dart';
library;

import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:universal_web/web.dart' as web;

import '../dom/styles/styles.dart' show Styles, Padding, Colors, Unit;
import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../foundation/object.dart';

part 'build_context.dart';
part 'build_owner.dart';
part 'buildable_element.dart';
part 'components.dart';
part 'components_binding.dart';
part 'inactive_elements.dart';
part 'inherited_component.dart';
part 'inherited_model.dart';
part 'keys.dart';
part 'leaf_element.dart';
part 'multi_child_element.dart';
part 'notification.dart';
part 'observer_component.dart';
part 'render_object.dart';
part 'stateful_component.dart';
part 'stateless_component.dart';

/// Describes the configuration for an [Element].
///
/// Components are the central class hierarchy in the Jaspr framework and have the
/// same structure and purpose as widgets do in Flutter. A component
/// is an immutable description of part of a user interface. Components can be
/// inflated into elements, which manage the underlying DOM.
///
/// Components themselves have no mutable state (all their fields must be final).
/// If you wish to associate mutable state with a component, consider using a
/// [StatefulComponent], which creates a [State] object (via
/// [StatefulComponent.createState]) whenever it is inflated into an element and
/// incorporated into the tree.
///
/// A given component can be included in the tree zero or more times. In particular
/// a given component can be placed in the tree multiple times. Each time a component
/// is placed in the tree, it is inflated into an [Element], which means a
/// component that is incorporated into the tree multiple times will be inflated
/// multiple times.
///
/// The [key] property controls how one component replaces another component in the
/// tree. If the [runtimeType] and [key] properties of the two components are
/// [operator==], respectively, then the new component replaces the old component by
/// updating the underlying element (i.e., by calling [Element.update] with the
/// new component). Otherwise, the old element is removed from the tree, the new
/// component is inflated into an element, and the new element is inserted into the
/// tree.
///
/// See also:
///
///  * [StatefulComponent] and [State], for components that can build differently
///    several times over their lifetime.
///  * [InheritedComponent], for components that introduce ambient state that can
///    be read by descendant components.
///  * [StatelessComponent], for components that always build the same way given a
///    particular configuration and ambient state.
@immutable
abstract class Component {
  /// Initializes [key] for subclasses.
  const Component({this.key});

  /// Creates a component which renders a html text node.
  const factory Component.text(String text, {Key? key}) = Text._;

  /// Creates a component which renders a html element node with the given [tag], like
  /// a `<div>`, `<button>` etc.
  ///
  /// Example:
  /// ```dart
  /// return Component.element(
  ///   tag: 'div',
  ///   classes: 'some-class',
  ///   styles: Styles(backgroundColor: Colors.red),
  ///   children: [
  ///     Component.text('Hello World'),
  ///   ],
  /// );
  /// ```
  ///
  /// Renders:
  ///
  /// ```html
  /// <div class="some-class" style="background-color: red;">
  ///   Hello World
  /// </div>
  /// ```
  ///
  const factory Component.element({
    required String tag,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events,
    List<Component>? children,
    Key? key,
  }) = DomComponent._;

  /// Creates a component which applies its parameters (like [classes], [styles], etc.) to its
  /// direct child element(s).
  ///
  /// This does not create a html element itself. All properties are merged with the respective child element's
  /// properties, with the child's properties taking precedence where there are conflicts.
  ///
  /// Example:
  /// ```dart
  /// return Component.wrapElement(
  ///   classes: 'wrapping-class',
  ///   styles: Styles(backgroundColor: Colors.blue, padding: Padding.all(8.px)),
  ///   child: Component.element(
  ///     tag: 'div',
  ///     classes: 'some-class',
  ///     styles: Styles(backgroundColor: Colors.red),
  ///     children: [
  ///       Component.text('Hello World'),
  ///     ],
  ///   ),
  /// );
  /// ```
  ///
  /// Renders:
  /// ```html
  /// <div class="wrapping-class some-class" style="padding: 8px; background-color: red;">
  ///   Hello World
  /// </div>
  /// ```
  ///
  const factory Component.wrapElement({
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events,
    required Component child,
  }) = _WrappingDomComponent;

  /// Creates a component which renders a list of child components without any wrapping element.
  ///
  /// This is useful when you want to return multiple elements from a build method without adding an extra
  /// wrapping element to the html DOM.
  ///
  /// Example:
  /// ```dart
  /// return Component.fragment([
  ///   Component.element(tag: 'span', children: []),
  ///   Component.element(tag: 'button', children: []),
  /// ]);
  /// ```
  ///
  /// Renders:
  /// ```html
  /// <span></span>
  /// <button></button>
  /// ```
  ///
  const factory Component.fragment(List<Component> children, {Key? key}) = Fragment._;

  /// Creates an empty component which renders nothing.
  ///
  /// This is useful when you want to return "nothing" from a build method.
  const factory Component.empty({Key? key}) = Fragment._empty;

  /// Controls how one component replaces another component in the tree.
  ///
  /// If the [runtimeType] and [key] properties of the two components are
  /// [operator==], respectively, then the new component replaces the old component by
  /// updating the underlying element (i.e., by calling [Element.update] with the
  /// new component). Otherwise, the old element is removed from the tree, the new
  /// component is inflated into an element, and the new element is inserted into the
  /// tree.
  ///
  /// In addition, using a [GlobalKey] as the component's [key] allows the element
  /// to be moved around the tree (changing parent) without losing state. When a
  /// new component is found (its key and type do not match a previous component in
  /// the same location), but there was a component with that same global key
  /// elsewhere in the tree in the previous frame, then that component's element is
  /// moved to the new location.
  ///
  /// Generally, a component that is the only child of another component does not need
  /// an explicit key.
  ///
  /// See also:
  ///
  ///  * The discussions at [Key] and [GlobalKey].
  final Key? key;

  /// Inflates this configuration to a concrete instance.
  ///
  /// A given component can be included in the tree zero or more times. In particular
  /// a given component can be placed in the tree multiple times. Each time a component
  /// is placed in the tree, it is inflated into an [Element], which means a
  /// component that is incorporated into the tree multiple times will be inflated
  /// multiple times.
  Element createElement();

  /// Whether the `newComponent` can be used to update an [Element] that currently
  /// has the `oldComponent` as its configuration.
  ///
  /// An element that uses a given component as its configuration can be updated to
  /// use another component as its configuration if, and only if, the two components
  /// have [runtimeType] and [key] properties that are [operator==].
  ///
  /// If the components have no key (their key is null), then they are considered a
  /// match if they have the same type, even if their children are completely
  /// different.
  static bool canUpdate(Component oldComponent, Component newComponent) {
    if (oldComponent.runtimeType != newComponent.runtimeType || oldComponent.key != newComponent.key) {
      return false;
    }
    // If the tag is different, then the components are not compatible.
    if (oldComponent is DomComponent && oldComponent.tag != (newComponent as DomComponent).tag) {
      return false;
    }
    return true;
  }
}

/// Signature for a function that creates a component, e.g. [StatelessComponent.build]
/// or [State.build].
///
/// Used by [Builder.builder], etc.
typedef ComponentBuilder = Component Function(BuildContext context);

///
/// Signature for the callback to [BuildContext.visitChildElements].
///
/// The argument is the child being visited.
///
/// It is safe to call `element.visitChildElements` reentrantly within
/// this callback.
typedef ElementVisitor = void Function(Element element);

enum _ElementLifecycle { initial, active, inactive, defunct }

/// An instantiation of a [Component] at a particular location in the tree.
///
/// Components describe how to configure a subtree but the same component can be used
/// to configure multiple subtrees simultaneously because components are immutable.
/// An [Element] represents the use of a component to configure a specific location
/// in the tree. Over time, the component associated with a given element can
/// change, for example, if the parent component rebuilds and creates a new component
/// for this location..
abstract class Element implements BuildContext {
  /// Creates an element that uses the given component as its configuration.
  ///
  /// Typically called by an override of [Component.createElement].
  Element(Component component) : _component = component;

  Element? _parent;
  Element? get parent => _parent;

  _NotificationNode? _notificationTree;

  /// Compare two components for equality.
  ///
  /// When a component is rebuilt with another that compares equal according
  /// to `operator ==`, it is assumed that the update is redundant and the
  /// work to update that branch of the tree is skipped.
  ///
  /// It is generally discouraged to override `operator ==` on any component that
  /// has children, since a correct implementation would have to defer to the
  /// children's equality operator also, and that is an O(N²) operation: each
  /// child would need to itself walk all its children, each step of the tree.
  ///
  /// It is sometimes reasonable for a leaf component (one with no children) to
  /// implement this method, if rebuilding the component is known to be much more
  /// expensive than checking the components' parameters for equality and if the
  /// component is expected to often be rebuilt with identical parameters.
  ///
  /// In general, however, it is more efficient to cache the components used
  /// in a build method if it is known that they will not change.
  @nonVirtual
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => identical(this, other);

  /// Information set by parent to define where this child fits in its parent's
  /// child list.
  ///
  /// A child component's slot is determined when the parent's [updateChild] method
  /// is called to inflate the child component.
  ElementSlot get slot => _slot!;
  ElementSlot? _slot;

  // Custom implementation of hash code optimized for the ".of" pattern used
  // with `InheritedComponents`.
  //
  // `Element.dependOnInheritedComponentOfExactType` relies heavily on hash-based
  // `Set` look-ups, putting this getter on the performance critical path.
  //
  // The value is designed to fit within the SMI representation. This makes
  // the cached value use less memory (one field and no extra heap objects) and
  // cheap to compare (no indirection).
  @nonVirtual
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _cachedHash;
  final int _cachedHash = _nextHashCode = (_nextHashCode + 1) % 0xffffff;
  static int _nextHashCode = 1;

  /// An integer that is guaranteed to be greater than the parent's, if any.
  /// The element at the root of the tree must have a depth greater than 0.
  int get depth => _depth!;
  int? _depth;

  static int _sort(Element a, Element b) {
    if (a.depth < b.depth) {
      return -1;
    } else if (b.depth < a.depth) {
      return 1;
    } else if (b.dirty && !a.dirty) {
      return -1;
    } else if (a.dirty && !b.dirty) {
      return 1;
    }
    return 0;
  }

  /// The configuration for this element.
  @override
  Component get component => _component!;
  Component? _component;

  /// The root component binding that manages the component tree.
  @override
  AppBinding get binding => _binding!;
  AppBinding? _binding;

  /// The root build owner that manages the build cycle.
  BuildOwner get owner => _owner!;
  BuildOwner? _owner;

  // This is used to verify that Element objects move through life in an
  // orderly fashion.
  _ElementLifecycle _lifecycleState = _ElementLifecycle.initial;

  /// Calls the argument for each child.
  ///
  /// There is no guaranteed order in which the children will be visited, though
  /// it should be consistent over time.
  ///
  /// Calling this during build is dangerous: the child list might still be
  /// being updated at that point, so the children might not be constructed yet,
  /// or might be old children that are going to be replaced. This method should
  /// only be called if it is provable that the children are available.
  void visitChildren(ElementVisitor visitor);

  /// Wrapper around [visitChildren] for [BuildContext].
  @override
  void visitChildElements(ElementVisitor visitor) {
    visitChildren(visitor);
  }

  /// Update the given child with the given new configuration.
  ///
  /// This method is the core of the components system. It is called each time we
  /// are to add, update, or remove a child based on an updated configuration.
  ///
  /// If the `child` is null, and the `newComponent` is not null, then we have a new
  /// child for which we need to create an [Element], configured with `newComponent`.
  ///
  /// If the `newComponent` is null, and the `child` is not null, then we need to
  /// remove it because it no longer has a configuration.
  ///
  /// If neither are null, then we need to update the `child`'s configuration to
  /// be the new configuration given by `newComponent`. If `newComponent` can be given
  /// to the existing child (as determined by [Component.canUpdate]), then it is so
  /// given. Otherwise, the old child needs to be disposed and a new child
  /// created for the new configuration.
  ///
  /// If both are null, then we don't have a child and won't have a child, so we
  /// do nothing.
  ///
  /// The [updateChild] method returns the new child, if it had to create one,
  /// or the child that was passed in, if it just had to update the child, or
  /// null, if it removed the child and did not replace it.
  ///
  /// The following table summarizes the above:
  ///
  /// |                     | **newComponent == null**  | **newComponent != null**   |
  /// | :-----------------: | :--------------------- | :---------------------- |
  /// |  **child == null**  |  Returns null.         |  Returns new [Element]. |
  /// |  **child != null**  |  Old child is removed, returns null. | Old child updated if possible, returns child or new [Element]. |
  @protected
  Element? updateChild(Element? child, Component? newComponent, ElementSlot newSlot) {
    if (newComponent == null) {
      if (child != null) {
        deactivateChild(child);
      }
      return null;
    }
    final Element newChild;
    if (child != null) {
      if (child._component == newComponent) {
        if (child._parentChanged || child.slot != newSlot) {
          updateSlotForChild(child, newSlot);
        }
        newChild = child;
      } else if (child._parentChanged || Component.canUpdate(child.component, newComponent)) {
        if (child._parentChanged || child.slot != newSlot) {
          updateSlotForChild(child, newSlot);
        }
        final oldComponent = child.component;
        child.update(newComponent);
        assert(child.component == newComponent);
        child.didUpdate(oldComponent);
        newChild = child;
      } else {
        deactivateChild(child);
        assert(child._parent == null);
        newChild = inflateComponent(newComponent, newSlot);
      }
    } else {
      newChild = inflateComponent(newComponent, newSlot);
    }

    return newChild;
  }

  /// Updates the children of this element to use new components.
  ///
  /// Attempts to update the given old children list using the given new
  /// components, removing obsolete elements and introducing new ones as necessary,
  /// and then returns the new child list.
  ///
  /// During this function the `oldChildren` list must not be modified. If the
  /// caller wishes to remove elements from `oldChildren` re-entrantly while
  /// this function is on the stack, the caller can supply a `forgottenChildren`
  /// argument, which can be modified while this function is on the stack.
  /// Whenever this function reads from `oldChildren`, this function first
  /// checks whether the child is in `forgottenChildren`. If it is, the function
  /// acts as if the child was not in `oldChildren`.
  ///
  /// This function is a convenience wrapper around [updateChild], which updates
  /// each individual child.
  @protected
  List<Element> updateChildren(
    List<Element> oldChildren,
    List<Component> newComponents, {
    Set<Element>? forgottenChildren,
  }) {
    Element? replaceWithNullIfForgotten(Element? child) {
      return child != null && forgottenChildren != null && forgottenChildren.contains(child) ? null : child;
    }

    ElementSlot slotFor(int newChildIndex, Element? previousChild) {
      return ElementSlot(newChildIndex, previousChild);
    }

    // This attempts to diff the new child list (newComponents) with
    // the old child list (oldChildren), and produce a new list of elements to
    // be the new list of child elements of this element. The called of this
    // method is expected to update this render object accordingly.

    // The cases it tries to optimize for are:
    //  - the old list is empty
    //  - the lists are identical
    //  - there is an insertion or removal of one or more components in
    //    only one place in the list
    // If a component with a key is in both lists, it will be synced.
    // Components without keys might be synced but there is no guarantee.

    // The general approach is to sync the entire new list backwards, as follows:
    // 1. Walk the lists from the top, syncing nodes, until you no longer have
    //    matching nodes.
    // 2. Walk the lists from the bottom, without syncing nodes, until you no
    //    longer have matching nodes. We'll sync these nodes at the end. We
    //    don't sync them now because we want to sync all the nodes in order
    //    from beginning to end.
    // At this point we narrowed the old and new lists to the point
    // where the nodes no longer match.
    // 3. Walk the narrowed part of the old list to get the list of
    //    keys and sync null with non-keyed items.
    // 4. Walk the narrowed part of the new list forwards:
    //     * Sync non-keyed items with null
    //     * Sync keyed items with the source if it exists, else with null.
    // 5. Walk the bottom of the list again, syncing the nodes.
    // 6. Sync null with any items in the list of keys that are still
    //    mounted.

    if (oldChildren.length <= 1 && newComponents.length <= 1) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren.firstOrNull);
      final newChild = updateChild(oldChild, newComponents.firstOrNull, ElementSlot(0, null));
      return [?newChild];
    }

    int newChildrenTop = 0;
    int oldChildrenTop = 0;
    int newChildrenBottom = newComponents.length - 1;
    int oldChildrenBottom = oldChildren.length - 1;

    final List<Element?> newChildren = oldChildren.length == newComponents.length
        ? oldChildren
        : List<Element?>.filled(newComponents.length, null, growable: true);

    Element? prevChild;

    // Update the top of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
      final Component newComponent = newComponents[newChildrenTop];
      if (oldChild == null || !Component.canUpdate(oldChild.component, newComponent)) break;
      final Element newChild = updateChild(oldChild, newComponent, slotFor(newChildrenTop, prevChild))!;
      newChildren[newChildrenTop] = newChild;
      prevChild = newChild;
      newChildrenTop += 1;
      oldChildrenTop += 1;
    }

    // Scan the bottom of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenBottom]);
      final Component newComponent = newComponents[newChildrenBottom];
      if (oldChild == null || !Component.canUpdate(oldChild.component, newComponent)) break;
      oldChildrenBottom -= 1;
      newChildrenBottom -= 1;
    }

    Map<Key, Element>? retakeOldKeyedChildren;
    if (newChildrenTop <= newChildrenBottom && oldChildrenTop <= oldChildrenBottom) {
      final Map<Key, Component> newKeyedChildren = {};
      var newChildrenTopPeek = newChildrenTop;
      while (newChildrenTopPeek <= newChildrenBottom) {
        final Component newComponent = newComponents[newChildrenTopPeek];
        final Key? key = newComponent.key;
        if (key != null) {
          newKeyedChildren[key] = newComponent;
        }
        newChildrenTopPeek += 1;
      }

      if (newKeyedChildren.isNotEmpty) {
        retakeOldKeyedChildren = {};
        var oldChildrenTopPeek = oldChildrenTop;
        while (oldChildrenTopPeek <= oldChildrenBottom) {
          final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTopPeek]);
          if (oldChild != null) {
            final Key? key = oldChild.component.key;
            if (key != null) {
              final Component? newComponent = newKeyedChildren[key];
              if (newComponent != null && Component.canUpdate(oldChild.component, newComponent)) {
                retakeOldKeyedChildren[key] = oldChild;
              }
            }
          }
          oldChildrenTopPeek += 1;
        }
      }
    }

    while (newChildrenTop <= newChildrenBottom) {
      if (oldChildrenTop <= oldChildrenBottom) {
        final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
        if (oldChild != null) {
          final Key? key = oldChild.component.key;
          if (key == null || retakeOldKeyedChildren == null || !retakeOldKeyedChildren.containsKey(key)) {
            deactivateChild(oldChild);
          }
        }
        oldChildrenTop += 1;
      }

      Element? oldChild;
      final Component newComponent = newComponents[newChildrenTop];
      final Key? key = newComponent.key;
      if (key != null) {
        oldChild = retakeOldKeyedChildren?[key];
      }

      final Element newChild = updateChild(oldChild, newComponent, slotFor(newChildrenTop, prevChild))!;
      newChildren[newChildrenTop] = newChild;
      prevChild = newChild;
      newChildrenTop += 1;
    }

    while (oldChildrenTop <= oldChildrenBottom) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
      if (oldChild != null) {
        final Key? key = oldChild.component.key;
        if (key == null || retakeOldKeyedChildren == null || !retakeOldKeyedChildren.containsKey(key)) {
          deactivateChild(oldChild);
        }
      }
      oldChildrenTop += 1;
    }

    // We've scanned the whole list.
    newChildrenBottom = newComponents.length - 1;
    oldChildrenBottom = oldChildren.length - 1;

    // Update the bottom of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element oldChild = oldChildren[oldChildrenTop];
      final Component newComponent = newComponents[newChildrenTop];
      final Element newChild = updateChild(oldChild, newComponent, slotFor(newChildrenTop, prevChild))!;
      newChildren[newChildrenTop] = newChild;
      prevChild = newChild;
      newChildrenTop += 1;
      oldChildrenTop += 1;
    }

    assert(newChildren.every((element) => element != null));

    return newChildren.cast<Element>();
  }

  /// Add this element to the tree as a child of the given parent.
  ///
  /// The framework calls this function when a newly created element is added to
  /// the tree for the first time. Use this method to initialize state that
  /// depends on having a parent. State that is independent of the parent can
  /// more easily be initialized in the constructor.
  ///
  /// This method transitions the element from the "initial" lifecycle state to
  /// the "active" lifecycle state.
  ///
  /// Subclasses that override this method are likely to want to also override
  /// [update] and [visitChildren].
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.mount(parent)`.
  @mustCallSuper
  void mount(Element? parent, ElementSlot newSlot) {
    assert(_lifecycleState == _ElementLifecycle.initial);
    assert(_component != null);
    assert(_parent == null);
    assert(parent == null || parent._lifecycleState == _ElementLifecycle.active);

    _parent = parent;
    _parentRenderObjectElement = parent is RenderObjectElement ? parent : parent?._parentRenderObjectElement;

    _slot = newSlot;
    if (this is RenderObjectElement) {
      newSlot.target = this as RenderObjectElement;
    }

    _lifecycleState = _ElementLifecycle.active;
    _depth = parent != null ? parent.depth + 1 : 1;

    if (parent != null) {
      _owner = parent.owner;
      _binding = parent.binding;
    }
    assert(_owner != null);
    assert(_binding != null);

    final Key? key = component.key;
    if (key is GlobalKey && binding.isClient) {
      ComponentsBinding._registerGlobalKey(key, this);
    }
    _updateInheritance();
    _updateObservers();
    attachNotificationTree();
  }

  @protected
  @mustCallSuper
  void didMount() {}

  /// Change the component used to configure this element.
  ///
  /// The framework calls this function when the parent wishes to use a
  /// different component to configure this element. The new component is guaranteed
  /// to have the same [runtimeType] as the old component.
  ///
  /// This function is called only during the "active" lifecycle state.
  @mustCallSuper
  void update(covariant Component newComponent) {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_component != null);
    assert(newComponent != component);
    assert(_depth != null);
    assert(Component.canUpdate(component, newComponent));
    if (shouldRebuild(newComponent)) {
      _dirty = true;
    }
    _component = newComponent;
  }

  void didUpdate(covariant Component oldComponent) {
    if (_dirty) {
      rebuild();
    }
  }

  /// Implement this method to determine whether a rebuild can be skipped.
  ///
  /// This method will be called whenever the component is about to update. If returned false, the subsequent rebuild will be skipped.
  ///
  /// This method exists only as a performance optimization and gives no guarantees about when the component is rebuilt.
  /// Keep the implementation as efficient as possible and avoid deep (recursive) comparisons or performance heavy checks, as this might
  /// have an opposite effect on performance.
  bool shouldRebuild(covariant Component newComponent);

  /// Change the slot that the given child occupies in its parent.
  ///
  /// Called by [MultiChildRenderObjectElement], and other [RenderObjectElement]
  /// subclasses that have multiple children, when child moves from one position
  /// to another in this element's child list.
  @protected
  void updateSlotForChild(Element child, ElementSlot newSlot) {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(child._parent == this);
    void visit(Element element) {
      element.updateSlot(newSlot);
      if (element is! RenderObjectElement) {
        Element? next;
        element.visitChildren((Element child) {
          assert(next == null); // This verifies that there's only one child.
          next = child;
          visit(child);
        });
      }
    }

    visit(child);
  }

  /// Called by [updateSlotForChild] when the framework needs to change the slot
  /// that this [Element] occupies in its ancestor.
  @protected
  @mustCallSuper
  void updateSlot(ElementSlot newSlot) {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_parent != null);
    assert(_parent!._lifecycleState == _ElementLifecycle.active);
    _slot = newSlot;
    if (this is RenderObjectElement) {
      newSlot.target = this as RenderObjectElement;
    }
  }

  void _updateDepth(int parentDepth) {
    final int expectedDepth = parentDepth + 1;
    if (depth < expectedDepth) {
      _depth = expectedDepth;
      visitChildren((Element child) {
        child._updateDepth(expectedDepth);
      });
    }
  }

  Element? _retakeInactiveElement(GlobalKey key, Component newComponent) {
    final Element? element = key._currentElement;
    if (element == null) {
      return null;
    }
    if (!Component.canUpdate(element.component, newComponent)) {
      return null;
    }
    final Element? parent = element._parent;
    if (parent != null) {
      parent.forgetChild(element);
      parent.deactivateChild(element);
    }
    assert(element._parent == null);
    owner._inactiveElements.remove(element);
    return element;
  }

  /// Create an element for the given component and add it as a child of this
  /// element.
  ///
  /// This method is typically called by [updateChild] but can be called
  /// directly by subclasses that need finer-grained control over creating
  /// elements.
  ///
  /// If the given component has a global key and an element already exists that
  /// has a component with that global key, this function will reuse that element
  /// (potentially grafting it from another location in the tree or reactivating
  /// it from the list of inactive elements) rather than creating a new element.
  ///
  /// The element returned by this function will already have been mounted and
  /// will be in the "active" lifecycle state.
  @protected
  Element inflateComponent(Component newComponent, ElementSlot newSlot) {
    final Key? key = newComponent.key;
    if (key is GlobalKey) {
      final Element? newChild = _retakeInactiveElement(key, newComponent);
      if (newChild != null) {
        assert(newChild._parent == null);
        newChild._activateWithParent(this);
        newChild._parentChanged = true;
        final Element? updatedChild = updateChild(newChild, newComponent, newSlot);
        assert(newChild == updatedChild);
        return updatedChild!;
      }
    }
    final Element newChild = newComponent.createElement();
    newChild.mount(this, newSlot);
    newChild.didMount();
    assert(newChild._lifecycleState == _ElementLifecycle.active);
    return newChild;
  }

  /// Move the given element to the list of inactive elements and detach its
  /// render object from the render tree.
  ///
  /// This method stops the given element from being a child of this element by
  /// detaching its render object from the render tree and moving the element to
  /// the list of inactive elements.
  ///
  /// This method (indirectly) calls [deactivate] on the child.
  ///
  /// The caller is responsible for removing the child from its child model.
  /// Typically [deactivateChild] is called by the element itself while it is
  /// updating its child model; however, during [GlobalKey] reparenting, the new
  /// parent proactively calls the old parent's [deactivateChild], first using
  /// [forgetChild] to cause the old parent to update its child model.
  @protected
  void deactivateChild(Element child) {
    assert(child._parent == this);
    child._parent = null;
    child.slot.target = null;
    owner._inactiveElements.add(child);
  }

  /// Remove the given child from the element's child list, in preparation for
  /// the child being reused elsewhere in the element tree.
  ///
  /// This updates the child model such that, e.g., [visitChildren] does not
  /// walk that child anymore.
  ///
  /// The element will still have a valid parent when this is called.
  /// After this is called, [deactivateChild] is called to sever the link to
  /// this object.
  ///
  /// The [update] is responsible for updating or creating the new child that
  /// will replace this [child].
  @protected
  @mustCallSuper
  void forgetChild(Element child) {}

  void _activateWithParent(Element parent) {
    assert(_lifecycleState == _ElementLifecycle.inactive);
    _parent = parent;
    _parentRenderObjectElement = parent is RenderObjectElement ? parent : parent._parentRenderObjectElement;
    _updateDepth(_parent!.depth);
    _activateRecursively(this);
    assert(_lifecycleState == _ElementLifecycle.active);
  }

  static void _activateRecursively(Element element) {
    assert(element._lifecycleState == _ElementLifecycle.inactive);
    element.activate();
    assert(element._lifecycleState == _ElementLifecycle.active);
    element.visitChildren(_activateRecursively);
  }

  /// Transition from the "inactive" to the "active" lifecycle state.
  ///
  /// The framework calls this method when a previously deactivated element has
  /// been reincorporated into the tree. The framework does not call this method
  /// the first time an element becomes active (i.e., from the "initial"
  /// lifecycle state). Instead, the framework calls [mount] in that situation.
  ///
  /// Implementations of this method should start with a call to the inherited
  /// method, as in `super.activate()`.
  @mustCallSuper
  void activate() {
    assert(_lifecycleState == _ElementLifecycle.inactive);
    assert(_component != null);
    assert(_owner != null);
    assert(_binding != null);
    assert(_parent != null);
    assert(_depth != null);
    final bool hadDependencies = (_dependencies != null && _dependencies!.isNotEmpty) || _hadUnsatisfiedDependencies;
    _lifecycleState = _ElementLifecycle.active;

    final parent = _parent!;
    _parentRenderObjectElement = parent is RenderObjectElement ? parent : parent._parentRenderObjectElement;

    _dependencies?.clear();
    _hadUnsatisfiedDependencies = false;
    _updateInheritance();
    _updateObservers();
    attachNotificationTree();
    if (_dirty) {
      owner.scheduleBuildFor(this);
    }
    if (hadDependencies) didChangeDependencies();
  }

  /// Transition from the "active" to the "inactive" lifecycle state.
  ///
  /// The framework calls this method when a previously active element is moved
  /// to the list of inactive elements. While in the inactive state, the element
  /// will not appear on screen. The element can remain in the inactive state
  /// only until the end of the current animation frame. At the end of the
  /// animation frame, if the element has not be reactivated, the framework will
  /// unmount the element.
  ///
  /// This is (indirectly) called by [deactivateChild].
  ///
  /// Implementations of this method should end with a call to the inherited
  /// method, as in `super.deactivate()`.
  @mustCallSuper
  void deactivate() {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_component != null);
    assert(_depth != null);
    if (_dependencies != null && _dependencies!.isNotEmpty) {
      for (final dependency in _dependencies!) {
        dependency.deactivateDependent(this);
      }
    }
    _inheritedElements = null;
    _lifecycleState = _ElementLifecycle.inactive;
  }

  /// Transition from the "inactive" to the "defunct" lifecycle state.
  ///
  /// Called when the framework determines that an inactive element will never
  /// be reactivated. At the end of each animation frame, the framework calls
  /// [unmount] on any remaining inactive elements, preventing inactive elements
  /// from remaining inactive for longer than a single animation frame.
  ///
  /// After this function is called, the element will not be incorporated into
  /// the tree again.
  ///
  /// Any resources this element holds should be released at this point.
  ///
  /// Implementations of this method should end with a call to the inherited
  /// method, as in `super.unmount()`.
  @mustCallSuper
  void unmount() {
    assert(_lifecycleState == _ElementLifecycle.inactive);
    assert(_component != null);
    assert(_depth != null);
    assert(_owner != null);

    if (_observerElements != null && _observerElements!.isNotEmpty) {
      for (final observer in _observerElements!) {
        observer.didUnmountElement(this);
      }
      _observerElements = null;
    }

    final Key? key = component.key;
    if (key is GlobalKey) {
      ComponentsBinding._unregisterGlobalKey(key, this);
    }

    _parentRenderObjectElement = null;
    _component = null;
    _dependencies = null;
    _lifecycleState = _ElementLifecycle.defunct;
  }

  List<ObserverElement>? _observerElements;

  Map<Type, InheritedElement>? _inheritedElements;
  Set<InheritedElement>? _dependencies;
  bool _hadUnsatisfiedDependencies = false;

  @override
  InheritedComponent dependOnInheritedElement(InheritedElement ancestor, {Object? aspect}) {
    _dependencies ??= HashSet<InheritedElement>();
    _dependencies!.add(ancestor);
    ancestor.updateDependencies(this, aspect);
    return ancestor.component;
  }

  @override
  T? dependOnInheritedComponentOfExactType<T extends InheritedComponent>({Object? aspect}) {
    final InheritedElement? ancestor = _inheritedElements == null ? null : _inheritedElements![T];
    if (ancestor != null) {
      return dependOnInheritedElement(ancestor, aspect: aspect) as T;
    }
    _hadUnsatisfiedDependencies = true;
    return null;
  }

  @override
  InheritedElement? getElementForInheritedComponentOfExactType<T extends InheritedComponent>() {
    final InheritedElement? ancestor = _inheritedElements == null ? null : _inheritedElements![T];
    return ancestor;
  }

  void _updateInheritance() {
    assert(_lifecycleState == _ElementLifecycle.active);
    _inheritedElements = _parent?._inheritedElements;
  }

  /// Populates [_observerElements] when this Element is mounted or activated.
  /// [ObserverElement]s will register themselves for their children.
  void _updateObservers() {
    assert(_lifecycleState == _ElementLifecycle.active);
    _observerElements = _parent?._observerElements;
  }

  /// Called in [Element.mount] and [Element.activate] to register this element in
  /// the notification tree.
  ///
  /// This method is only exposed so that [NotifiableElementMixin] can be implemented.
  /// Subclasses of [Element] that wish to respond to notifications should mix that
  /// in instead.
  ///
  /// See also:
  ///   * [NotificationListener], a component that allows listening to notifications.
  @protected
  void attachNotificationTree() {
    _notificationTree = _parent?._notificationTree;
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulComponent>>() {
    Element? ancestor = _parent;
    while (ancestor != null) {
      if (ancestor is StatefulElement && ancestor.state is T) {
        break;
      }
      ancestor = ancestor._parent;
    }
    final StatefulElement? statefulAncestor = ancestor as StatefulElement?;
    return statefulAncestor?.state as T?;
  }

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {
    Element? ancestor = _parent;
    while (ancestor != null && visitor(ancestor)) {
      ancestor = ancestor._parent;
    }
  }

  /// Called when a dependency of this element changes.
  ///
  /// The [dependOnInheritedComponentOfExactType] registers this element as depending on
  /// inherited information of the given type. When the information of that type
  /// changes at this location in the tree (e.g., because the [InheritedElement]
  /// updated to a new [InheritedComponent] and
  /// [InheritedComponent.updateShouldNotify] returned true), the framework calls
  /// this function to notify this element of the change.
  void didChangeDependencies() {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_debugCheckOwnerBuildTargetExists('didChangeDependencies'));
    markNeedsBuild();
  }

  bool _debugCheckOwnerBuildTargetExists(String methodName) {
    assert(() {
      if (owner._debugCurrentBuildTarget == null) {
        throw '$methodName for ${component.runtimeType} was called at an '
            'inappropriate time.';
      }
      return true;
    }());
    return true;
  }

  /// Returns true if the element has been marked as needing rebuilding.
  bool _dirty = true;
  bool get dirty => _dirty;

  // Whether this is in owner._dirtyElements. This is used to know whether we
  // should be adding the element back into the list when it's reactivated.
  // ignore: prefer_final_fields
  bool _inDirtyList = false;

  // We let component authors call setState from initState, didUpdateComponent, and
  // build even when state is locked because its convenient and a no-op anyway.
  // This flag ensures that this convenience is only allowed on the element
  // currently undergoing initState, didUpdateComponent, or build.
  bool _debugAllowIgnoredCallsToMarkNeedsBuild = false;
  bool _debugSetAllowIgnoredCallsToMarkNeedsBuild(bool value) {
    assert(_debugAllowIgnoredCallsToMarkNeedsBuild == !value);
    _debugAllowIgnoredCallsToMarkNeedsBuild = value;
    return true;
  }

  /// Marks the element as dirty and schedules a rebuild.
  @mustCallSuper
  void markNeedsBuild() {
    assert(_lifecycleState != _ElementLifecycle.defunct);
    if (_lifecycleState != _ElementLifecycle.active) return;
    assert(_parentRenderObjectElement != null);
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(() {
      if (owner._debugBuilding) {
        assert(owner._debugCurrentBuildTarget != null);
        if (_debugIsInScope(owner._debugCurrentBuildTarget!)) {
          return true;
        }
        if (!_debugAllowIgnoredCallsToMarkNeedsBuild) {
          throw 'setState() or markNeedsBuild() called during build.';
        }
        // can only get here if we're not in scope, but ignored calls are allowed, and our call would somehow be ignored (since we're already dirty)
        assert(dirty);
      } else if (owner._debugStateLocked) {
        assert(!_debugAllowIgnoredCallsToMarkNeedsBuild);
        throw 'setState() or markNeedsBuild() called when widget tree was locked.';
      }
      return true;
    }());

    if (_dirty) return;
    _dirty = true;
    owner.scheduleBuildFor(this);
  }

  bool _debugIsInScope(Element target) {
    Element? current = this;
    while (current != null) {
      if (target == current) {
        return true;
      }
      current = current._parent;
    }
    return false;
  }

  Element? _debugPreviousBuildTarget;

  /// Cause the component to update itself.
  ///
  /// Called by the [BuildOwner] when rebuilding, by [mount] when the element is first
  /// built, and by [update] when the component has changed.
  void rebuild() {
    assert(_lifecycleState != _ElementLifecycle.initial);
    if (_lifecycleState != _ElementLifecycle.active || !_dirty) {
      return;
    }
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(owner._debugStateLocked);
    assert(() {
      if (!binding.isClient && owner.isFirstBuild) return true;
      _debugPreviousBuildTarget = owner._debugCurrentBuildTarget;
      owner._debugCurrentBuildTarget = this;
      return true;
    }());
    if (_observerElements != null && _observerElements!.isNotEmpty) {
      for (final observer in _observerElements!) {
        observer.willRebuildElement(this);
      }
    }
    owner.performRebuildOn(this);
  }

  void didRebuild() {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(() {
      if (!binding.isClient && owner.isFirstBuild) return true;
      assert(owner._debugCurrentBuildTarget == this);
      owner._debugCurrentBuildTarget = _debugPreviousBuildTarget;
      return true;
    }());
    assert(!_dirty);

    if (_dependencies != null && _dependencies!.isNotEmpty) {
      for (final dependency in _dependencies!) {
        dependency.didRebuildDependent(this);
      }
    }
    if (_observerElements != null && _observerElements!.isNotEmpty) {
      for (final observer in _observerElements!) {
        observer.didRebuildElement(this);
      }
    }
  }

  /// Cause the component to update itself.
  ///
  /// Called by [BuildOwner] after the appropriate checks have been made.
  void performRebuild();

  void attachRenderObject() {}

  void detachRenderObject() {
    visitChildren((Element child) {
      assert(child._parent == this);
      child.detachRenderObject();
    });
  }

  @override
  void dispatchNotification(Notification notification) {
    _notificationTree?.dispatchNotification(notification);
  }

  /// The nearest ancestor dom node.
  RenderObjectElement? _parentRenderObjectElement;
  RenderObjectElement? get parentRenderObjectElement => _parentRenderObjectElement;

  var _parentChanged = false;
}

class ElementSlot {
  ElementSlot(this.index, this.previousSibling);

  RenderObjectElement? target;

  /// The previous sibling of this slot in the parent's child list.
  final Element? previousSibling;

  /// The index of this slot in the parent's child list.
  final int index;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ElementSlot && index == other.index && previousSibling == other.previousSibling;
  }

  @override
  int get hashCode => Object.hash(index, previousSibling);
}
