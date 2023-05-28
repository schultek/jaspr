part of framework;

class RenderScope extends Component {
  const RenderScope({required this.delegate, this.shallow = true, this.child, super.key});

  final RenderDelegate delegate;
  final bool shallow;
  final Component? child;

  @override
  RenderScopeElement createElement() => RenderScopeElement(this);
}

class RenderScopeElement extends SingleChildElement {
  RenderScopeElement(RenderScope component) : super(component);

  @override
  RenderScope get component => super.component as RenderScope;

  @override
  Renderer _inheritRendererFromParent() {
    return _ScopedRenderer(super._inheritRendererFromParent(), this);
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

    var oldComponent = component;
    super.update(newComponent);

    var shouldReRenderChildren = oldComponent.delegate.runtimeType != component.delegate.runtimeType ||
        component.delegate.updateShouldNotify(oldComponent.delegate);

    if (shouldReRenderChildren) {
      var renderer = _renderer as _ScopedRenderer;
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
  @mustCallSuper
  void attachNode(RenderElement? element, RenderElement child, RenderElement? after) {
    _parent!.attachNode(element, child, after);
  }

  @protected
  bool updateShouldNotify(covariant RenderDelegate oldDelegate) => false;
}

class _ScopedRenderer implements Renderer {
  final Renderer _parent;
  final RenderScopeElement _scope;

  final Set<RenderElement> _dependents = {};

  _ScopedRenderer(this._parent, this._scope);

  @override
  @protected
  @mustCallSuper
  void renderNode(RenderElement element, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    _dependents.add(element);
    _scope.component.delegate._parent = _parent;
    _scope.component.delegate.renderNode(element, tag, id, classes, styles, attributes, events);
  }

  @override
  @protected
  @mustCallSuper
  void renderTextNode(RenderElement element, String text, [bool rawHtml = false]) {
    _scope.component.delegate._parent = _parent;
    _scope.component.delegate.renderTextNode(element, text, rawHtml);
  }

  @override
  @protected
  @mustCallSuper
  void skipContent(RenderElement element) {
    _scope.component.delegate._parent = _parent;
    _scope.component.delegate.skipContent(element);
  }

  @override
  @protected
  @mustCallSuper
  void attachNode(RenderElement? element, RenderElement child, RenderElement? after) {
    _scope.component.delegate._parent = _parent;
    _scope.component.delegate.attachNode(element, child, after);
  }

  @override
  @protected
  @mustCallSuper
  void finalizeNode(RenderElement element) {
    _parent.finalizeNode(element);
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

  @override
  Renderer inherit(Element parent) {
    if (_scope.component.shallow && parent is RenderElement) {
      return _parent;
    } else {
      return this;
    }
  }
}
