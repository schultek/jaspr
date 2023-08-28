part of framework;

/// Signature for a function that is called for each [RenderObject].
///
/// Used by [RenderObject.visitChildren].
///
/// The `child` argument must not be null.
typedef RenderObjectVisitor = void Function(RenderObject child);

abstract class RenderObject {
  /// The parent of this node in the tree.
  RenderObject? get parent => _parent;
  RenderObject? _parent;

  RenderObject? previousSibling;

  RenderObject? nextSibling;

  /// Calls visitor for each immediate child of this render object.
  ///
  /// Override in subclasses with children and call the visitor for each child.
  void visitChildren(RenderObjectVisitor visitor) {}
}

abstract class MultiChildRenderObject extends RenderObject {
  /// The number of children.
  int get childCount => _childCount;
  int _childCount = 0;

  /// The first child in the child list.
  RenderObject? get firstChild => _firstChild;
  RenderObject? _firstChild;

  /// The last child in the child list.
  RenderObject? get lastChild => _lastChild;
  RenderObject? _lastChild;

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    RenderObject? child = _firstChild;
    while (child != null) {
      visitor(child);
      child = child.nextSibling;
    }
  }

  /// Insert child into this render object's child list after the given child.
  ///
  /// If `after` is null, then this inserts the child at the start of the list,
  /// and the child becomes the new [firstChild].
  void insert(RenderObject child, {RenderObject? after}) {
    assert(child != this, 'A RenderObject cannot be inserted into itself.');
    assert(after != this,
        'A RenderObject cannot simultaneously be both the parent and the sibling of another RenderObject.');
    assert(child != after, 'A RenderObject cannot be inserted after itself.');
    assert(child != _firstChild);
    assert(child != _lastChild);
    child._parent = this;
    _insertIntoChildList(child, after: after);
  }

  void _insertIntoChildList(RenderObject child, {RenderObject? after}) {
    assert(child.nextSibling == null);
    assert(child.previousSibling == null);
    _childCount += 1;
    assert(_childCount > 0);
    if (after == null) {
      // insert at the start (_firstChild)
      child.nextSibling = _firstChild;
      if (_firstChild != null) {
        _firstChild!.previousSibling = child;
      }
      _firstChild = child;
      _lastChild ??= child;
    } else {
      assert(_firstChild != null);
      assert(_lastChild != null);
      assert(_debugUltimatePreviousSiblingOf(after, equals: _firstChild));
      assert(_debugUltimateNextSiblingOf(after, equals: _lastChild));
      if (after.nextSibling == null) {
        // insert at the end (_lastChild); we'll end up with two or more children
        assert(after == _lastChild);
        child.previousSibling = after;
        after.nextSibling = child;
        _lastChild = child;
      } else {
        // insert in the middle; we'll end up with three or more children
        // set up links from child to siblings
        child.nextSibling = after.nextSibling;
        child.previousSibling = after;
        // set up links from siblings to child
        child.previousSibling!.nextSibling = child;
        child.nextSibling!.previousSibling = child;
        assert(after.nextSibling == child);
      }
    }
  }

  /// Remove this child from the child list.
  ///
  /// Requires the child to be present in the child list.
  void remove(RenderObject child) {
    _removeFromChildList(child);
    child._parent = null;
  }

  void _removeFromChildList(RenderObject child) {
    assert(_debugUltimatePreviousSiblingOf(child, equals: _firstChild));
    assert(_debugUltimateNextSiblingOf(child, equals: _lastChild));
    assert(_childCount >= 0);
    if (child.previousSibling == null) {
      assert(_firstChild == child);
      _firstChild = child.nextSibling;
    } else {
      child.previousSibling!.nextSibling = child.nextSibling;
    }
    if (child.nextSibling == null) {
      assert(_lastChild == child);
      _lastChild = child.previousSibling;
    } else {
      child.nextSibling!.previousSibling = child.previousSibling;
    }
    child.previousSibling = null;
    child.nextSibling = null;
    _childCount -= 1;
  }

  bool _debugUltimatePreviousSiblingOf(RenderObject child, {RenderObject? equals}) {
    while (child.previousSibling != null) {
      assert(child.previousSibling != child);
      child = child.previousSibling!;
    }
    return child == equals;
  }

  bool _debugUltimateNextSiblingOf(RenderObject child, {RenderObject? equals}) {
    while (child.nextSibling != null) {
      assert(child.nextSibling != child);
      child = child.nextSibling!;
    }
    return child == equals;
  }
}

mixin RenderObjectElement on Element {
  /// Creates an instance of the [RenderObject] class that this
  /// [RenderObjectElement] represents, using the configuration described by this
  /// [RenderObjectComponent].
  @protected
  @factory
  RenderObject createRenderObject(BuildContext context);

  RenderObject get renderObject => _renderObject!;
  RenderObject? _renderObject;

  RenderObjectElement? _ancestorRenderObjectElement;

  RenderObjectElement? _findAncestorRenderObjectElement() {
    Element? ancestor = _parent;
    while (ancestor != null && ancestor is! RenderObjectElement) {
      ancestor = ancestor._parent;
    }
    return ancestor as RenderObjectElement?;
  }

  @override
  void _firstBuild([VoidCallback? onBuilt]) {
    _renderObject = createRenderObject(this);
    // renderer.render(_renderObject);
    super._firstBuild(() {
      attachRenderObject(slot);
      onBuilt?.call();
    });
  }

  @override
  void attachRenderObject(ElementSlot? newSlot) {
    assert(_ancestorRenderObjectElement == null);
    _slot = newSlot;
    _ancestorRenderObjectElement = _findAncestorRenderObjectElement();
    if (_ancestorRenderObjectElement case MultiChildRenderObject ancestor) {
      ancestor.insert(renderObject, newSlot.previousSibling.lastChildRenderObject);
    }
  }

  @override
  void detachRenderObject() {
    if (_ancestorRenderObjectElement != null) {
      if (_ancestorRenderObjectElement case MultiChildRenderObject ancestor) {
        renderer.remove(renderObject);
        ancestor.remove(renderObject);
      }
      _ancestorRenderObjectElement = null;
    }
    _slot = null;
  }
}

abstract class Renderer {
  void render(RenderObject renderObject);

  void attach(RenderObject renderObject);

  void remove(RenderObject renderObject);
}
