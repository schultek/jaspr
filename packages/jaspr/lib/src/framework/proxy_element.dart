part of 'framework.dart';

abstract class ProxyComponent extends Component {
  const ProxyComponent({
    this.child,
    this.children,
    super.key,
  }) : assert(child == null || children == null);

  final Component? child;
  final List<Component>? children;

  @override
  ProxyElement createElement() => ProxyElement(this);
}

/// An [Element] that has multiple children based on a proxy list.
class ProxyElement extends Element {
  /// Creates an element that uses the given component as its configuration.
  ProxyElement(ProxyComponent super.component);

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

  @override
  bool get debugDoingBuild => false;

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
  bool shouldRebuild(ProxyComponent newComponent) {
    return true;
  }

  @override
  void performRebuild() {
    _dirty = false;

    var comp = (component as ProxyComponent);
    var newComponents = comp.children ?? [if (comp.child != null) comp.child!];

    _children = updateChildren(_children ?? [], newComponents, forgottenChildren: _forgottenChildren);
    _forgottenChildren.clear();
  }

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

abstract class LeafElement extends Element {
  LeafElement(super.component);

  @override
  bool get debugDoingBuild => false;

  @override
  void mount(Element? parent, Element? prevSibling) {
    super.mount(parent, prevSibling);
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
