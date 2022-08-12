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
    if (renderer is DelegatingRenderer && renderer._shallow == true) {
      return renderer._parent;
    }
    return renderer;
  }

  void mountNode() {
    renderNode(_renderer!);
  }

  void attachNode() {
    _parentNode?.renderChildNode(this);
  }

  @override
  void update(Component newComponent) {
    super.update(newComponent);
    renderNode(_renderer!);
  }

  void _remove() {
    _renderer!.removeChild(_parentNode!, this);
  }

  @protected
  void renderNode(Renderer renderer);

  @override
  void _didChangeAncestorSibling() {
    super._didChangeAncestorSibling();
    assert(_parentNode != null);
    attachNode();
  }

  @override
  void performRebuild() {
    super.performRebuild();
    _renderer!.didPerformRebuild(this);
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

class RenderScope extends Component {

  const RenderScope({required this.renderer, this.shallow = true, this.children = const [], super.key});

  final DelegatingRenderer renderer;
  final bool shallow;
  final List<Component> children;

  @override
  _RenderScopeElement createElement() => _RenderScopeElement(this);
}

class _RenderScopeElement extends MultiChildElement {

  _RenderScopeElement(RenderScope component) : super(component);

  @override
  RenderScope get component => super.component as RenderScope;

  @override
  void mount(Element? parent, Element? prevSibling) {
    super.mount(parent, prevSibling);
    component.renderer._parent = _renderer;
    component.renderer._shallow = component.shallow;
    _renderer = component.renderer;
  }

  @override
  Iterable<Component> build() => component.children;

  @override
  void update(RenderScope newComponent) {
    assert(() {
      if (component.shallow != newComponent.shallow) {
        throw 'Changing the shallow property on RenderScope is currently not supported.';
      }
      return true;
    }());

    super.update(newComponent);

    var oldRenderer = _renderer as DelegatingRenderer;
    component.renderer._parent = oldRenderer._parent;
    component.renderer._shallow = component.shallow;
    _renderer = component.renderer;

    var shouldReRenderChildren = oldRenderer.runtimeType != component.renderer.runtimeType
        || component.renderer.updateShouldNotify(oldRenderer);

    if (shouldReRenderChildren) {
      // TODO
    }

    _dirty = true;
    rebuild();
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

  @protected
  bool updateShouldNotify(covariant Renderer oldRenderer) => false;
}

abstract class DelegatingRenderer implements Renderer {
  Renderer? _parent;
  bool? _shallow;

  @override
  @protected
  @mustCallSuper
  void setRootNode(RenderElement node) {
    _parent!.setRootNode(node);
  }

  @override
  @protected
  @mustCallSuper
  void renderNode(RenderElement node, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    _parent!.renderNode(node, tag, id, classes, styles, attributes, events);
  }

  @override
  @protected
  @mustCallSuper
  void renderTextNode(RenderElement node, String text, [bool rawHtml = false]) {
    _parent!.renderTextNode(node, text, rawHtml);
  }

  @override
  @protected
  @mustCallSuper
  void skipContent(RenderElement node) {
    _parent!.skipContent(node);
  }

  @override
  @protected
  @mustCallSuper
  void renderChildNode(RenderElement node, RenderElement child, RenderElement? after) {
    _parent!.renderChildNode(node, child, after);
  }

  @override
  @protected
  @mustCallSuper
  void didPerformRebuild(RenderElement node) {
    _parent!.didPerformRebuild(node);
  }

  @override
  @protected
  @mustCallSuper
  void removeChild(RenderElement parent, RenderElement child) {
    _parent!.removeChild(parent, child);
  }
}
