part of 'framework.dart';

/// Signature for a function that is called for each [RenderObject].
///
/// Used by [RenderObject.visitChildren].
///
/// The `child` argument must not be null.
typedef RenderObjectVisitor = void Function(RenderObject child);

abstract class RenderObject {
  RenderObject? get parent;

  RenderObject createChildRenderObject();

  void updateElement(String tag, String? id, String? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events);

  void updateText(String text);

  void skipChildren();

  void attach(covariant RenderObject child, {covariant RenderObject? after});

  void remove(covariant RenderObject child);
}

abstract class BuildableRenderObjectElement = BuildableElement with RenderObjectElement;
abstract class ProxyRenderObjectElement = ProxyElement with RenderObjectElement;
abstract class LeafRenderObjectElement = LeafElement with RenderObjectElement;

mixin RenderObjectElement on Element {
  RenderObject createRenderObject() {
    var renderObject = _parentRenderObjectElement!.renderObject.createChildRenderObject();
    assert(renderObject.parent == _parentRenderObjectElement!.renderObject);
    return renderObject;
  }

  void updateRenderObject();

  RenderObject get renderObject => _renderObject!;
  RenderObject? _renderObject;

  @override
  void didMount() {
    if (_renderObject == null) {
      _renderObject = createRenderObject();
      updateRenderObject();
    }
    super.didMount();
  }

  bool _dirtyRender = false;

  bool shouldRerender(covariant Component newComponent) {
    return true;
  }

  @override
  void update(Component newComponent) {
    if (shouldRerender(newComponent)) {
      _dirtyRender = true;
    }
    super.update(newComponent);
  }

  @override
  void didUpdate(Component oldComponent) {
    if (_dirtyRender) {
      _dirtyRender = false;
      updateRenderObject();
    }
    super.didUpdate(oldComponent);
  }

  @override
  void attachRenderObject() {
    var parent = _parentRenderObjectElement?.renderObject;
    if (parent != null) {
      Element? prevElem = _prevAncestorSibling;
      while (prevElem != null && prevElem._lastRenderObjectElement == null) {
        prevElem = prevElem._prevAncestorSibling;
      }
      var after = prevElem?._lastRenderObjectElement;
      parent.attach(renderObject, after: after?.renderObject);
      assert(renderObject.parent == parent);
    }
  }

  @override
  void detachRenderObject() {
    var parent = _parentRenderObjectElement?.renderObject;
    if (parent != null) {
      parent.remove(renderObject);
      assert(renderObject.parent == null);
    }
  }

  @override
  void _didUpdateSlot() {
    super._didUpdateSlot();
    attachRenderObject();
  }

  @override
  RenderObjectElement get _lastRenderObjectElement => this;
}
