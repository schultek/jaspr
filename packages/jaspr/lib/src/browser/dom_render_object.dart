import 'dart:async';
import 'dart:html' as html show Element, Text;
import 'dart:html';

import '../foundation/constants.dart';
import '../foundation/events/events.dart';
import '../framework/framework.dart';

const htmlns = 'http://www.w3.org/1999/xhtml';
const xmlns = {
  'svg': 'http://www.w3.org/2000/svg',
  'math': 'http://www.w3.org/1998/Math/MathML',
};

class DomRenderObject extends RenderObject {
  Node? node;
  List<Node> toHydrate = [];
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

  html.Element _createElement(String tag, String? namespace) {
    if (namespace != null && namespace != htmlns) {
      return document.createElementNS(namespace, tag);
    }
    return document.createElement(tag);
  }

  @override
  void updateElement(String tag, String? id, String? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    late Set<String> attributesToRemove;
    late html.Element elem;

    var namespace = xmlns[tag];
    if ((namespace, parent?.node) case (== null, html.Element pnode)) {
      namespace = pnode.namespaceUri;
    }

    diff:
    if (node == null) {
      var toHydrate = parent!.toHydrate;
      if (toHydrate.isNotEmpty) {
        for (var e in toHydrate) {
          if (e is html.Element && e.tagName.toLowerCase() == tag) {
            if (kVerboseMode) {
              print("Hydrate html node: $e");
            }
            elem = node = e;
            attributesToRemove = elem.attributes.keys.toSet();
            toHydrate.remove(e);
            Iterable<Node> nodes = e.nodes;
            if (kDebugMode) {
              nodes = nodes.where((node) => node is! html.Text || (node.text ?? '').trim().isNotEmpty);
            }
            this.toHydrate = nodes.toList();
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
      if (node is! html.Element || (node as html.Element).tagName.toLowerCase() != tag) {
        elem = _createElement(tag, namespace);
        var old = node;
        node!.replaceWith(elem);
        node = elem;
        if (old != null && old.childNodes.isNotEmpty) {
          var oldChildren = [...old.childNodes];
          for (var child in oldChildren) {
            elem.append(child);
          }
        }
        attributesToRemove = {};
        if (kVerboseMode) {
          print("Replace html node: $elem for $old");
        }
      } else {
        elem = node as html.Element;
        attributesToRemove = elem.attributes.keys.toSet();
      }
    }

    elem.clearOrSetAttribute('id', id);
    elem.clearOrSetAttribute('class', classes == null || classes.isEmpty ? null : classes);
    elem.clearOrSetAttribute('style',
        styles == null || styles.isEmpty ? null : styles.entries.map((e) => '${e.key}: ${e.value}').join('; '));

    if (attributes != null && attributes.isNotEmpty) {
      for (var attr in attributes.entries) {
        if (attr.key == 'value' && elem is InputElement && elem.value != attr.value) {
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
          currentBinding.fn = fn;
        } else {
          dataEvents[type] = EventBinding(elem, type, fn);
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
          if (e is html.Text) {
            if (kVerboseMode) {
              print("Hydrate text node: $e");
            }
            node = e;
            if (e.text != text) {
              e.text = text;
              if (kVerboseMode) {
                print("Update text node: $text");
              }
            }
            toHydrate.remove(e);
            break diff;
          }
        }
      }

      node = html.Text(text);
      if (kVerboseMode) {
        print("Create text node: $text");
      }
    } else {
      if (node is! html.Text) {
        var elem = html.Text(text);
        node!.replaceWith(elem);
        node = elem;
        if (kVerboseMode) {
          print("Replace text node: $text");
        }
      } else {
        var node = this.node as html.Text;
        if (node.text != text) {
          node.text = text;
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

      assert(parentNode is html.Element);
      if (childNode == null) return;

      var afterNode = after?.node;

      if (childNode.previousNode == afterNode && childNode.parentNode == parentNode) {
        return;
      }

      if (kVerboseMode) {
        print("Attach node $childNode of $parentNode after $afterNode");
      }

      if (afterNode == null) {
        parentNode!.insertBefore(childNode, parentNode.childNodes.firstOrNull);
      } else {
        parentNode!.insertBefore(childNode, afterNode.nextNode);
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
    child.node?.remove();
    child.parent = null;
  }

  void finalize() {
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
  final Node container;
  late final Node? beforeStart;

  RootDomRenderObject(this.container, [List<Node>? nodes]) {
    node = container;
    toHydrate = [...nodes ?? container.nodes];
    beforeStart = toHydrate.firstOrNull?.previousNode;
  }

  factory RootDomRenderObject.between(Node start, Node end) {
    var nodes = <Node>[];
    Node? curr = start.nextNode;
    while (curr != null && curr != end) {
      nodes.add(curr);
      curr = curr.nextNode;
    }
    return RootDomRenderObject(start.parentNode!, nodes);
  }

  @override
  void attach(covariant DomRenderObject child, {covariant DomRenderObject? after}) {
    super.attach(child, after: after?.node != null ? after : (DomRenderObject()..node = beforeStart));
  }
}

typedef DomEventCallback = void Function(Event event);

class EventBinding {
  final String type;
  DomEventCallback fn;
  StreamSubscription? subscription;

  EventBinding(html.Element element, this.type, this.fn) {
    subscription = element.on[type].listen((event) {
      fn(event);
    });
  }

  void clear() {
    subscription?.cancel();
    subscription = null;
  }
}

extension AttributeOperation on html.Element {
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
