part of 'framework.dart';

/// An [Element] that has a [build] method.
///
/// Used by [StatelessComponent] and [StatefulComponent].
abstract class BuildableElement extends Element {
  /// Creates an element that uses the given component as its configuration.
  BuildableElement(super.component);

  /// The current child of this element.
  @protected
  @visibleForTesting
  Element? get child => _child;

  Element? _child;

  bool _debugDoingBuild = false;
  @override
  bool get debugDoingBuild => _debugDoingBuild;

  @override
  void mount(Element? parent, ElementSlot newSlot) {
    super.mount(parent, newSlot);
    assert(_child == null);
  }

  @override
  void didMount() {
    rebuild();
    super.didMount();
  }

  @override
  bool shouldRebuild(Component newComponent) {
    return true;
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
      // TODO: implement actual error handling
      built = Component.element(
        tag: 'div',
        styles: const Styles(
          padding: Padding.all(Unit.em(2)),
          backgroundColor: Colors.red,
          color: Colors.yellow,
          fontSize: Unit.rem(1),
        ),
        children: [Component.text('Error on building component: $e')],
      );
      binding.reportBuildError(this, e, st);
    } finally {
      _dirty = false;
      assert(_debugSetAllowIgnoredCallsToMarkNeedsBuild(false));
    }

    _child = updateChild(_child, built, slot);
  }

  @protected
  void failRebuild(Object error, StackTrace stackTrace) {
    binding.reportBuildError(this, error, stackTrace);

    _dirty = false;
    _child = null;
  }

  /// Subclasses should override this function to actually call the appropriate
  /// `build` function (e.g., [StatelessComponent.build] or [State.build]) for
  /// their component.
  @protected
  Component build();

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) {
      visitor(_child!);
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_child != null);
    assert(_child == child);
    _child = null;
    super.forgetChild(child);
  }
}
