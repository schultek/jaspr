part of framework;

mixin RenderElement on Element {

  @override
  RenderElement get _lastNode => this;

  RenderElement get parentNode => _parentNode!;

  Renderer get renderer => _renderer!;

  /// Arbitrary data the renderer can use
  dynamic _data;

  dynamic getData() => _data;
  dynamic setData(dynamic data) => _data = data;

  @override
  Renderer? _inheritRenderer() {
    var renderer = _renderer;
    if (renderer is _DelegatingRenderer && renderer._shallow == true) {
      return renderer._parent;
    }
    return renderer;
  }

  void _render() {
    renderNode(_renderer!);
  }

  void _attach() {
    _parentNode?.renderChildNode(this);
  }

  void _remove() {
    _renderer!.removeChild(_parentNode!, this);
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
    _renderer!.didPerformRebuild(this);
  }

  @override
  void unmount() {
    super.unmount();
    var renderer = _renderer;
    if (renderer is _DelegatingRenderer) {
      renderer._release(this);
    }
  }

  void renderChildNode(RenderElement child) {
    Element? prevElem = child._prevAncestorSibling;
    while (prevElem != null && prevElem._lastNode == null) {
      prevElem = prevElem._prevAncestorSibling;
    }
    var after = prevElem?._lastNode;
    _renderer!.renderChildNode(this, child, after);
  }
}

abstract class Renderer {
  void setRootNode(RenderElement element);

  void renderNode(RenderElement element, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events);

  void renderTextNode(RenderElement element, String text, [bool rawHtml = false]);

  void skipContent(RenderElement element);

  void renderChildNode(RenderElement element, RenderElement child, RenderElement? after);

  void didPerformRebuild(RenderElement element);

  void removeChild(RenderElement parent, RenderElement child);
}
