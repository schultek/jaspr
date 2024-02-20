part of 'framework.dart';

/// Signature for a function that is called for each [RenderObject].
///
/// Used by [RenderObject.visitChildren].
///
/// The `child` argument must not be null.
typedef RenderObjectVisitor = void Function(RenderObject child);

abstract class RenderObject {
  RenderObject createChildRenderObject();

  void updateElement(String tag, String? id, String? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events);

  void updateText(String text, [bool rawHtml = false]);

  void skipChildren();

  void attach(covariant RenderObject child, {covariant RenderObject? after});

  void remove();
}

abstract class MultiChildRenderObjectElement extends MultiChildElement with RenderObjectElement {
  MultiChildRenderObjectElement(super.component);

  @override
  void update(covariant Component newComponent) {
    super.update(newComponent);
    _dirty = true;
    rebuild();
  }
}

abstract class SingleChildRenderObjectElement extends SingleChildElement with RenderObjectElement {
  SingleChildRenderObjectElement(super.component);

  @override
  void update(covariant Component newComponent) {
    super.update(newComponent);
    _dirty = true;
    rebuild();
  }
}

mixin RenderObjectElement on Element {
  RenderObject createRenderObject() {
    return _parentRenderObjectElement!.renderObject.createChildRenderObject();
  }

  void updateRenderObject();

  RenderObject get renderObject => _renderObject!;
  RenderObject? _renderObject;

  @override
  void _firstBuild([VoidCallback? onBuilt]) {
    if (_renderObject == null) {
      _renderObject = createRenderObject();
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
    var parent = _parentRenderObjectElement?.renderObject;
    if (parent != null) {
      Element? prevElem = _prevAncestorSibling;
      while (prevElem != null && prevElem._lastRenderObjectElement == null) {
        prevElem = prevElem._prevAncestorSibling;
      }
      var after = prevElem?._lastRenderObjectElement;
      parent.attach(renderObject, after: after?.renderObject);
    }
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
