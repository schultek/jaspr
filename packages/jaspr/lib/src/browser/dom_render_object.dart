import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../foundation/constants.dart';
import '../foundation/events/events.dart';
import '../framework/framework.dart';

const htmlns = 'http://www.w3.org/1999/xhtml';
const xmlns = {
  'svg': 'http://www.w3.org/2000/svg',
  'math': 'http://www.w3.org/1998/Math/MathML',
};

class DomRenderObject extends RenderObject {
  web.Node? node;
  List<web.Node> toHydrate = [];

  Map<String, EventBinding>? events;

  @override
  DomRenderObject? parent;

  void clearEvents() {
    events?.forEach((type, binding) {
      binding.clear();
    });
    events = null;
  }

  @override
  DomRenderObject createChildRenderObject() {
    return DomRenderObject()..parent = this;
  }

  web.Element _createElement(String tag, String? namespace) {
    if (namespace != null && namespace != htmlns) {
      return web.document.createElementNS(namespace, tag);
    }
    return web.document.createElement(tag);
  }

  @override
  void updateElement(String tag, String? id, String? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    late Set<String> attributesToRemove;
    late web.Element elem;

    var namespace = xmlns[tag];
    if ((namespace, parent?.node) case (== null, web.Element pnode)) {
      namespace = pnode.namespaceURI;
    }

    diff:
    if (node == null) {
      if (parent!.toHydrate.isNotEmpty) {
        for (var e in parent!.toHydrate) {
          if (e.instanceOfString('Element') && (e as web.Element).tagName.toLowerCase() == tag) {
            if (kVerboseMode) {
              print("Hydrate html node: $e");
            }
            elem = node = e;
            attributesToRemove = {};
            for (var i = 0; i < elem.attributes.length; i++) {
              attributesToRemove.add(elem.attributes.item(i)!.name);
            }
            parent!.toHydrate.remove(e);
            toHydrate = e.childNodes.toIterable().toList();
            break diff;
          }
        }
      }

      elem = node = _createElement(tag, namespace);
      attributesToRemove = {};
      if (kVerboseMode) {
        print("Create html node: $elem");
      }
    } else {
      if (node.instanceOfString('Element') || (node as web.Element).tagName.toLowerCase() != tag) {
        elem = _createElement(tag, namespace);
        var old = node!;
        node!.parentNode!.replaceChild(elem, old);
        node = elem;
        if (old.childNodes.length > 0) {
          var oldChildren = old.childNodes.toIterable();
          for (var child in oldChildren) {
            elem.append(child as dynamic);
          }
        }
        attributesToRemove = {};
        if (kVerboseMode) {
          print("Replace html node: $elem for $old");
        }
      } else {
        elem = node as web.Element;
        attributesToRemove = {};
        for (var i = 0; i < elem.attributes.length; i++) {
          attributesToRemove.add(elem.attributes.item(i)!.name);
        }
      }
    }

    elem.clearOrSetAttribute('id', id);
    elem.clearOrSetAttribute('class', classes == null || classes.isEmpty ? null : classes);
    elem.clearOrSetAttribute('style',
        styles == null || styles.isEmpty ? null : styles.entries.map((e) => '${e.key}: ${e.value}').join('; '));

    if (attributes != null && attributes.isNotEmpty) {
      for (var attr in attributes.entries) {
        if (attr.key == 'value' &&
            elem.instanceOfString('HTMLInputElement') &&
            (elem as web.HTMLInputElement).value != attr.value) {
          if (kVerboseMode) {
            print("Set input value: ${attr.value}");
          }
          elem.value = attr.value;
          continue;
        }
        elem.clearOrSetAttribute(attr.key, attr.value);
      }
    }

    attributesToRemove.removeAll(['id', 'class', 'style', ...?attributes?.keys]);
    if (attributesToRemove.isNotEmpty) {
      for (final name in attributesToRemove) {
        elem.removeAttribute(name);
        if (kVerboseMode) {
          print("Remove attribute: $name");
        }
      }
    }

    if (events != null && events.isNotEmpty) {
      final prevEventTypes = this.events?.keys.toSet();
      this.events ??= <String, EventBinding>{};
      final dataEvents = this.events!;
      events.forEach((type, fn) {
        prevEventTypes?.remove(type);
        final currentBinding = dataEvents[type];
        if (currentBinding != null) {
          currentBinding.fn = fn as dynamic;
        } else {
          dataEvents[type] = EventBinding(elem, type, fn as dynamic);
        }
      });
      prevEventTypes?.forEach((type) {
        dataEvents.remove(type)?.clear();
      });
    } else {
      clearEvents();
    }
  }

  @override
  void updateText(String text) {
    diff:
    if (node == null) {
      var toHydrate = parent!.toHydrate;
      if (toHydrate.isNotEmpty) {
        for (var e in toHydrate) {
          if (e.instanceOfString('Text')) {
            if (kVerboseMode) {
              print("Hydrate text node: $e");
            }
            node = e;
            if (e.textContent != text) {
              e.textContent = text;
              if (kVerboseMode) {
                print("Update text node: $text");
              }
            }
            toHydrate.remove(e);
            break diff;
          }
        }
      }

      node = web.Text(text);
      if (kVerboseMode) {
        print("Create text node: $text");
      }
    } else {
      if (!node.instanceOfString('Text')) {
        var elem = web.Text(text);
        (node as web.Element).replaceWith(elem as dynamic);
        node = elem;
        if (kVerboseMode) {
          print("Replace text node: $text");
        }
      } else {
        var node = this.node as web.Text;
        if (node.textContent != text) {
          node.textContent = text;
          if (kVerboseMode) {
            print("Update text node: $text");
          }
        }
      }
    }
  }

  @override
  void skipChildren() {
    parent!.toHydrate.clear();
  }

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    try {
      child.parent = this;

      var parentNode = node;
      var childNode = child.node;

      assert(parentNode.instanceOfString('Element'));
      if (childNode == null) return;

      var afterNode = after?.node;

      if (childNode.previousSibling == afterNode && childNode.parentNode == parentNode) {
        return;
      }

      if (kVerboseMode) {
        print("Attach node $childNode of $parentNode after $afterNode");
      }

      if (afterNode == null) {
        parentNode!.insertBefore(childNode, parentNode.childNodes.item(0));
      } else {
        parentNode!.insertBefore(childNode, afterNode.nextSibling);
      }
    } finally {
      child.finalize();
    }
  }

  @override
  void remove(DomRenderObject child) {
    if (kVerboseMode) {
      print("Remove child $child of $this");
    }
    child.node?.parentNode!.removeChild(child.node!);
    child.parent = null;
  }

  void finalize() {
    if (kVerboseMode && toHydrate.isNotEmpty) {
      print("Clear ${toHydrate.length} nodes not hydrated ($toHydrate)");
    }
    for (var node in toHydrate) {
      node.parentNode!.removeChild(node);
    }
    toHydrate.clear();
  }
}

class RootDomRenderObject extends DomRenderObject {
  final web.Element container;
  late final web.Node? beforeStart;

  RootDomRenderObject(this.container, [List<web.Node>? nodes]) {
    node = container;
    toHydrate = [...nodes ?? container.childNodes.toIterable()];
    beforeStart = toHydrate.firstOrNull?.previousSibling;
  }

  factory RootDomRenderObject.between(web.Node start, web.Node end) {
    var nodes = <web.Node>[];
    web.Node? curr = start.nextSibling;
    while (curr != null && curr != end) {
      nodes.add(curr);
      curr = curr.nextSibling;
    }
    return RootDomRenderObject(start.parentElement!, nodes);
  }

  @override
  void attach(covariant DomRenderObject child, {covariant DomRenderObject? after}) {
    super.attach(child, after: after?.node != null ? after : (DomRenderObject()..node = beforeStart));
  }
}

typedef DomEventCallback = void Function(web.Event event);

class EventBinding {
  final String type;
  DomEventCallback fn;
  StreamSubscription? subscription;

  EventBinding(web.Element element, this.type, this.fn) {
    web.EventStreamProvider<web.Event>(type).forElement(element).listen((event) {
      fn(event);
    });
  }

  void clear() {
    subscription?.cancel();
    subscription = null;
  }
}

extension AttributeOperation on web.Element {
  void clearOrSetAttribute(String name, String? value) {
    final current = getAttribute(name);
    if (current == value) return;
    if (value == null) {
      if (kVerboseMode) {
        print("Remove attribute: $name");
      }
      removeAttribute(name);
    } else {
      if (kVerboseMode) {
        print("Update attribute: $name - $value");
      }
      setAttribute(name, value);
    }
  }
}

extension on web.NodeList {
  Iterable<web.Node> toIterable() sync* {
    for (var i = 0; i < length; i++) {
      yield item(i)!;
    }
  }
}
