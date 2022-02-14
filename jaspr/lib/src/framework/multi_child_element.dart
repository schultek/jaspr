part of framework;

abstract class MultiChildElement extends Element {
  MultiChildElement(Component component) : super(component);

  List<Element>? _children;

  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  void mount(Element? parent) {
    super.mount(parent);
    assert(_children == null);
    assert(_lifecycleState == _ElementLifecycle.active);
    _firstBuild();
  }

  void _firstBuild() {
    root.performRebuildOn(this);
  }

  @override
  void rebuild() {
    if (dirty) {
      List<Component> built = build().toList();
      _children = updateChildren(_children ?? [], built, forgottenChildren: _forgottenChildren);
      _forgottenChildren.clear();
      _dirty = false;
    } else {
      assert(_children != null);
      for (var child in _children!) {
        root.performRebuildOn(child);
      }
    }
  }

  @protected
  List<Element> updateChildren(List<Element> oldChildren, List<Component> newComponents,
      {Set<Element>? forgottenChildren}) {
    Element? replaceWithNullIfForgotten(Element child) {
      return forgottenChildren != null && forgottenChildren.contains(child) ? null : child;
    }

    int newChildrenTop = 0;
    int oldChildrenTop = 0;
    int newChildrenBottom = newComponents.length - 1;
    int oldChildrenBottom = oldChildren.length - 1;

    final List<Element?> newChildren = oldChildren.length == newComponents.length
        ? oldChildren
        : List<Element?>.filled(newComponents.length, null, growable: true);

    // Update the top of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
      final Component newComponent = newComponents[newChildrenTop];
      if (oldChild == null || !Component.canUpdate(oldChild.component, newComponent)) break;
      final Element newChild = updateChild(oldChild, newComponent)!;
      newChildren[newChildrenTop] = newChild;
      newChildrenTop += 1;
      oldChildrenTop += 1;
    }

    // Scan the bottom of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenBottom]);
      final Component newComponent = newComponents[newChildrenBottom];
      if (oldChild == null || !Component.canUpdate(oldChild.component, newComponent)) break;
      oldChildrenBottom -= 1;
      newChildrenBottom -= 1;
    }

    // Scan the old children in the middle of the list.
    final bool haveOldChildren = oldChildrenTop <= oldChildrenBottom;
    Map<Key, Element>? oldKeyedChildren;
    if (haveOldChildren) {
      oldKeyedChildren = <Key, Element>{};
      while (oldChildrenTop <= oldChildrenBottom) {
        final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
        if (oldChild != null) {
          if (oldChild.component.key != null) {
            oldKeyedChildren[oldChild.component.key!] = oldChild;
          } else {
            deactivateChild(oldChild);
          }
        }
        oldChildrenTop += 1;
      }
    }

    // Update the middle of the list.
    while (newChildrenTop <= newChildrenBottom) {
      Element? oldChild;
      final Component newComponent = newComponents[newChildrenTop];
      if (haveOldChildren) {
        final Key? key = newComponent.key;
        if (key != null) {
          oldChild = oldKeyedChildren![key];
          if (oldChild != null) {
            if (Component.canUpdate(oldChild.component, newComponent)) {
              // we found a match!
              // remove it from oldKeyedChildren so we don't unsync it later
              oldKeyedChildren.remove(key);
            } else {
              // Not a match, let's pretend we didn't see it for now.
              oldChild = null;
            }
          }
        }
      }
      final Element newChild = updateChild(oldChild, newComponent)!;
      newChildren[newChildrenTop] = newChild;
      newChildrenTop += 1;
    }

    // We've scanned the whole list.
    newChildrenBottom = newComponents.length - 1;
    oldChildrenBottom = oldChildren.length - 1;

    // Update the bottom of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element oldChild = oldChildren[oldChildrenTop];
      final Component newComponent = newComponents[newChildrenTop];
      final Element newChild = updateChild(oldChild, newComponent)!;
      newChildren[newChildrenTop] = newChild;
      newChildrenTop += 1;
      oldChildrenTop += 1;
    }

    // Clean up any of the remaining middle nodes from the old list.
    if (haveOldChildren && oldKeyedChildren!.isNotEmpty) {
      for (final Element oldChild in oldKeyedChildren.values) {
        if (forgottenChildren == null || !forgottenChildren.contains(oldChild)) deactivateChild(oldChild);
      }
    }

    return newChildren.cast<Element>();
  }

  @override
  void render(DomBuilder b) {
    for (var child in _children!) {
      child.render(b);
    }
  }

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
