part of framework;

/// An [Element] that has a single children.
///
/// Used by [InheritedComponent].
abstract class SingleChildElement extends Element {
  SingleChildElement(Component component) : super(component);

  /// The current child of this element.
  @protected
  @visibleForTesting
  Element get child => _child!;

  Element? _child;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    assert(_child == null);
    assert(_lifecycleState == _ElementLifecycle.active);
    _firstBuild();
  }

  void _firstBuild() {
    root.performRebuildOn(this);
  }

  @override
  void rebuild() {
    if (dirty) {
      var built = build();
      _child = updateChild(_child, built);
      _dirty = false;
    } else {
      assert(_child != null);
      root.performRebuildOn(_child!);
    }
  }

  @override
  void render(DomBuilder b) {
    _child?.render(b);
  }

  /// Subclasses should override this function to return the current configuration of
  /// their child.
  @protected
  Component? build();

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) {
      visitor(_child!);
    }
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
    super.forgetChild(child);
  }
}
