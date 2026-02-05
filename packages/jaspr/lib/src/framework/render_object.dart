part of 'framework.dart';

abstract class RenderObject {
  RenderObject? get parent;
  web.Node? get node;

  RenderElement createChildRenderElement(String tag);
  RenderText createChildRenderText(String text);
  RenderFragment createChildRenderFragment();

  void attach(covariant RenderObject child, {covariant RenderObject? after});

  void remove(covariant RenderObject child);
}

abstract class RenderElement implements RenderObject {
  void update(
    String? id,
    String? classes,
    Map<String, String>? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events,
  );
}

abstract class RenderText implements RenderObject {
  void update(String text);
}

abstract class RawableRenderObject implements RenderObject {
  @override
  RenderText createChildRenderText(String text, [bool rawHtml = false]);
}

abstract class RawableRenderText implements RenderText {
  @override
  void update(String text, [bool rawHtml = false]);
}

abstract class RenderFragment implements RenderObject {}

abstract class MultiChildRenderObjectElement = MultiChildElement with RenderObjectElement;
abstract class LeafRenderObjectElement = LeafElement with RenderObjectElement;

mixin RenderObjectElement on Element {
  @protected
  RenderObject createRenderObject();

  @protected
  void updateRenderObject(covariant RenderObject renderObject);

  RenderObject get renderObject => _renderObject!;
  RenderObject? _renderObject;

  @override
  void didMount() {
    _renderObject ??= createRenderObject();
    super.didMount();
  }

  bool _dirtyRender = false;

  bool shouldRerender(covariant Component newComponent) {
    return true;
  }

  @override
  void didRebuild() {
    super.didRebuild();

    if (!_attached) {
      attachRenderObject();
    }
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
      updateRenderObject(renderObject);
    }
    super.didUpdate(oldComponent);
  }

  bool _attached = false;

  @override
  void attachRenderObject() {
    final parent = _parentRenderObjectElement?.renderObject;
    if (parent != null) {
      final after = slot.previousSibling?.slot.target;
      parent.attach(renderObject, after: after?.renderObject);
      assert(renderObject.parent == parent);
    }
    _attached = true;
  }

  @override
  void detachRenderObject() {
    final parent = _parentRenderObjectElement?.renderObject;
    if (parent != null) {
      parent.remove(renderObject);
      assert(renderObject.parent == null);
    }
    _attached = false;
  }

  @override
  void updateSlot(ElementSlot newSlot) {
    super.updateSlot(newSlot);
    attachRenderObject();
  }
}
