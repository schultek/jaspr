part of framework;

/// Signature for a function that is called for each [RenderObject].
///
/// Used by [RenderObject.visitChildren].
///
/// The `child` argument must not be null.
typedef RenderObjectVisitor = void Function(RenderObject child);

abstract class RenderObject {
  RenderObject createChildRenderObject();

  void updateElement(String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events);

  void updateText(String text, [bool rawHtml = false]);

  void skipChildren();

  void attach(covariant RenderObject? parent, covariant RenderObject? after);

  void remove();
}

mixin RenderObjectElement on Element {
  void updateRenderObject();

  RenderObject get renderObject => _renderObject!;
  RenderObject? _renderObject;

  @override
  void _firstBuild([VoidCallback? onBuilt]) {
    if (_renderObject == null) {
      _renderObject = _parentRenderObjectElement!.renderObject.createChildRenderObject();
      updateRenderObject();
    }
    super._firstBuild(() {
      attachRenderObject();
      onBuilt?.call();
    });
  }

  @override
  void update(Component newComponent) {
    super.update(newComponent);
    updateRenderObject();
  }

  void attachRenderObject() {
    Element? prevElem = _prevAncestorSibling;
    while (prevElem != null && prevElem._lastRenderObjectElement == null) {
      prevElem = prevElem._prevAncestorSibling;
    }
    var after = prevElem?._lastRenderObjectElement;
    renderObject.attach(_parentRenderObjectElement?.renderObject, after?.renderObject);
  }

  void detachRenderObject() {
    renderObject.remove();
  }

  @override
  void _didUpdateSlot() {
    super._didUpdateSlot();
    attachRenderObject();
  }

  @override
  RenderObjectElement get _lastRenderObjectElement => this;
}
