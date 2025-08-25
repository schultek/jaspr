part of 'framework.dart';

abstract class LeafElement extends Element {
  LeafElement(super.component);

  @override
  bool get debugDoingBuild => false;

  @override
  void mount(Element? parent, ElementSlot newSlot) {
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
