import 'dart:async';

import 'package:web/web.dart' as web;

import '../foundation/constants.dart';
import '../foundation/events/events.dart';
import '../framework/framework.dart';

const xmlns = {
  'svg': 'http://www.w3.org/2000/svg',
};

class DomRenderObject extends RenderObject {
  DomRenderObject? parent;
  String? namespace;
  web.Node? node;
  List<web.Node> toHydrate = [];
  Map<String, EventBinding>? events;

  void clearEvents() {
    events?.forEach((type, binding) {
      binding.clear();
    });
    events = null;
  }

  @override
  DomRenderObject createChildRenderObject() {
    return DomRenderObject()
      ..parent = this
      ..namespace = namespace;
  }

  web.Element _createElement(String tag) {
    namespace = xmlns[tag] ?? namespace;
    if (namespace != null) {
      return web.document.createElementNS(namespace!, tag);
    }
    return web.document.createElement(tag);
  }

  @override
  void updateElement(String tag, String? id, String? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    late Set<String> attributesToRemove;
    late web.Element elem;

    diff:
    if (node == null) {
      var toHydrate = parent!.toHydrate;
      if (toHydrate.isNotEmpty) {
        for (var e in toHydrate) {
          if (e is web.Element && e.tagName.toLowerCase() == tag) {
            if (kVerboseMode) {
              print("Hydrate html node: $e");
            }
            elem = node = e;
            attributesToRemove = {};
            for (var i = 0; i < elem.attributes.length; i++) {
              attributesToRemove.add(elem.attributes.item(i)!.name);
            }
            toHydrate.remove(e);
            var nodes = e.childNodes.toIterable();
            if (kDebugMode) {
              nodes = nodes.where((node) => node is! web.Text || (node.textContent ?? '').trim().isNotEmpty);
            }
            this.toHydrate = nodes.toList();
            break diff;
          }
        }
      }

      elem = node = _createElement(tag);
      attributesToRemove = {};
      if (kVerboseMode) {
        print("Create html node: $elem");
      }
    } else {
      if (node is! web.Element || (node as web.Element).tagName.toLowerCase() != tag) {
        elem = _createElement(tag);
        var old = node;
        if (node case web.Element node) {
          node.replaceWith(elem as dynamic);
        } else if (node case web.Text node) {
          node.replaceWith(elem as dynamic);
        }
        node = elem;
        if (old != null && old.childNodes.length > 0) {
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
        if (attr.key == 'value' && elem is web.HTMLInputElement && elem.value != attr.value) {
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
  void updateText(String text, [bool rawHtml = false]) {
    if (rawHtml) {
      var parent = this.parent!.node;
      if (parent is web.Element) {
        if (parent.innerHTML != text) {
          parent.innerHTML = text;
          node = parent.childNodes.item(0);
          if (kVerboseMode) {
            print("Update inner html: $text");
          }
        }
        this.parent!.toHydrate.clear();
      }
      return;
    }

    diff:
    if (node == null) {
      var toHydrate = parent!.toHydrate;
      if (toHydrate.isNotEmpty) {
        for (var e in toHydrate) {
          if (e is web.Text) {
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
      if (node is! web.Text) {
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
  void attach(DomRenderObject? parent, DomRenderObject? after) {
    try {
      this.parent = parent;
      namespace = parent?.namespace;
      if (parent == null) return;

      var parentNode = parent.node;
      var childNode = node;

      assert(parentNode is web.Element);
      if (childNode == null) return;

      var afterNode = after?.node;
      if (afterNode == null && parent is RootDomRenderObject) {
        afterNode = parent.beforeStart;
      }

      if (childNode.previousSibling == afterNode && childNode.parentNode == parentNode) {
        return;
      }

      if (kVerboseMode) {
        print("Attach node $childNode of $parentNode after $afterNode");
      }

      if (afterNode == null) {
        if (parentNode!.childNodes.length == 0) {
          parentNode.append(childNode);
        } else {
          parentNode.insertBefore(childNode, parentNode.childNodes.item(0));
        }
      } else {
        parentNode!.insertBefore(childNode, afterNode.nextSibling);
      }
    } finally {
      _finalize();
    }
  }

  @override
  void remove() {
    if (kVerboseMode) {
      print("Remove child $node of ${parent?.node}");
    }
    node?.remove();
    parent = null;
    namespace = null;
  }

  void _finalize() {
    if (kVerboseMode && toHydrate.isNotEmpty) {
      print("Clear ${toHydrate.length} nodes not hydrated ($toHydrate)");
    }
    for (var node in toHydrate) {
      node.remove();
    }
    toHydrate.clear();
  }
}

class RootDomRenderObject extends DomRenderObject {
  final web.Element container;
  late final web.Node? beforeStart;

  RootDomRenderObject(this.container, [List<web.Node>? nodes]) {
    node = container;
    toHydrate = nodes ?? container.childNodes.toIterable().toList();
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

extension on web.Element {
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

extension on web.Node {
  void remove() {
    (switch (this) {
      web.Element() => remove(),
      web.CharacterData() => remove(),
      _ => (),
    });
  }
}

extension on web.NodeList {
  Iterable<web.Node> toIterable() sync* {
    for (var i = 0; i < length; i++) {
      yield item(i)!;
    }
  }
}
