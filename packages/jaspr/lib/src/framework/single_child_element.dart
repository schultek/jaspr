part of framework;

/// An [Element] that has a single children.
///
/// Used by [InheritedComponent].
abstract class SingleChildElement extends Element {
  SingleChildElement(super.component);

  /// The current child of this element.
  @protected
  @visibleForTesting
  Element get child => _child!;

  Element? _child;

  bool _debugDoingBuild = false;
  @override
  bool get debugDoingBuild => _debugDoingBuild;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    assert(_child == null);
    assert(_lifecycleState == _ElementLifecycle.active);
    _firstBuild();
  }

  void _firstBuild() {
    rebuild();
  }

  @override
  void performRebuild() {
    assert(_debugSetAllowIgnoredCallsToMarkNeedsBuild(true));
    Component? built;
    try {
      assert(() {
        _debugDoingBuild = true;
        return true;
      }());
      built = build();
      assert(() {
        _debugDoingBuild = false;
        return true;
      }());
    } catch (e, st) {
      _debugDoingBuild = false;
      // TODO: implement actual error component
      built = DomComponent(
        tag: 'div',
        child: Text("Error on building component: $e"),
      );
      print('Error: $e $st');
    } finally {
      _dirty = false;
      assert(_debugSetAllowIgnoredCallsToMarkNeedsBuild(false));
    }

    _child = updateChild(_child, built);
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
