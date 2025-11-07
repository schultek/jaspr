import 'dart:async';
import 'dart:convert';

import 'package:universal_web/web.dart' as web;

import '../components/basic.dart';
import '../foundation/type_checks.dart';
import '../foundation/validator.dart';
import '../framework/framework.dart';
import 'browser_binding.dart';
import 'custom_node_component.dart';

typedef ClientLoader = FutureOr<ClientBuilder> Function();
typedef ClientBuilder = Component Function(ClientParams params);

final Map<String, ClientLoader> _loaders = {};
final Map<String, ClientBuilder> _builders = {};
final List<ClientComponentAnchor> _rootAnchors = [];

FutureOr<ClientBuilder> _getClientByName(String name) {
  if (_builders.containsKey(name)) {
    return _builders[name]!;
  }

  final loader = _loaders[name]!();
  if (loader is ClientBuilder) {
    return _builders[name] = loader;
  } else {
    return loader.then((b) => _builders[name] = b);
  }
}

/// Called by the shared client components entrypoint.
void registerClients(Map<String, ClientLoader> clients) {
  _loaders.addAll(clients);
  _builders.removeWhere((key, _) => clients.containsKey(key));
  _rootAnchors.addAll(_findAnchors(runEagerly: true));
}

/// Helper method to get a client loader from a deferred import.
ClientLoader loadClient(Future<void> Function() loader, ClientBuilder builder) {
  return () => loader().then((_) => builder);
}

/// Sync variant of [registerClients].
void registerClientsSync(Map<String, ClientBuilder> clients) {
  _builders.addAll(clients);
  _rootAnchors.addAll(_findAnchors(runEagerly: true));
}

class ClientParams {
  ClientParams(this._params, this.serverComponents);

  final Map<String, dynamic> _params;
  final Map<String, ServerComponentAnchor> serverComponents;

  Component mount(String sId) {
    assert(sId.startsWith('s${DomValidator.clientMarkerPrefixRegex}'));
    var s = serverComponents[sId.substring(2)];
    if (s != null) {
      return s.build();
    } else {
      return const Component.text("");
    }
  }

  T get<T>(String key) {
    if (_params[key] is! T) {
      print("$key is not $T: ${_params[key]}");
    }
    return _params[key];
  }
}

final _clientStartRegex = RegExp('^${DomValidator.clientMarkerPrefixRegex}(\\S+)(?:\\s+#(\\S*))?(?:\\s+data=(.*))?\$');
final _clientEndRegex = RegExp('^/${DomValidator.clientMarkerPrefixRegex}(\\S+)\$');

final _serverStartRegex = RegExp('^s${DomValidator.clientMarkerPrefixRegex}(\\d+)(?:\\s+#(\\S*))?\$');
final _serverEndRegex = RegExp('^/s${DomValidator.clientMarkerPrefixRegex}(\\d+)\$');

sealed class ComponentAnchor {
  ComponentAnchor(this.name, this.key, this.startNode);

  final String name;
  final String key;
  final web.Node startNode;
  late web.Node endNode;
}

final Expando<ClientComponentAnchor> _clientAnchorExpando = Expando();

extension ClientAnchorExtension on web.Node {
  ClientComponentAnchor? get clientAnchor => _clientAnchorExpando[this];

  set clientAnchor(ClientComponentAnchor? anchor) {
    _clientAnchorExpando[this] = anchor;
  }
}

class ClientComponentAnchor extends ComponentAnchor {
  ClientComponentAnchor(
    super.name,
    super.key,
    super.startNode,
    this.data,
  );

  String? data;
  late FutureOr<ClientBuilder> builder;
  final Map<String, ServerComponentAnchor> serverAnchors = {};

  void Function(void Function())? _setState;

  Future<void> resolve() async {
    var r = await (Future.value(builder), Future.wait(serverAnchors.values.map((a) => a.resolve()))).wait;
    builder = r.$1;
  }

  Component build() {
    assert(builder is ClientBuilder, "ClientComponentAnchor was not resolved before calling build()");
    return StatefulBuilder(
      key: GlobalObjectKey(key),
      builder: (context, setState) {
        _setState = setState;
        final params = ClientParams(
          data != null ? jsonDecode(const DomValidator().unescapeMarkerText(data!)) : {},
          serverAnchors,
        );
        return (builder as ClientBuilder)(params);
      },
    );
  }

  void rebuild(String? data, Map<String, ServerComponentAnchor> serverAnchors) {
    assert(_setState != null, "ClientComponentAnchor was not built before calling rebuild()");
    _setState!(() {
      this.data = data;
      this.serverAnchors.clear();
      this.serverAnchors.addAll(serverAnchors);
    });
  }

  Future<void> run() async {
    await resolve();
    try {
      BrowserAppBinding().attachRootComponent(build(), attachBetween: (startNode, endNode));
    } catch (e, st) {
      throw Error.throwWithStackTrace(
        "Failed to attach client component '$name'. "
        "The following error occurred: $e",
        st,
      );
    }
  }
}

class ServerComponentAnchor extends ComponentAnchor {
  ServerComponentAnchor(super.name, super.key, super.startNode);

  final List<ClientComponentAnchor> clientAnchors = [];

  Future<void> resolve() async {
    await Future.wait(clientAnchors.map((a) => a.resolve()));
  }

  Component build() {
    final List<web.Node> nodes = [];

    web.Node? curr = startNode;
    while (curr != null && curr != endNode) {
      final next = curr.nextSibling;
      nodes.add(curr);
      curr = next;
    }
    nodes.add(endNode);

    return CustomNodeComponent(key: UniqueKey(), nodes, [
      for (var client in clientAnchors) ClientComponent(anchor: client),
    ]);
  }
}

List<ClientComponentAnchor> _findAnchors({web.Node? root, bool runEagerly = false}) {
  final iterator = web.document.createNodeIterator(root ?? web.document, 128 /* NodeFilter.SHOW_COMMENT */);

  List<ComponentAnchor> anchors = [];
  List<ClientComponentAnchor> clientAnchors = [];
  Map<String, int> clientKeyCounters = {};

  web.Comment? currNode;
  while ((currNode = iterator.nextNode() as web.Comment?) != null) {
    final value = currNode!.nodeValue ?? '';

    // Find client start anchor.
    var match = _clientStartRegex.firstMatch(value);
    if (match != null) {
      assert(
        anchors.isEmpty || anchors.last is ServerComponentAnchor,
        "Found directly nested client component anchor, which is not allowed.",
      );

      final name = match.group(1)!;
      final key = match.group(2);
      final data = match.group(3);

      final resolvedKey = key != null
          ? '@$name#$key'
          : (() {
              var count = clientKeyCounters[name] ?? -1;
              clientKeyCounters[name] = count + 1;
              return '@$name-${anchors.length}-$count';
            })();

      anchors.add(ClientComponentAnchor(name, resolvedKey, currNode, data));

      continue;
    }

    // Find client end anchor.
    match = _clientEndRegex.firstMatch(value);
    if (match != null) {
      final name = match.group(1)!;
      assert(
        anchors.isNotEmpty && anchors.last.name == name,
        "Found client component end anchor without matching start anchor.",
      );

      final comp = anchors.removeLast() as ClientComponentAnchor;

      final start = comp.startNode;
      assert(start.parentNode == currNode.parentNode, "Found client component anchors with different parent nodes.");

      comp.endNode = currNode;
      comp.builder = _getClientByName(name);

      // Remove the data string.
      start.textContent = '${DomValidator.clientMarkerPrefix}${comp.name}';

      start.clientAnchor = comp;

      if (anchors.isEmpty) {
        // This is a root client component.
        if (runEagerly) {
          comp.run();
        }
        clientAnchors.add(comp);
      } else {
        (anchors.last as ServerComponentAnchor).clientAnchors.add(comp);
      }

      continue;
    }

    // Find server start anchor.
    match = _serverStartRegex.firstMatch(value);
    if (match != null) {
      assert(anchors.isNotEmpty, "Found non-nested server component anchor, which is not allowed.");
      assert(
        anchors.last is ClientComponentAnchor,
        "Found directly nested server component anchor, which is not allowed.",
      );

      final name = match.group(1)!;
      final key = match.group(2);

      final count = (anchors.last as ClientComponentAnchor).serverAnchors.length;
      final resolvedKey = key != null ? 's#$key' : 's-${anchors.length}-$count';

      anchors.add(ServerComponentAnchor(name, resolvedKey, currNode));

      continue;
    }

    // Find server end anchor.
    match = _serverEndRegex.firstMatch(value);
    if (match != null) {
      var name = match.group(1)!;
      assert(
        anchors.isNotEmpty && anchors.last.name == name,
        "Found server component end anchor without matching start anchor.",
      );

      final comp = anchors.removeLast() as ServerComponentAnchor;

      final start = comp.startNode;
      assert(start.parentNode == currNode.parentNode, "Found server component anchors with different parent nodes.");

      comp.endNode = currNode;

      assert(anchors.isNotEmpty, "Found server component without ancestor client component.");
      (anchors.last as ClientComponentAnchor).serverAnchors[name] = comp;

      continue;
    }
  }

  return clientAnchors;
}

class ClientComponent extends NodeChildComponent {
  ClientComponent({required this.anchor, super.key});

  final ClientComponentAnchor anchor;

  @override
  NodeChildElement createElement() => ClientComponentElement(this);
}

class ClientComponentElement extends MultiChildRenderObjectElement implements NodeChildElement {
  ClientComponentElement(ClientComponent super.component);

  @override
  ClientComponent get component => super.component as ClientComponent;

  @override
  void update(ClientComponent newComponent) {
    assert(
      newComponent.anchor == component.anchor,
      'ClientComponent cannot be updated with a different anchor. Use a new ClientComponent instance instead.',
    );
    super.update(newComponent);
  }

  late final Component _child = component.anchor.build();

  @override
  List<Component> buildChildren() {
    return [_child];
  }

  @override
  DomRenderNodeChild createRenderObject() {
    return DomRenderNodeChild.between(
      parentRenderObjectElement!.renderObject as DomRenderNodes,
      component.anchor.startNode,
      component.anchor.endNode,
    );
  }

  @override
  void updateRenderObject(RenderObject renderObject) {}
}

void updatePage(web.Element newBody) {
  final currentBody = web.document.body!;
  _findAnchors(root: newBody, runEagerly: false);

  updateChildren(currentBody, newBody);
}

void updateElement(web.Element currentNode, web.Element newNode) {
  // Update attributes.

  final currentAttributes = currentNode.attributes;
  final newAttributes = newNode.attributes;

  final attributesToRemove = <String>{};

  for (var i = 0; i < currentAttributes.length; i++) {
    var attr = currentAttributes.item(i)!;
    attributesToRemove.add(attr.name);
  }

  for (var i = 0; i < newAttributes.length; i++) {
    var attr = newAttributes.item(i)!;
    attributesToRemove.remove(attr.name);

    if (currentAttributes.getNamedItem(attr.name)?.name != attr.value) {
      currentNode.setAttribute(attr.name, attr.value);
    }
  }

  for (var attrName in attributesToRemove) {
    currentNode.removeAttribute(attrName);
  }

  // Recursively update child nodes.
  updateChildren(currentNode, newNode);
}

void updateChildren(web.Element currentNode, web.Element newNode) {
  final currentChildren = currentNode.childNodes;
  final newChildren = newNode.childNodes;

  var currentChildIndex = 0;
  var newChildIndex = 0;

  while (currentChildIndex < currentChildren.length && newChildIndex < newChildren.length) {
    final currentChild = currentChildren.item(currentChildIndex)!;
    final newChild = newChildren.item(newChildIndex)!;

    if (currentChild.clientAnchor case final anchor?) {
      // This is a client component anchor, skip it.
      currentChildIndex++;
      while (currentChildIndex < currentChildren.length) {
        if (currentChildren.item(currentChildIndex) == anchor.endNode) {
          currentChildIndex++;
          break;
        }
        currentChildIndex++;
      }

      if (newChild.clientAnchor case final newAnchor? when newAnchor.name == anchor.name) {
        // Skip the new client component as well.
        newChildIndex++;
        while (newChildIndex < newChildren.length) {
          final child = newChildren.item(newChildIndex)!;
          if (child == newAnchor.endNode) {
            newChildIndex++;
            break;
          }
          newChildIndex++;
        }

        anchor.rebuild(newAnchor.data, newAnchor.serverAnchors);
      }
      continue;
    }

    if (currentChild.nodeType != newChild.nodeType) {
      currentNode.insertBefore(newChild, currentChild);
      continue;
    }

    if (currentChild.isText) {
      if (currentChild.textContent != newChild.textContent) {
        currentChild.textContent = newChild.textContent;
      }
      currentChildIndex++;
      newChildIndex++;
      continue;
    }
    if (currentChild.isElement) {
      updateElement(currentChild as web.Element, newChild as web.Element);
      currentChildIndex++;
      newChildIndex++;
      continue;
    }

    currentNode.replaceChild(newChild, currentChild);
    currentChildIndex++;
  }

  while (currentChildIndex < currentChildren.length) {
    var currentChild = currentChildren.item(currentChildIndex)!;
    currentNode.removeChild(currentChild);
  }

  while (newChildIndex < newChildren.length) {
    var newChild = newChildren.item(newChildIndex)!;
    currentNode.appendChild(newChild);
  }
}
