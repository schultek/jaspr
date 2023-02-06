import 'dart:async';
import 'dart:html';
import 'dart:html' as html show Element, Text;

import '../foundation/constants.dart';
import '../framework/framework.dart';

class DomNodeData {
  Node? node;
  List<Node> toHydrate = [];
  Map<String, _EventBinding>? events;

  void clearEvents() {
    events?.forEach((type, binding) {
      binding.clear();
    });
    events = null;
  }
}

typedef DomEventCallback = void Function(Event event);

class _EventBinding {
  final String type;
  DomEventCallback fn;
  StreamSubscription? subscription;

  _EventBinding(html.Element element, this.type, this.fn) {
    subscription = element.on[type].listen((event) {
      fn(event);
    });
  }

  void clear() {
    subscription?.cancel();
    subscription = null;
  }
}

extension DomNodeDataExt on RenderElement {
  DomNodeData get data => getData() ?? setData(DomNodeData());
}

extension on html.Element {
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

class BrowserDomRenderer extends Renderer {
  final html.Element container;
  final int? from;
  final int? to;

  BrowserDomRenderer(this.container, this.from, this.to);

  @override
  void renderNode(RenderElement element, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    var data = element.data;

    late Set<String> attributesToRemove;
    late html.Element elem;

    diff:
    if (data.node == null) {
      var toHydrate = element.parentNode!.data.toHydrate;
      if (toHydrate.isNotEmpty) {
        for (var e in toHydrate) {
          if (e is html.Element && e.tagName.toLowerCase() == tag) {
            if (kVerboseMode) {
              print("Hydrate html node: $e");
            }
            elem = data.node = e;
            attributesToRemove = elem.attributes.keys.toSet();
            toHydrate.remove(e);
            Iterable<Node> nodes = e.nodes;
            if (kDebugMode) {
              nodes = nodes.where((node) => node is! html.Text || (node.text ?? '').trim().isNotEmpty);
            }
            data.toHydrate = nodes.toList();
            break diff;
          }
        }
      }

      elem = data.node = document.createElement(tag);
      attributesToRemove = {};
      if (kVerboseMode) {
        print("Create html node: $elem");
      }
    } else {
      if (data.node is! html.Element || (data.node as html.Element).tagName.toLowerCase() != tag) {
        elem = document.createElement(tag);
        var old = data.node;
        data.node!.replaceWith(elem);
        data.node = elem;
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
        elem = data.node as html.Element;
        attributesToRemove = elem.attributes.keys.toSet();
      }
    }

    elem.clearOrSetAttribute('id', id);
    elem.clearOrSetAttribute('class', classes == null || classes.isEmpty ? null : classes.join(' '));
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
      final prevEventTypes = data.events?.keys.toSet();
      data.events ??= <String, _EventBinding>{};
      final dataEvents = data.events!;
      events.forEach((type, fn) {
        prevEventTypes?.remove(type);
        final currentBinding = dataEvents[type];
        if (currentBinding != null) {
          currentBinding.fn = fn;
        } else {
          dataEvents[type] = _EventBinding(elem, type, fn);
        }
      });
      prevEventTypes?.forEach((type) {
        dataEvents.remove(type)?.clear();
      });
    } else {
      data.clearEvents();
    }
  }

  @override
  void renderTextNode(RenderElement element, String text, [bool rawHtml = false]) {
    var data = element.data;

    if (rawHtml) {
      var parent = element.parentNode!.data.node;
      if (parent is html.Element) {
        if (parent.innerHtml != text) {
          parent.innerHtml = text;
          data.node = parent.childNodes.first;
          if (kVerboseMode) {
            print("Update inner html: $text");
          }
        }
        element.parentNode!.data.toHydrate.clear();
      }
      return;
    }

    diff:
    if (data.node == null) {
      var toHydrate = element.parentNode!.data.toHydrate;
      if (toHydrate.isNotEmpty) {
        for (var e in toHydrate) {
          if (e is html.Text) {
            if (kVerboseMode) {
              print("Hydrate text node: $e");
            }
            data.node = e;
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

      data.node = html.Text(text);
      if (kVerboseMode) {
        print("Create text node: $text");
      }
    } else {
      if (data.node is! html.Text) {
        var elem = html.Text(text);
        data.node!.replaceWith(elem);
        data.node = elem;
        if (kVerboseMode) {
          print("Replace text node: $text");
        }
      } else {
        var node = data.node as html.Text;
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
  void skipContent(RenderElement element) {
    element.parentNode!.data.toHydrate.clear();
  }

  @override
  void attachNode(RenderElement? parent, RenderElement child, RenderElement? after) {
    if (parent == null) {
      Iterable<Node> nodes = container.nodes;
      if (kDebugMode) {
        nodes = nodes.where((node) => node is! html.Text || (node.text ?? '').trim().isNotEmpty);
      }
      nodes = nodes.skip(from ?? 0);
      if (to != null) {
        nodes = nodes.take(to! - (from ?? 0));
      }
      child.data
        ..node = container
        ..toHydrate = nodes.toList();
      return;
    }

    var parentNode = parent.data.node;
    var childNode = child.data.node;

    assert(parentNode is html.Element);
    if (childNode == null) return;

    var afterNode = after?.data.node;
    if (afterNode == null && parentNode == container && from != null && from! > 0) {
      var trimmedNodes = container.childNodes.where((n) => n is! html.Text || (n.data?.trim().isNotEmpty ?? false)).toList();
      afterNode = trimmedNodes[from!-1];
    }

    if (childNode.previousNode == afterNode && childNode.parentNode == parentNode) {
      return;
    }

    if (kVerboseMode) {
      print("Attach node $childNode of $parentNode after $afterNode");
    }

    if (afterNode == null) {
      if (parentNode!.childNodes.isEmpty) {
        parentNode.append(childNode);
      } else {
        parentNode.insertBefore(childNode, parentNode.childNodes.first);
      }
    } else {
      parentNode!.insertBefore(childNode, afterNode.nextNode);
    }
  }

  @override
  void finalizeNode(RenderElement element) {
    if (kVerboseMode && element.data.toHydrate.isNotEmpty) {
      print("Clear ${element.data.toHydrate.length} nodes not hydrated (${element.data.toHydrate})");
    }
    for (var node in element.data.toHydrate) {
      node.remove();
    }
    element.data.toHydrate.clear();
  }

  @override
  void removeChild(RenderElement parent, RenderElement child) {
    var node = child.data.node;
    if (kVerboseMode) {
      print("Remove child $node of ${parent.data.node}");
    }
    node?.remove();
  }
}
