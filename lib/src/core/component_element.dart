part of core;

abstract class ComponentElement extends Element {
  ComponentElement(Component component) : super(component);

  List<Element>? _children;

  @override
  Future<void> rebuild() async {
    var comps = build(this).toList();

    var lastChildren = _children ?? [];
    _children = [];

    var len = max(lastChildren.length, comps.length);
    for (var i = 0; i < len; i++) {
      var comp = i < comps.length ? comps[i] : null;
      var lastChild = i < lastChildren.length ? lastChildren[i] : null;

      var newChild = await updateChild(lastChild, comp);
      if (newChild != null) {
        _children!.add(newChild);
      }
    }

    for (var child in _children!) {
      await child.rebuild();
    }
  }

  @override
  void render(DomBuilder b) {
    for (var child in _children!) {
      child.render(b);
    }
  }

  @protected
  Iterable<Component> build(BuildContext context);

  @override
  void markNeedsBuild() {
    _parent?.markNeedsBuild();
  }
}
