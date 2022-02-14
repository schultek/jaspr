part of framework;

abstract class InheritedComponent extends Component {
  const InheritedComponent({required this.child});

  final Component child;

  @override
  InheritedElement createElement() => InheritedElement(this);

  @protected
  bool updateShouldNotify(covariant InheritedComponent oldComponent);
}

class InheritedElement extends SingleChildElement {
  InheritedElement(InheritedComponent component) : super(component);

  @override
  InheritedComponent get component => super.component as InheritedComponent;

  final Map<Element, Object?> _dependents = HashMap<Element, Object?>();

  @override
  void _updateInheritance() {
    assert(_lifecycleState == _ElementLifecycle.active);
    final Map<Type, InheritedElement>? incomingElements = _parent?._inheritedElements;
    if (incomingElements != null) {
      _inheritedElements = HashMap<Type, InheritedElement>.from(incomingElements);
    } else {
      _inheritedElements = HashMap<Type, InheritedElement>();
    }
    _inheritedElements![component.runtimeType] = this;
  }

  @protected
  Object? getDependencies(Element dependent) {
    return _dependents[dependent];
  }

  @protected
  void setDependencies(Element dependent, Object? value) {
    _dependents[dependent] = value;
  }

  @protected
  void updateDependencies(Element dependent, Object? aspect) {
    setDependencies(dependent, null);
  }

  @override
  void update(InheritedComponent newComponent) {
    var oldComponent = component;
    super.update(newComponent);
    updated(oldComponent);
    _dirty = true;
    root.performRebuildOn(this);
  }

  @protected
  void updated(InheritedComponent oldComponent) {
    if (component.updateShouldNotify(oldComponent)) {
      for (final Element dependent in _dependents.keys) {
        dependent.didChangeDependencies();
      }
    }
  }

  @override
  Component? build() => component.child;
}
