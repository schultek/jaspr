part of 'framework.dart';

/// An [Element] that has multiple children based on a proxy list.
abstract class MultiChildElement extends Element {
  /// Creates an element that uses the given component as its configuration.
  MultiChildElement(super.component);

  /// The current list of children of this element.
  ///
  /// This list is filtered to hide elements that have been forgotten (using
  /// [forgetChild]).
  @protected
  @visibleForTesting
  Iterable<Element> get children => _children!.where((Element child) => !_forgottenChildren.contains(child));

  List<Element>? _children;
  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  bool get debugDoingBuild => false;

  @override
  void mount(Element? parent, ElementSlot newSlot) {
    super.mount(parent, newSlot);
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

  @protected
  List<Component> buildChildren();

  @override
  void performRebuild() {
    _dirty = false;

    final newComponents = buildChildren();
    _children = updateChildren(_children ?? [], newComponents, forgottenChildren: _forgottenChildren);
    _forgottenChildren.clear();
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_children case final children?) {
      for (final child in children) {
        if (!_forgottenChildren.contains(child)) {
          visitor(child);
        }
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
