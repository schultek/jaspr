part of framework;

class RenderScope extends Component {

  const RenderScope({required this.delegate, this.shallow = true, this.child, super.key});

  final RenderDelegate delegate;
  final bool shallow;
  final Component? child;

  @override
  _RenderScopeElement createElement() => _RenderScopeElement(this);
}

class _RenderScopeElement extends SingleChildElement {

  _RenderScopeElement(RenderScope component) : super(component);

  @override
  RenderScope get component => super.component as RenderScope;

  @override
  void mount(Element? parent, Element? prevSibling) {
    super.mount(parent, prevSibling);
    _renderer = _DelegatingRenderer(
        _renderer!,
        component.shallow,
        component.delegate
    );
  }

  @override
  Component? build() => component.child;

  @override
  void update(RenderScope newComponent) {
    assert(() {
      if (component.shallow != newComponent.shallow) {
        throw 'Changing the shallow property on RenderScope is currently not supported.';
      }
      return true;
    }());

    super.update(newComponent);

    var renderer = _renderer as _DelegatingRenderer;
    var oldDelegate = renderer._delegate;
    renderer._delegate = component.delegate;

    var shouldReRenderChildren = oldDelegate.runtimeType != component.delegate.runtimeType
        || component.delegate.updateShouldNotify(oldDelegate);

    if (shouldReRenderChildren) {
      for (var element in renderer._dependents) {
        element._render();
      }
    }

    _dirty = true;
    rebuild();
  }
}


abstract class RenderDelegate {
  Renderer? _parent;

  @protected
  @mustCallSuper
  void renderNode(RenderElement node, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    _parent!.renderNode(node, tag, id, classes, styles, attributes, events);
  }

  @protected
  @mustCallSuper
  void renderTextNode(RenderElement node, String text, [bool rawHtml = false]) {
    _parent!.renderTextNode(node, text, rawHtml);
  }

  @protected
  @mustCallSuper
  void skipContent(RenderElement node) {
    _parent!.skipContent(node);
  }

  @protected
  bool updateShouldNotify(covariant RenderDelegate oldDelegate) => false;
}

class _DelegatingRenderer implements Renderer {
  final Renderer _parent;
  final bool _shallow;

  RenderDelegate _delegate;
  final Set<RenderElement> _dependents = {};

  _DelegatingRenderer(this._parent, this._shallow, this._delegate);

  @override
  @protected
  @mustCallSuper
  void setRootNode(RenderElement element) {
    _parent.setRootNode(element);
  }

  @override
  @protected
  @mustCallSuper
  void renderNode(RenderElement element, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    _dependents.add(element);
    _delegate._parent = _parent;
    _delegate.renderNode(element, tag, id, classes, styles, attributes, events);
  }

  @override
  @protected
  @mustCallSuper
  void renderTextNode(RenderElement element, String text, [bool rawHtml = false]) {
    _delegate._parent = _parent;
    _delegate.renderTextNode(element, text, rawHtml);
  }

  @override
  @protected
  @mustCallSuper
  void skipContent(RenderElement element) {
    _delegate._parent = _parent;
    _delegate.skipContent(element);
  }

  @override
  @protected
  @mustCallSuper
  void renderChildNode(RenderElement element, RenderElement child, RenderElement? after) {
    _parent.renderChildNode(element, child, after);
  }

  @override
  @protected
  @mustCallSuper
  void didPerformRebuild(RenderElement element) {
    _parent.didPerformRebuild(element);
  }

  @override
  @protected
  @mustCallSuper
  void removeChild(RenderElement parent, RenderElement child) {
    _parent.removeChild(parent, child);
  }

  void _release(RenderElement element) {
    _dependents.remove(element);
  }

}
