library framework;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:domino/domino.dart';
import 'package:jaspr/jaspr.dart';
import 'package:meta/meta.dart';

part 'app_binding.dart';
part 'build_context.dart';
part 'dom_component.dart';
part 'inactive_elements.dart';
part 'inherited_component.dart';
part 'keys.dart';
part 'multi_child_element.dart';
part 'single_child_element.dart';
part 'stateful_component.dart';
part 'stateless_component.dart';

const bool kIsWeb = identical(0, 0.0);

abstract class Component {
  const Component({this.key});

  final Key? key;

  Element createElement();

  static bool canUpdate(Component oldComponent, Component newComponent) {
    return oldComponent.runtimeType == newComponent.runtimeType && oldComponent.key == newComponent.key;
  }
}

typedef ElementVisitor = void Function(Element element);

enum _ElementLifecycle {
  initial,
  active,
  inactive,
  defunct,
}

abstract class Element implements BuildContext {
  Element(Component component) : _component = component;

  Element? _parent;

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

  Component? _component;
  Component get component => _component!;

  AppBinding? _root;
  AppBinding get root => _root!;

  BuildScheduler? _scheduler;

  _ElementLifecycle _lifecycleState = _ElementLifecycle.initial;

  void visitChildren(ElementVisitor visitor);

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
        root.performRebuildOn(newChild);
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

  void detachScheduler() {
    visitChildren((Element child) {
      child.detachScheduler();
    });
    _scheduler = null;
  }

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
    root._inactiveElements.remove(element);
    return element;
  }

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

  @protected
  void deactivateChild(Element child) {
    assert(child._parent == this);
    child._parent = null;
    child.detachScheduler();
    root._inactiveElements.add(child);
  }

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
    if (_dirty) _scheduler!.scheduleRebuild();
    if (hadDependencies) didChangeDependencies();
  }

  @mustCallSuper
  void deactivate() {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_component != null);
    assert(_depth != null);
    if (_dependencies != null && _dependencies!.isNotEmpty) {
      for (final InheritedElement dependency in _dependencies!) {
        dependency._dependents.remove(this);
      }
    }
    _inheritedElements = null;
    _lifecycleState = _ElementLifecycle.inactive;
  }

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

  @override
  T? getInheritedComponentOfExactType<T extends InheritedComponent>() {
    var element = getElementForInheritedComponentOfExactType<T>();
    return element?.component as T?;
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

  void didChangeDependencies() {
    assert(_lifecycleState == _ElementLifecycle.active);
    markNeedsBuild();
  }

  bool _dirty = true;
  bool get dirty => _dirty;

  @mustCallSuper
  void markNeedsBuild() {
    assert(_lifecycleState != _ElementLifecycle.defunct);
    if (_lifecycleState != _ElementLifecycle.active) return;
    assert(_scheduler != null);
    assert(_lifecycleState == _ElementLifecycle.active);
    if (_dirty) return;
    _dirty = true;
    _scheduler!.scheduleBuildFor(this);
  }

  @mustCallSuper
  void rebuild();

  @mustCallSuper
  void render(DomBuilder b);
}
