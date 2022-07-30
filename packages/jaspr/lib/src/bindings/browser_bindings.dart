import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:html' as html show Element, Text;

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../foundation/scheduler.dart';
import '../foundation/sync.dart';
import '../framework/framework.dart';

/// Main entry point for the browser app
void runApp(Component app, {String attachTo = 'body'}) {
  AppBinding.ensureInitialized().attachRootComponent(app, attachTo: attachTo);
}

/// Global component binding for the browser
class AppBinding extends BindingBase with ComponentsBinding, SyncBinding, SchedulerBinding {
  static AppBinding ensureInitialized() {
    if (ComponentsBinding.instance == null) {
      AppBinding();
    }
    return ComponentsBinding.instance! as AppBinding;
  }

  @override
  void initInstances() {
    super.initInstances();
    _loadRawState();
  }

  @override
  bool get isClient => true;

  @override
  void didAttachRootElement(Element element, {required String to}) {}

  @override
  DomBuilder attachBuilder(String to) {
    return BrowserDomBuilder(document.querySelector(to)!);
  }

  @override
  Uri get currentUri => Uri.parse(window.location.toString());

  final Map<String, dynamic> _rawState = {};

  void _loadRawState() {
    var stateData = document.body!.attributes.remove('state-data');
    if (stateData != null) {
      _rawState.addAll(stateCodec.decode(stateData).cast<String, dynamic>());
    }
  }

  @override
  void updateRawState(String id, dynamic state) {
    _rawState[id] = state;
  }

  @override
  dynamic getRawState(String id) {
    return _rawState[id];
  }

  @override
  Future<Map<String, dynamic>> fetchState(String url) {
    return window
        .fetch(url, {
          'headers': {'jaspr-mode': 'data-only'}
        })
        .then((result) => result.text())
        .then((data) => jsonDecode(data));
  }

  @override
  void scheduleBuild(VoidCallback buildCallback) {
    // This seems to give the best results over futures and microtasks
    // Needs to be inspected in more detail
    window.requestAnimationFrame((highResTime) {
      buildCallback();
    });
  }
}

final _nodesExpando = Expando<DomNodeData>();

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

extension on DomNode {
  DomNodeData get data => _nodesExpando[this] ??= DomNodeData();
}

extension on html.Element {
  void clearOrSetAttribute(String name, String? value) {
    final current = getAttribute(name);
    if (current == value) return;
    if (value == null) {
      print("Remove attribute: $name");
      removeAttribute(name);
    } else {
      print("Update attribute: $name - $value");
      setAttribute(name, value);
    }
  }
}

class BrowserDomBuilder extends DomBuilder {
  final html.Element container;
  BrowserDomBuilder(this.container);

  @override
  void setRootNode(DomNode node) {
    node.data.node = container;
    node.data.toHydrate = [...container.nodes];
  }

  @override
  void renderNode(DomNode node, String tag, Map<String, String> attrs, Map<String, EventCallback> events) {
    var data = node.data;

    late Set<String> attributesToRemove;
    late html.Element elem;

    diff:
    if (data.node == null) {
      var toHydrate = node.parentNode?.data.toHydrate ?? [];
      if (toHydrate.isNotEmpty) {
        for (var e in toHydrate) {
          if (e is html.Element && e.tagName.toLowerCase() == tag) {
            print("Hydrate html node: $e");
            elem = data.node = e;
            attributesToRemove = elem.attributes.keys.toSet();
            toHydrate.remove(e);
            data.toHydrate = [...e.nodes];
            break diff;
          }
        }
      }

      elem = data.node = document.createElement(tag);
      attributesToRemove = {};
      print("Create html node: $elem");
    } else {
      if (data.node is! html.Element || (data.node as html.Element).tagName.toLowerCase() != tag) {
        elem = document.createElement(tag);
        var old = data.node;
        data.node!.replaceWith(elem);
        data.node = elem;
        attributesToRemove = {};
        print("Replace html node: $elem for $old");
      } else {
        elem = data.node as html.Element;
        attributesToRemove = elem.attributes.keys.toSet();
      }
    }

    for (var attr in attrs.entries) {
      elem.clearOrSetAttribute(attr.key, attr.value);
      attributesToRemove.remove(attr.key);
    }
    for (final name in attributesToRemove) {
      elem.removeAttribute(name);
      print("Remove attribute: $name");
    }

    if (events.isNotEmpty) {
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
  void renderTextNode(DomNode node, String text) {
    var data = node.data;

    diff:
    if (data.node == null) {
      var toHydrate = node.parentNode?.data.toHydrate ?? [];
      if (toHydrate.isNotEmpty) {
        for (var e in toHydrate) {
          if (e is html.Text) {
            print("Hydrate text node: $e");
            data.node = e;
            if (e.text != text) {
              e.text = text;
              print("Update text node: $text");
            }
            toHydrate.remove(e);
            break diff;
          }
        }
      }

      data.node = html.Text(text);
      print("Create text node: $text");
    } else {
      if (data.node is! html.Text) {
        var elem = html.Text(text);
        data.node!.replaceWith(elem);
        data.node = elem;
        print("Replace text node: $text");
      } else {
        var node = data.node as html.Text;
        if (node.text != text) {
          node.text = text;
          print("Update text node: $text");
        }
      }
    }
  }

  @override
  void renderChildNode(DomNode node, DomNode child, DomNode? after) {
    var parentNode = node.data.node;
    var childNode = child.data.node;

    assert(parentNode is html.Element);
    assert(childNode != null);

    var afterNode = after?.data.node;

    if (childNode!.previousNode == afterNode && childNode.parentNode == parentNode) {
      return;
    }

    print("Attach node $childNode of $parentNode after $afterNode");

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
  void didPerformRebuild(DomNode node) {
    if (node.data.toHydrate.isNotEmpty) {
      print("Clear ${node.data.toHydrate.length} nodes not hydrated (${node.data.toHydrate})");
    }
    for (var node in node.data.toHydrate) {
      node.remove();
    }
    node.data.toHydrate.clear();
  }

  @override
  void removeChild(DomNode parent, DomNode child) {
    var node = child.data.node;
    print("Remove child $node of ${parent.data.node}");
    node?.remove();
  }
}
