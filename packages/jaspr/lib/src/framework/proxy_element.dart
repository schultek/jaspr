part of 'framework.dart';

abstract class ProxyComponent extends Component {
  const ProxyComponent({
    super.key,
    required this.child,
  });

  final Component child;

  @override
  ProxyElement createElement() => ProxyElement(this);
}

/// An [Element] that composes a child element.
class ProxyElement extends BuildableElement {
  /// Creates an element that uses the given component as its configuration.
  ProxyElement(ProxyComponent super.component);

  @override
  Component build() => (component as ProxyComponent).child;
}

abstract class LeafElement extends Element {
  LeafElement(super.component);

  @override
  bool get debugDoingBuild => false;

  @override
  void mount(Element? parent, ElementSlot? newSlot) {
    super.mount(parent, newSlot);
    assert(_lifecycleState == _ElementLifecycle.active);
  }

  @override
  void didMount() {
    rebuild();
    super.didMount();
  }

  @override
  bool shouldRebuild(Component newComponent) {
    return false;
  }

  @override
  void performRebuild() {
    _dirty = false;
  }

  @override
  void visitChildren(ElementVisitor visitor) {}
}
