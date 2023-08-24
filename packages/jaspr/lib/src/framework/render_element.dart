part of framework;

mixin RenderElement on Element {
  @override
  RenderElement get _lastNode => this;

  /// Arbitrary data the renderer can use
  dynamic renderData;

  void _render() {
    renderNode(_renderer!);
  }

  void _attach() {
    Element? prevElem = _prevAncestorSibling;
    while (prevElem != null && prevElem._lastNode == null) {
      prevElem = prevElem._prevAncestorSibling;
    }
    var after = prevElem?._lastNode;
    _renderer!.attachNode(_parentNode, this, after);
  }

  void _remove() {
    _renderer!.removeChild(_parentNode!, this);
  }

  @override
  void _firstBuild([VoidCallback? onBuilt]) {
    _render();
    super._firstBuild(() {
      _attach();
      onBuilt?.call();
    });
  }

  @override
  void update(Component newComponent) {
    super.update(newComponent);
    _render();
  }

  @protected
  void renderNode(Renderer renderer);

  @override
  void _didChangeAncestorSibling() {
    super._didChangeAncestorSibling();
    assert(_parentNode != null);
    _attach();
  }

  @override
  void performRebuild() {
    super.performRebuild();
    _renderer!.finalizeNode(this);
  }

  @override
  void unmount() {
    super.unmount();
    var renderer = _renderer;
    if (renderer is _ScopedRenderer) {
      renderer._release(this);
    }
  }
}

abstract class Renderer {
  void renderNode(RenderElement element, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events);

  void renderTextNode(RenderElement element, String text, [bool rawHtml = false]);

  void skipContent(RenderElement element);

  void attachNode(RenderElement? parent, RenderElement child, RenderElement? after);

  void finalizeNode(RenderElement element);

  void removeChild(RenderElement parent, RenderElement child);

  Renderer inherit(Element parent) => this;
}
