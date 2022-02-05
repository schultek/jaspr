library core;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:domino/domino.dart';
import 'package:meta/meta.dart';

part 'component_element.dart';
part 'dom_component.dart';
part 'inherited_component.dart';
part 'stateful_component.dart';
part 'stateless_component.dart';

const bool kIsWeb = identical(0, 0.0);

abstract class BuildContext {
  InheritedComponent dependOnInheritedElement(InheritedElement ancestor,
      {Object? aspect});
  T? dependOnInheritedComponentOfExactType<T extends InheritedComponent>(
      {Object? aspect});
  InheritedElement? getElementForInheritedComponentOfExactType<
      T extends InheritedComponent>();
  T? getInheritedComponentOfExactType<T extends InheritedComponent>();
}

abstract class Component {
  const Component();

  Element createElement();

  static bool canUpdate(Component oldComponent, Component newComponent) {
    return oldComponent.runtimeType == newComponent.runtimeType;
  }
}

abstract class Element implements BuildContext {
  Element(this._component);

  Component _component;
  Component get component => _component;

  Element? _parent;

  Map<Type, InheritedElement>? _inheritedElements;

  void _updateInheritance() {
    _inheritedElements = _parent?._inheritedElements;
  }

  void didChangeDependencies() {
    markNeedsBuild();
  }

  @override
  InheritedComponent dependOnInheritedElement(InheritedElement ancestor,
      {Object? aspect}) {
    ancestor.updateDependencies(this, aspect);
    return ancestor.component;
  }

  @override
  T? dependOnInheritedComponentOfExactType<T extends InheritedComponent>(
      {Object? aspect}) {
    final InheritedElement? ancestor =
        _inheritedElements == null ? null : _inheritedElements![T];
    if (ancestor != null) {
      return dependOnInheritedElement(ancestor, aspect: aspect) as T;
    }
    return null;
  }

  @override
  InheritedElement? getElementForInheritedComponentOfExactType<
      T extends InheritedComponent>() {
    final InheritedElement? ancestor =
        _inheritedElements == null ? null : _inheritedElements![T];
    return ancestor;
  }

  @override
  T? getInheritedComponentOfExactType<T extends InheritedComponent>() {
    var element = getElementForInheritedComponentOfExactType<T>();
    return element?.component as T?;
  }

  Future<void> rebuild();

  void render(DomBuilder b);

  @protected
  FutureOr<Element?> updateChild(
      Element? child, Component? newComponent) async {
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
      } else if (Component.canUpdate(child._component, newComponent)) {
        child.update(newComponent);
        newChild = child;
      } else {
        deactivateChild(child);
        newChild = await inflateComponent(newComponent);
      }
    } else {
      newChild = await inflateComponent(newComponent);
    }

    return newChild;
  }

  @mustCallSuper
  FutureOr<void> mount(Element? parent) {
    _parent = parent;
    _updateInheritance();
  }

  @mustCallSuper
  void update(covariant Component newComponent) {
    _component = newComponent;
  }

  @protected
  FutureOr<Element> inflateComponent(Component newComponent) async {
    final Element newChild = newComponent.createElement();
    await newChild.mount(this);
    return newChild;
  }

  @protected
  void deactivateChild(Element child) {
    child._parent = null;
  }

  void markNeedsBuild();
}
