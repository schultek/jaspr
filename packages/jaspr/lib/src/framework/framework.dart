// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library framework;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:binary_codec/binary_codec.dart';
import 'package:domino/domino.dart';

import '../../jaspr.dart';

export 'package:domino/domino.dart' show DomBuilder, DomEvent, DomEventFn, DomLifecycleEvent, DomLifecycleEventFn;

part 'build_context.dart';
part 'build_owner.dart';
part 'components_binding.dart';
part 'dom_component.dart';
part 'inactive_elements.dart';
part 'inherited_component.dart';
part 'keys.dart';
part 'multi_child_element.dart';
part 'single_child_element.dart';
part 'state_mixins.dart';
part 'stateful_component.dart';
part 'stateless_component.dart';

/// Describes the configuration for an [Element].
///
/// Components are the central class hierarchy in the jaspr framework and have the
/// same structure and purpose as components do in Flutter. A component
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
    return oldComponent.runtimeType == newComponent.runtimeType && oldComponent.key == newComponent.key;
  }
}

/// Signature for a function that creates a component, e.g. [StatelessComponent.build]
/// or [State.build].
///
/// Used by [Builder.builder], etc.
typedef ComponentBuilder = Iterable<Component> Function(BuildContext context);

typedef SingleComponentBuilder = Component Function(BuildContext context);

/// Signature for the callback to [BuildContext.visitChildElements].
///
/// The argument is the child being visited.
///
/// It is safe to call `element.visitChildElements` reentrantly within
/// this callback.
typedef ElementVisitor = void Function(Element element);

enum _ElementLifecycle {
  initial,
  active,
  inactive,
  defunct,
}

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
  ComponentsBinding? _root;
  ComponentsBinding get root => _root!;

  /// The nearest ancestor build scheduler that can rebuild its children.
  BuildScheduler? _scheduler;

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
  Element? updateChild(Element? child, Component? newComponent) {
    if (newComponent == null) {
      if (child != null) {
        deactivateChild(child);
      }
      return null;
    }
    final Element newChild;
    if (child != null) {
      if (child._component == newComponent) {
        newChild = child;
      } else if (Component.canUpdate(child.component, newComponent)) {
        child.update(newComponent);
        assert(child.component == newComponent);
        newChild = child;
      } else {
        deactivateChild(child);
        assert(child._parent == null);
        newChild = inflateComponent(newComponent);
      }
    } else {
      newChild = inflateComponent(newComponent);
    }

    return newChild;
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
  void mount(Element? parent) {
    assert(_lifecycleState == _ElementLifecycle.initial);
    assert(_component != null);
    assert(_parent == null);
    assert(parent == null || parent._lifecycleState == _ElementLifecycle.active);

    _parent = parent;
    _scheduler = this is BuildScheduler
        ? this as BuildScheduler
        : parent is BuildScheduler
            ? parent
            : parent?._scheduler;

    assert(_scheduler != null);

    _lifecycleState = _ElementLifecycle.active;
    _depth = parent != null ? parent.depth + 1 : 1;

    if (parent != null) {
      _root = parent._root;
    }
    assert(_root != null);

    final Key? key = component.key;
    if (key is GlobalKey) {
      root._registerGlobalKey(key, this);
    }
    _updateInheritance();
  }

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
    _component = newComponent;
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

  /// Remove [_scheduler] from the render tree.
  ///
  /// This is called by [deactivateChild].
  void detachScheduler() {
    visitChildren((Element child) {
      child.detachScheduler();
    });
    _scheduler = null;
  }

  /// Add [_scheduler] to the render tree.
  ///
  /// If this or the parent element is a [BuildScheduler] it will use that element, otherwise
  /// it will take the parents [_scheduler] element.
  void attachScheduler() {
    var parent = _parent!;
    _scheduler = this is BuildScheduler
        ? this as BuildScheduler
        : parent is BuildScheduler
            ? parent
            : parent._scheduler;
    visitChildren((Element child) {
      child.attachScheduler();
    });
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
    root._owner._inactiveElements.remove(element);
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
  Element inflateComponent(Component newComponent) {
    final Key? key = newComponent.key;
    if (key is GlobalKey) {
      final Element? newChild = _retakeInactiveElement(key, newComponent);
      if (newChild != null) {
        assert(newChild._parent == null);
        newChild._activateWithParent(this);
        final Element? updatedChild = updateChild(newChild, newComponent);
        assert(newChild == updatedChild);
        return updatedChild!;
      }
    }
    final Element newChild = newComponent.createElement();
    newChild.mount(this);
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
    child.detachScheduler();
    root._owner._inactiveElements.add(child);
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
    _updateDepth(_parent!.depth);
    attachScheduler();
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
    assert(_root != null);
    assert(_scheduler != null);
    assert(_depth != null);
    final bool hadDependencies = (_dependencies != null && _dependencies!.isNotEmpty) || _hadUnsatisfiedDependencies;
    _lifecycleState = _ElementLifecycle.active;

    _dependencies?.clear();
    _hadUnsatisfiedDependencies = false;
    _updateInheritance();
    if (_dirty) {
      root._owner.scheduleBuildFor(this);
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
      for (var dependency in _dependencies!) {
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
    assert(_root != null);

    final Key? key = component.key;
    if (key is GlobalKey) {
      root._unregisterGlobalKey(key, this);
    }

    _component = null;
    _dependencies = null;
    _lifecycleState = _ElementLifecycle.defunct;
  }

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
    markNeedsBuild();
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
    assert(_scheduler != null);
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(() {
      if (root._owner._debugBuilding) {
        if (_debugIsInScope(root._owner._schedulerContext!)) {
          return true;
        }
        if (!_debugAllowIgnoredCallsToMarkNeedsBuild) {
          throw 'setState() or markNeedsBuild() called during build.';
        }
        // can only get here if we're not in scope, but ignored calls are allowed, and our call would somehow be ignored (since we're already dirty)
        assert(dirty);
      }
      return true;
    }());

    if (_dirty) return;
    _dirty = true;
    _root!._owner.scheduleBuildFor(this);
  }

  /// Invalidates the element and schedules a re-render
  @protected
  Future<void> invalidate() {
    return _scheduler!.view.invalidate() ?? Future.value();
  }

  bool _debugIsInScope(BuildScheduler target) {
    BuildScheduler? current = _scheduler;
    while (current != null) {
      if (target == current) {
        return true;
      }
      current = current._parent?._scheduler;
    }
    return false;
  }

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
    root.performRebuildOn(this, () {
      assert(!_dirty);
      if (_dependencies != null && _dependencies!.isNotEmpty) {
        for (var dependency in _dependencies!) {
          dependency.didRebuildDependent(this);
        }
      }
    });
  }

  /// Cause the component to update itself.
  ///
  /// Called by [rebuild] after the appropriate checks have been made.
  @protected
  void performRebuild();

  /// Renders the element to the DOM.
  ///
  /// This is typically called after a completed build by the [BuildScheduler].
  @mustCallSuper
  void render(DomBuilder b);

  /// Can be set by the element to signal that the first build should be performed asynchronous.
  Future? _asyncFirstBuild;
}
