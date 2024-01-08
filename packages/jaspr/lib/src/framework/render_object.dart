part of framework;

/// Signature for a function that is called for each [RenderObject].
///
/// Used by [RenderObject.visitChildren].
///
/// The `child` argument must not be null.
typedef RenderObjectVisitor = void Function(RenderObject child);

abstract class RenderObject<T extends RenderObject<T>> {
  /// The parent of this node in the tree.
  T? get parent => _parent;
  T? _parent;

  T? previousSibling;

  T? nextSibling;

  /// Calls visitor for each immediate child of this render object.
  ///
  /// Override in subclasses with children and call the visitor for each child.
  void visitChildren(RenderObjectVisitor visitor) {}

  T createChildRenderObject();

  void updateElement(String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events);

  void updateText(String text, [bool rawHtml = false]);

  void skipChildren();

  void attach(ElementSlot? slot);

  @mustCallSuper
  void remove() {
    _parent = null;
  }
}

mixin RenderObjectElement on Element {
  void updateRenderObject();

  RenderObject<dynamic> get renderObject => _renderObject!;
  RenderObject<dynamic>? _renderObject;

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
    if (_renderObject == null) {
      _ancestorRenderObjectElement = _findAncestorRenderObjectElement();
      _renderObject = _ancestorRenderObjectElement!.renderObject.createChildRenderObject();
      updateRenderObject();
    }
    super._firstBuild(() {
      attachRenderObject(slot);
      onBuilt?.call();
    });
  }

  @override
  void attachRenderObject(ElementSlot? newSlot) {
    assert(_ancestorRenderObjectElement == null);
    _slot = newSlot;
    renderObject.attach(newSlot);
  }

  @override
  void detachRenderObject() {
    renderObject.remove();
    if (_ancestorRenderObjectElement != null) {
      _ancestorRenderObjectElement = null;
    }
    _slot = null;
  }
}
