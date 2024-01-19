part of 'framework.dart';

/// Base class for components that observes the build execution of
/// it's descendants in the Component tree.
///
/// See also:
///
///  * [StatefulComponent] and [State], for components that can build differently
///    several times over their lifetime.
///  * [StatelessComponent], for components that always build the same way given a
///    particular configuration and ambient state.
///  * [InheritedComponent], for components that introduce ambient state that can
///    be read by descendant components.
///  * [Component], for an overview of components in general.
abstract class ObserverComponent extends Component {
  /// Abstract constant constructor with the [child]
  /// which will be below this in the tree.
  const ObserverComponent({required this.child, super.key});

  /// The component below this component in the tree.
  final Component child;

  @override
  ObserverElement createElement();
}

/// An [Element] that uses an [ObserverComponent] as its configuration.
/// You can override [willRebuildElement], [didRebuildElement] and [didUnmountElement]
/// to execute the required logic.
abstract class ObserverElement extends SingleChildElement {
  ObserverElement(ObserverComponent super.component);

  @override
  ObserverComponent get component => super.component as ObserverComponent;

  /// Executed when a child [element] is the next to rebuild.
  void willRebuildElement(Element element);

  /// Executed when a child [element] completed a rebuild.
  void didRebuildElement(Element element);

  /// Executed when a child [element] is unmounted from the Element tree.
  /// You should release any resources associated with the element.
  void didUnmountElement(Element element);

  @override
  void update(ObserverComponent newComponent) {
    super.update(newComponent);
    _dirty = true;
    rebuild();
  }

  @override
  void _updateObservers() {
    assert(_lifecycleState == _ElementLifecycle.active);
    final List<ObserverElement>? incomingElements = _parent?._observerElements;
    if (incomingElements != null) {
      _observerElements = List<ObserverElement>.from(incomingElements);
    } else {
      _observerElements = <ObserverElement>[];
    }
    _observerElements!.add(this);
  }

  @override
  Component? build() => component.child;
}
