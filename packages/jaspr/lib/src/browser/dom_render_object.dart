import 'dart:async';
import 'dart:js_interop';

import 'package:universal_web/web.dart' as web;

import '../foundation/constants.dart';
import '../foundation/events.dart';
import '../foundation/type_checks.dart';
import '../framework/framework.dart';
import 'utils.dart';

const htmlns = 'http://www.w3.org/1999/xhtml';
const xmlns = {
  'svg': 'http://www.w3.org/2000/svg',
  'math': 'http://www.w3.org/1998/Math/MathML',
};

abstract class DomRenderObject implements RenderObject {
  @override
  DomRenderObject? parent;

  @override
  RenderElement createChildRenderElement() {
    return DomRenderElement()..parent = this;
  }

  @override
  RenderText createChildRenderText() {
    return DomRenderText()..parent = this;
  }

  @override
  RenderFragment createChildRenderFragment() {
    return DomRenderFragment()..parent = this;
  }

  void finalize();
}

class DomRenderElement extends DomRenderObject implements RenderElement {
  @override
  web.Element? node;

  List<web.Node> toHydrate = [];

  Map<String, EventBinding>? events;

  void clearEvents() {
    events?.forEach((type, binding) {
      binding.clear();
    });
    events = null;
  }

  web.Element _createElement(String tag, String? namespace) {
    if (namespace != null && namespace != htmlns) {
      return web.document.createElementNS(namespace, tag);
    }
    return web.document.createElement(tag);
  }

  @override
  void update(String tag, String? id, String? classes, Map<String, String>? styles, Map<String, String>? attributes,
      Map<String, EventCallback>? events) {
    late Set<String> attributesToRemove;
    late web.Element elem;

    var namespace = xmlns[tag];
    if (namespace == null && (parent?.node?.isElement ?? false)) {
      namespace = (parent?.node as web.Element).namespaceURI;
    }

    diff:
    if (node == null) {
      final parentToHydrate = parent is DomRenderElement ? (parent as DomRenderElement).toHydrate : [];
      if (parentToHydrate.isNotEmpty) {
        for (final e in parentToHydrate) {
          if (e.isElement && (e as web.Element).tagName.toLowerCase() == tag) {
            if (kVerboseMode) {
              print("Hydrate html node: $e");
            }
            elem = node = e;
            attributesToRemove = {};
            for (var i = 0; i < elem.attributes.length; i++) {
              attributesToRemove.add(elem.attributes.item(i)!.name);
            }
            parentToHydrate.remove(e);
            toHydrate = e.childNodes.toIterable().toList();
            break diff;
          }
        }
      }

      elem = node = _createElement(tag, namespace);
      attributesToRemove = {};
      if (kVerboseMode) {
        web.console.log("Create html node: $elem".toJS);
      }
    } else {
      if (node!.tagName.toLowerCase() != tag) {
        throw ArgumentError(
          'Cannot change element tag (tried from "${node!.tagName.toLowerCase()}" to "$tag").',
        );
      }
      elem = node!;
      attributesToRemove = {};
      for (var i = 0; i < elem.attributes.length; i++) {
        attributesToRemove.add(elem.attributes.item(i)!.name);
      }
    }

    elem.clearOrSetAttribute('id', id);
    elem.clearOrSetAttribute('class', classes == null || classes.isEmpty ? null : classes);
    elem.clearOrSetAttribute('style',
        styles == null || styles.isEmpty ? null : styles.entries.map((e) => '${e.key}: ${e.value}').join('; '));

    if (attributes != null && attributes.isNotEmpty) {
      for (final attr in attributes.entries) {
        if (attr.key == 'value' && elem.isHtmlInputElement && (elem as web.HTMLInputElement).value != attr.value) {
          if (kVerboseMode) {
            print("Set input value: ${attr.value}");
          }
          elem.value = attr.value;
          continue;
        }

        if (attr.key == 'value' && elem.isHtmlSelectElement && (elem as web.HTMLSelectElement).value != attr.value) {
          if (kVerboseMode) {
            print("Set select value: ${attr.value}");
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
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    try {
      child.parent = this;

      final parentNode = node;
      final childNode = child.node;

      assert(parentNode.isElement);
      if (childNode == null) return;

      final afterNode = after?.node;

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

  @override
  void finalize() {
    if (kVerboseMode && toHydrate.isNotEmpty) {
      print("Clear ${toHydrate.length} nodes not hydrated ($toHydrate)");
    }
    for (final node in toHydrate) {
      node.parentNode!.removeChild(node);
    }
    toHydrate.clear();
  }
}

class DomRenderText extends DomRenderObject implements RenderText {
  @override
  web.Text? node;

  @override
  void update(String text) {
    diff:
    if (node == null) {
      final toHydrate = parent is DomRenderElement ? (parent as DomRenderElement).toHydrate : [];
      if (toHydrate.isNotEmpty) {
        for (final e in toHydrate) {
          if (e.isText) {
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
      final node = this.node!;
      if (node.textContent != text) {
        node.textContent = text;
        if (kVerboseMode) {
          print("Update text node: $text");
        }
      }
    }
  }

  @override
  void attach(covariant RenderObject child, {covariant RenderObject? after}) {
    throw UnimplementedError(
      'Text nodes cannot have children attached to them.',
    );
  }

  @override
  void remove(covariant RenderObject child) {
    throw UnimplementedError(
      'Text nodes cannot have children removed from them.',
    );
  }

  @override
  void finalize() {
    // noop
  }
}

class DomRenderFragment extends DomRenderObject implements RenderFragment {
  @override
  web.DocumentFragment? node;

  void update() {
    if (node == null) {
      node = web.document.createDocumentFragment();
      if (kVerboseMode) {
        print("Create document fragment");
      }
    }
  }

  @override
  void finalize() {
    // Fragments operate the hydration nodes of its parent, so we don't want to clear them.
  }
}

class RootDomRenderObject extends DomRenderElement {
  final web.Element container;
  late final web.Node? beforeStart;

  RootDomRenderObject(this.container, [List<web.Node>? nodes]) {
    node = container;
    toHydrate = [...nodes ?? container.childNodes.toIterable()];
    beforeStart = toHydrate.firstOrNull?.previousSibling;
  }

  factory RootDomRenderObject.between(web.Node start, web.Node end) {
    final nodes = <web.Node>[];
    web.Node? curr = start.nextSibling;
    while (curr != null && curr != end) {
      nodes.add(curr);
      curr = curr.nextSibling;
    }
    return RootDomRenderObject(start.parentElement!, nodes);
  }

  @override
  void attach(covariant DomRenderObject child, {covariant DomRenderObject? after}) {
    super.attach(child, after: after?.node != null ? after : (DomRenderElement()..node = beforeStart));
  }
}

typedef DomEventCallback = void Function(web.Event event);

class EventBinding {
  final String type;
  DomEventCallback fn;
  StreamSubscription? subscription;

  EventBinding(web.Element element, this.type, this.fn) {
    subscription = web.EventStreamProvider<web.Event>(type).forElement(element).listen((event) {
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
    if (value == null) {
      if (!hasAttribute(name)) return;
      if (kVerboseMode) {
        print("Remove attribute: $name");
      }
      removeAttribute(name);
    } else {
      if (getAttribute(name) == value) return;
      if (kVerboseMode) {
        print("Update attribute: $name - $value");
      }
      setAttribute(name, value);
    }
  }
}
