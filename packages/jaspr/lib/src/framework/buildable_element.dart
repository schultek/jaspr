part of 'framework.dart';

/// An [Element] that has multiple children and a [build] method.
///
/// Used by [DomComponent], [StatelessComponent] and [StatefulComponent].
abstract class BuildableElement extends Element {
  /// Creates an element that uses the given component as its configuration.
  BuildableElement(super.component);

  /// The current list of children of this element.
  ///
  /// This list is filtered to hide elements that have been forgotten (using
  /// [forgetChild]).
  @protected
  Iterable<Element> get children => _children!.where((Element child) => !_forgottenChildren.contains(child));

  List<Element>? _children;
  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  bool _debugDoingBuild = false;
  @override
  bool get debugDoingBuild => _debugDoingBuild;

  @override
  void mount(Element? parent, Element? prevSibling) {
    super.mount(parent, prevSibling);
    assert(_children == null);
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
    List<Component>? built;
    try {
      assert(() {
        _debugDoingBuild = true;
        return true;
      }());
      built = build().toList();
      assert(() {
        _debugDoingBuild = false;
        return true;
      }());
    } catch (e, st) {
      _debugDoingBuild = false;
      // TODO: implement actual error handling
      built = [
        DomComponent(
          tag: 'div',
          styles: Styles(
            padding: Padding.all(2.em),
            backgroundColor: Colors.red,
            color: Colors.yellow,
            fontSize: 1.rem,
          ),
          child: Text("Error on building component: $e"),
        ),
      ];
      binding.reportBuildError(this, e, st);
    } finally {
      _dirty = false;
      assert(_debugSetAllowIgnoredCallsToMarkNeedsBuild(false));
    }

    _children = updateChildren(_children ?? [], built, forgottenChildren: _forgottenChildren);
    _forgottenChildren.clear();
  }

  /// Subclasses should override this function to actually call the appropriate
  /// `build` function (e.g., [StatelessComponent.build] or [State.build]) for
  /// their component.
  @protected
  Iterable<Component> build();

  @override
  void visitChildren(ElementVisitor visitor) {
    for (var child in _children ?? []) {
      if (!_forgottenChildren.contains(child)) {
        visitor(child);
      }
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_children != null);
    assert(_children!.contains(child));
    assert(!_forgottenChildren.contains(child));
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }
}
