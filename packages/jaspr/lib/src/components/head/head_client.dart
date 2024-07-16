import 'dart:html' as html;

import '../../../browser.dart';

class PlatformHead extends ProxyComponent {
  const PlatformHead({required super.children, super.key});

  @override
  Element createElement() => HeadElement(this);
}

class HeadElement extends ProxyRenderObjectElement {
  HeadElement(super.component);

  @override
  RenderObject createRenderObject() {
    return HeadRenderObject(depth);
  }

  @override
  void updateRenderObject() {}

  @override
  void activate() {
    super.activate();
    (renderObject as HeadRenderObject).depth = depth;
  }

  @override
  void detachRenderObject() {
    super.detachRenderObject();
    (renderObject as HeadRenderObject).unregister();
  }
}

class HeadAdapter {
  static HeadAdapter instance = HeadAdapter();

  static final html.HeadElement head = html.document.head!;

  static final (html.Node, html.Node) headBoundary = () {
    var iterator = html.NodeIterator(head, html.NodeFilter.SHOW_COMMENT);

    html.Node? start, end;

    html.Comment? currNode;
    while ((currNode = iterator.nextNode() as html.Comment?) != null) {
      var value = currNode!.nodeValue ?? '';
      if (value == r'$') {
        start = currNode;
      } else if (value == '/') {
        end = currNode;
      }
    }

    if (start == null) {
      start = html.Comment(r'$');
      head.insertBefore(start, end);
    }
    if (end == null) {
      end = html.Comment('/');
      head.insertBefore(end, start.nextNode);
    }
    return (start, end);
  }();

  static Iterable<html.Node> get liveHeadNodes sync* {
    html.Node? curr = headBoundary.$1.nextNode;
    while (curr != null && curr != headBoundary.$2) {
      yield curr;
      curr = curr.nextNode;
    }
  }

  static final Map<String, html.Node> initialKeyedHeadNodes = {
    for (var node in liveHeadNodes)
      if (keyFor(node) case String key) key: node,
  };

  static String? keyFor(html.Node node) {
    return switch (node) {
      html.Element(id: String id) when id.isNotEmpty => id,
      html.Element(tagName: "TITLE" || "BASE") => '__${node.tagName}',
      html.Element(tagName: "META", attributes: {'name': String name}) => '__meta:$name',
      _ => null,
    };
  }

  HeadAdapter();

  final List<HeadRenderObject> _headRenderObjects = [];
  bool _needsResorting = true;

  void update() {
    if (_needsResorting) {
      _headRenderObjects.sort((a, b) => a._depth - b._depth);
      _needsResorting = false;
    }

    Map<String, html.Node> keyedNodes = Map.of(initialKeyedHeadNodes);
    List<html.Node> children = List.of(initialKeyedHeadNodes.values);

    for (var renderObject in _headRenderObjects) {
      for (var node in renderObject.children) {
        var key = keyFor(node);
        if (key != null) {
          var shadowedNode = keyedNodes[key];
          keyedNodes[key] = node;
          if (shadowedNode != null) {
            children[children.indexOf(shadowedNode)] = node;
            continue;
          }
        }
        children.add(node);
      }
    }

    html.Node? current = headBoundary.$1.nextNode;

    for (var node in children) {
      if (current == null || current == headBoundary.$2) {
        head.insertBefore(node, current);
      } else if (current == node) {
        current = current.nextNode;
      } else if (keyFor(node) != null && keyFor(node) == keyFor(current)) {
        current.replaceWith(node);
        current = node.nextNode;
      } else {
        head.insertBefore(node, current);
      }
    }

    while (current != null && current != headBoundary.$2) {
      var next = current.nextNode;
      current.remove();
      current = next;
    }
  }

  void register(HeadRenderObject renderObject) {
    _headRenderObjects.add(renderObject);
    _needsResorting = true;
  }

  void unregister(HeadRenderObject renderObject) {
    _headRenderObjects.remove(renderObject);
    update();
  }
}

class HeadRenderObject extends DomRenderObject {
  HeadRenderObject(this._depth) {
    node = html.Text('');
    HeadAdapter.instance.register(this);
  }

  final List<html.Node> children = [];

  int _depth;
  set depth(int depth) {
    if (_depth == depth) return;
    _depth = depth;
    HeadAdapter.instance._needsResorting = true;
    HeadAdapter.instance.update();
  }

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    try {
      var childNode = child.node;
      if (childNode == null) return;

      var afterNode = after?.node;
      if (afterNode == null && children.contains(childNode)) {
        // Keep child in current place.
        return;
      }

      if (afterNode != null && !children.contains(afterNode)) {
        afterNode = null;
      }

      children.remove(childNode);
      children.insert(afterNode != null ? children.indexOf(afterNode) + 1 : 0, childNode);
      HeadAdapter.instance.update();
    } finally {
      child.finalize();
    }
  }

  @override
  void remove(DomRenderObject child) {
    super.remove(child);
    children.remove(child.node);
    HeadAdapter.instance.update();
  }

  void unregister() {
    HeadAdapter.instance.unregister(this);
  }
}

class PlatformAttach extends ProxyComponent {
  const PlatformAttach({required this.target, this.attributes, this.events, super.key});

  final String target;
  final Map<String, String>? attributes;
  final EventCallbacks? events;

  @override
  Element createElement() => AttachElement(this);
}

class AttachElement extends ProxyRenderObjectElement {
  AttachElement(PlatformAttach super.component);

  @override
  RenderObject createRenderObject() {
    var PlatformAttach(:target, :attributes, :events) = component as PlatformAttach;
    return AttachRenderObject(target, attributes, events, depth);
  }

  @override
  void updateRenderObject() {
    var PlatformAttach(:target, :attributes, :events) = component as PlatformAttach;
    (renderObject as AttachRenderObject)
      ..target = target
      ..attributes = attributes
      ..aevents = events;
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

class AttachRenderObject extends DomRenderObject {
  AttachRenderObject(this._target, this._attributes, this._events, this._depth) {
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

  EventCallbacks? _events;
  set aevents(EventCallbacks? events) {
    if (_events == events) return;
    _events = events;
    AttachAdapter.instanceFor(_target).update();
  }

  int _depth;
  set depth(int depth) {
    if (_depth == depth) return;
    _depth = depth;
    AttachAdapter.instanceFor(_target)._needsResorting = true;
    AttachAdapter.instanceFor(_target).update();
  }
}

class AttachAdapter {
  static AttachAdapter instanceFor(String target) {
    return _instances[target] ??= AttachAdapter(target);
  }

  static final Map<String, AttachAdapter> _instances = {};

  AttachAdapter(this.target);

  final String target;

  late final html.Element? element = html.querySelector(target);

  late final Map<String, String> initialAttributes = {...?element?.attributes};

  final List<AttachRenderObject> _attachRenderObjects = [];
  bool _needsResorting = true;

  final Map<String, EventBinding> events = {};

  void update() {
    if (_needsResorting) {
      _attachRenderObjects.sort((a, b) => a._depth - b._depth);
      _needsResorting = false;
    }

    Map<String, String> attributes = initialAttributes;
    EventCallbacks events = {};

    for (var renderObject in _attachRenderObjects) {
      assert(renderObject._target == target);
      if (renderObject._attributes case final attrs?) {
        attributes.addAll(attrs);
      }

      if (renderObject._events case final events?) {
        events.addAll(events);
      }
    }

    element?.attributes.clear();
    element?.attributes.addAll(attributes);

    if (element != null && events.isNotEmpty) {
      final prevEventTypes = this.events.keys.toSet();

      events.forEach((type, fn) {
        prevEventTypes.remove(type);
        final currentBinding = this.events[type];
        if (currentBinding != null) {
          currentBinding.fn = fn;
        } else {
          this.events[type] = EventBinding(element!, type, fn);
        }
      });
      prevEventTypes.forEach((type) {
        this.events.remove(type)?.clear();
      });
    } else {
      this.events.forEach((type, binding) {
        binding.clear();
      });
      this.events.clear();
    }
  }

  void register(AttachRenderObject renderObject) {
    _attachRenderObjects.add(renderObject);
    _needsResorting = true;
  }

  void unregister(AttachRenderObject renderObject) {
    _attachRenderObjects.remove(renderObject);
    update();
  }
}
