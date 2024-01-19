part of 'document.dart';

class ComponentObserver extends ObserverComponent {
  ComponentObserver({required this.registerElement, required super.child});

  final void Function(Element) registerElement;

  @override
  ObserverElement createElement() => ComponentObserverElement(this);
}

class ComponentObserverElement extends ObserverElement {
  ComponentObserverElement(super.component);

  @override
  ComponentObserver get component => super.component as ComponentObserver;

  @override
  void willRebuildElement(Element element) {}

  @override
  void didRebuildElement(Element element) {
    component.registerElement(element);
  }

  @override
  void didUnmountElement(Element element) {}
}
