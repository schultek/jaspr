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
    if ((namespace, parent?.node) case (== null, final html.Element pnode)) {
      namespace = pnode.namespaceUri;
    }

    diff:
    if (node == null) {
      final toHydrate = parent!.toHydrate;
      if (toHydrate.isNotEmpty) {
        for (final e in toHydrate) {
          if (e is html.Element && e.tagName.toLowerCase() == tag) {
            if (kVerboseMode) {
              window.console.log('Hydrate html node: $e');
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
        window.console.log('Create html node: $elem');
      }
    } else {
      if (node case final html.Element node when node.tagName.toLowerCase() == tag) {
        elem = node;
        attributesToRemove = elem.attributes.keys.toSet();
      } else {
        elem = _createElement(tag, namespace);
        final old = node;
        node!.replaceWith(elem);
        node = elem;
        if (old != null && old.childNodes.isNotEmpty) {
          final oldChildren = [...old.childNodes];
          for (final child in oldChildren) {
            elem.append(child);
          }
        }
        attributesToRemove = {};
        if (kVerboseMode) {
          window.console.log('Replace html node: $elem for $old');
        }
      }
    }

    elem.clearOrSetAttribute('id', id);
    elem.clearOrSetAttribute('class', classes == null || classes.isEmpty ? null : classes);

    elem.clearOrSetAttribute(
      'style',
      styles == null || styles.isEmpty ? null : styles.entries.map((e) => '${e.key}: ${e.value}').join('; '),
    );

    if (attributes != null && attributes.isNotEmpty) {
      for (final attr in attributes.entries) {
        if (attr.key == 'value' && elem is InputElement && elem.value != attr.value) {
          if (kVerboseMode) {
            window.console.log('Set input value: ${attr.value}');
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
          window.console.log('Remove attribute: $name');
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
      final toHydrate = parent!.toHydrate;
      if (toHydrate.isNotEmpty) {
        for (final e in toHydrate) {
          if (e is html.Text) {
            if (kVerboseMode) {
              window.console.log('Hydrate text node: $e');
            }
            node = e;
            if (e.text != text) {
              e.text = text;
              if (kVerboseMode) {
                window.console.log('Update text node: $text');
              }
            }
            toHydrate.remove(e);
            break diff;
          }
        }
      }

      node = html.Text(text);
      if (kVerboseMode) {
        window.console.log('Create text node: $text');
      }
    } else {
      if (node case final html.Text node) {
        if (node.text != text) {
          node.text = text;
          if (kVerboseMode) {
            window.console.log('Update text node: $text');
          }
        }
      } else {
        final elem = html.Text(text);
        node!.replaceWith(elem);
        node = elem;
        if (kVerboseMode) {
          window.console.log('Replace text node: $text');
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

      final parentNode = node;
      final childNode = child.node;

      assert(parentNode is html.Element);
      if (childNode == null) return;

      final afterNode = after?.node;

      if (childNode.previousNode == afterNode && childNode.parentNode == parentNode) {
        return;
      }

      if (kVerboseMode) {
        window.console.log('Attach node $childNode of $parentNode after $afterNode');
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
      window.console.log('Remove child $child of $this');
    }
    child.node?.remove();
    child.parent = null;
  }

  void finalize() {
    if (kVerboseMode && toHydrate.isNotEmpty) {
      window.console.log('Clear ${toHydrate.length} nodes not hydrated ($toHydrate)');
    }
    for (final node in toHydrate) {
      node.remove();
    }
    toHydrate.clear();
  }
}

class RootDomRenderObject extends DomRenderObject {
  RootDomRenderObject(this.container, [List<Node>? nodes]) {
    node = container;
    toHydrate = [...nodes ?? container.nodes];
    beforeStart = toHydrate.firstOrNull?.previousNode;
  }

  factory RootDomRenderObject.between(Node start, Node end) {
    final nodes = <Node>[];
    Node? curr = start.nextNode;
    while (curr != null && curr != end) {
      nodes.add(curr);
      curr = curr.nextNode;
    }
    return RootDomRenderObject(start.parentNode!, nodes);
  }

  final Node container;
  late final Node? beforeStart;

  @override
  void attach(covariant DomRenderObject child, {covariant DomRenderObject? after}) {
    super.attach(child, after: after?.node != null ? after : (DomRenderObject()..node = beforeStart));
  }
}

typedef DomEventCallback = void Function(Event event);

class EventBinding {
  EventBinding(html.Element element, this.type, this.fn) {
    subscription = element.on[type].listen((event) {
      fn(event);
    });
  }

  final String type;
  DomEventCallback fn;
  StreamSubscription? subscription;

  void clear() {
    subscription?.cancel();
    subscription = null;
  }
}

extension on html.Element {
  void clearOrSetAttribute(String name, String? value) {
    final current = getAttribute(name);
    if (current == value) return;
    if (value == null) {
      if (kVerboseMode) {
        window.console.log('Remove attribute: $name');
      }
      removeAttribute(name);
    } else {
      if (kVerboseMode) {
        window.console.log('Update attribute: $name - $value');
      }
      setAttribute(name, value);
    }
  }
}
