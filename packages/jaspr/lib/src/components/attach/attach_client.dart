import 'dart:html' as html;

import '../../../browser.dart';

class PlatformAttach extends ProxyComponent {
  const PlatformAttach({required this.target, this.attributes, super.key});

  final String target;
  final Map<String, String>? attributes;

  @override
  Element createElement() => AttachElement(this);
}

class AttachElement extends ProxyRenderObjectElement {
  AttachElement(PlatformAttach super.component);

  @override
  RenderObject createRenderObject() {
    var PlatformAttach(:target, :attributes) = component as PlatformAttach;
    return AttachRenderObject(target, depth);
  }

  @override
  void updateRenderObject() {
    var PlatformAttach(:target, :attributes) = component as PlatformAttach;
    (renderObject as AttachRenderObject)
      ..target = target
      ..attributes = attributes;
  }

  @override
  void activate() {
    super.activate();
    (renderObject as AttachRenderObject).depth = depth;
  }

  @override
  void detachRenderObject() {
    super.detachRenderObject();
    final renderObject = this.renderObject as AttachRenderObject;
    AttachAdapter.instanceFor(renderObject._target).unregister(renderObject);
  }
}

mixin AttachRenderObjectMixin on RenderObject {
  int get depth;
}

class AttachRenderObject extends DomRenderObject with AttachRenderObjectMixin {
  AttachRenderObject(this._target, this._depth) {
    node = html.Text('');
    AttachAdapter.instanceFor(_target).register(this);
  }

  String _target;
  set target(String target) {
    if (_target == target) return;
    AttachAdapter.instanceFor(_target).unregister(this);
    _target = target;
    AttachAdapter.instanceFor(_target).register(this);
    AttachAdapter.instanceFor(_target).update();
  }

  Map<String, String>? _attributes;
  set attributes(Map<String, String>? attrs) {
    if (_attributes == attrs) return;
    _attributes = attrs;
    AttachAdapter.instanceFor(_target).update();
  }

  int _depth;
  @override
  int get depth => _depth;
  set depth(int depth) {
    if (_depth == depth) return;
    _depth = depth;
    AttachAdapter.instanceFor(_target).update(needsResorting: true);
  }
}

mixin AttachAdapterMixin<T extends AttachRenderObjectMixin> {
  final List<T> _renderObjects = [];
  List<T> get renderObjects => _renderObjects;
  bool _needsResorting = true;

  void update({bool needsResorting = false}) {
    if (needsResorting || _needsResorting) {
      _renderObjects.sort((a, b) => a.depth - b.depth);
      _needsResorting = false;
    }

    performUpdate();
  }

  void performUpdate();

  void register(T renderObject) {
    _renderObjects.add(renderObject);
    _needsResorting = true;
  }

  void unregister(T renderObject) {
    _renderObjects.remove(renderObject);
    update();
  }
}

class AttachAdapter with AttachAdapterMixin<AttachRenderObject> {
  AttachAdapter(this.target);

  static AttachAdapter instanceFor(String target) {
    return _instances[target] ??= AttachAdapter(target);
  }

  static final Map<String, AttachAdapter> _instances = {};

  final String target;

  late final html.Element? element = html.querySelector(target);

  late final Map<String, String> initialAttributes = {...?element?.attributes};

  @override
  void performUpdate() {
    if (element == null) return;

    Map<String, String> attributes = initialAttributes;

    for (var renderObject in renderObjects) {
      assert(renderObject._target == target);
      if (renderObject._attributes case final attrs?) {
        attributes.addAll(attrs);
      }
    }

    var attributesToRemove = element!.attributes.keys.toSet();
    if (attributes.isNotEmpty) {
      for (var attr in attributes.entries) {
        element!.clearOrSetAttribute(attr.key, attr.value);
        attributesToRemove.remove(attr.key);
      }
    }

    if (attributesToRemove.isNotEmpty) {
      for (final name in attributesToRemove) {
        element!.removeAttribute(name);
      }
    }
  }
}
