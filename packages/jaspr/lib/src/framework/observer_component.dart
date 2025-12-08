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
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const ObserverComponent({required this.child, super.key});

  final Component child;

  @override
  ObserverElement createElement();
}

/// An [Element] that uses an [ObserverComponent] as its configuration.
/// You can override [willRebuildElement], [didRebuildElement] and [didUnmountElement]
/// to execute the required logic.
abstract class ObserverElement extends BuildableElement {
  ObserverElement(ObserverComponent super.component);

  @override
  ObserverComponent get component => super.component as ObserverComponent;

  @override
  Component build() => component.child;

  /// Executed when a child [element] is the next to rebuild.
  void willRebuildElement(Element element);

  /// Executed when a child [element] completed a rebuild.
  void didRebuildElement(Element element);

  /// Executed when a child [element] is unmounted from the Element tree.
  /// You should release any resources associated with the element.
  void didUnmountElement(Element element);

  @override
  void _updateObservers() {
    assert(_lifecycleState == _ElementLifecycle.active);
    final incomingElements = _parent?._observerElements;
    _observerElements = [
      ...?incomingElements,
      this,
    ];
  }
}
