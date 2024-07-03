import 'dart:async';
import 'dart:convert';
import 'dart:html' as html show Element;
import 'dart:html';

import '../../browser.dart';

typedef ClientBuilder = Component Function(ConfigParams);
typedef ClientLoader = FutureOr<ClientBuilder> Function();

typedef ClientByName = FutureOr<ClientBuilder> Function(String);

/// Called by the shared client components entrypoint.
void registerClients(Map<String, ClientLoader> clients) {
  final Map<String, ClientBuilder> builders = {};
  _findAnchors(clientByName: (name) {
    var client = (builders[name] ?? clients[name]!()) as FutureOr<ClientBuilder>;
    if (client is ClientBuilder) {
      return builders[name] = client;
    } else {
      return client.then((b) => builders[name] = b);
    }
  });
}

/// Helper method to get a client loader from a deferred import.
ClientLoader loadClient(Future<void> Function() loader, ClientBuilder builder) {
  return () => loader().then((_) => builder);
}

/// Sync variant of [registerClients].
void registerClientsSync(Map<String, ClientBuilder> clients) {
  _findAnchors(clientByName: (name) => clients[name]!);
}

class ConfigParams {
  ConfigParams(this._params, this.serverComponents);

  final Map<String, dynamic> _params;
  final Map<String, ServerComponentAnchor> serverComponents;

  T get<T>(String key) {
    if (T == Component) {
      var sId = _params[key];
      assert(sId is String && sId.startsWith(r's$'));
      var s = serverComponents[sId.substring(2)];
      if (s != null) {
        return s.build() as T;
      } else {
        return Text("") as T;
      }
    }
    if (_params[key] is! T) {
      print("$key is not $T: ${_params[key]}");
    }
    return _params[key];
  }
}

final _clientStartRegex = RegExp(r'^\$(\S+)(?:\s+data=(.*))?$');
final _clientEndRegex = RegExp(r'^/\$(\S+)$');

final _serverStartRegex = RegExp(r'^s\$(\d+)$');
final _serverEndRegex = RegExp(r'^/s\$(\d+)$');

sealed class ComponentAnchor {
  ComponentAnchor(this.name, this.startNode);

  final String name;
  final Node startNode;
  late Node endNode;
}

class ClientComponentAnchor extends ComponentAnchor {
  ClientComponentAnchor(super.name, super.startNode, this.data);

  final String? data;
  late FutureOr<ClientBuilder> builder;
  final Map<String, ServerComponentAnchor> serverAnchors = {};

  Future<void> resolve() async {
    var r = await (Future.value(builder), Future.wait(serverAnchors.values.map((a) => a.resolve()))).wait;
    builder = r.$1;
  }

  Component build() {
    assert(builder is ClientBuilder, "ClientComponentAnchor was not resolved before calling build()");
    var params = ConfigParams(data != null ? jsonDecode(data!) : {}, serverAnchors);
    return (builder as ClientBuilder)(params);
  }

  Future<void> run() async {
    await resolve();
    BrowserAppBinding().attachRootComponent(build(), attachBetween: (startNode, endNode));
  }
}

class ServerComponentAnchor extends ComponentAnchor {
  ServerComponentAnchor(super.name, super.startNode);

  late final DocumentFragment fragment;
  late final List<ClientComponentAnchor> clientAnchors;
  final Map<String, Component Function(html.Element)> elementFactories = {};

  Future<void> resolve() async {
    await Future.wait(clientAnchors.map((a) => a.resolve()));
  }

  void recursivelyFindChildAnchors(ClientByName clientByName) {
    fragment = document.createDocumentFragment();

    Node? curr = startNode.nextNode;
    while (curr != null && curr != endNode) {
      fragment.append(curr.clone(true));
      curr = curr.nextNode;
    }

    clientAnchors = _findAnchors(clientByName: clientByName, root: fragment, runEagerly: false);

    window.console.log(fragment);

    for (var client in clientAnchors) {
      var name = client.name.toLowerCase().replaceAll('/', '_');
      var n = 1;
      while (elementFactories.containsKey('${name}_$n')) {
        n++;
      }

      Component? child;

      elementFactories['${name}_$n'] = (_) {
        if (child == null) {
          var c = client.build();
          child = Builder.single(key: GlobalKey(), builder: (_) => c);
        }
        return child!;
      };

      while (client.startNode.nextNode != null && client.startNode.nextNode != client.endNode) {
        client.startNode.nextNode!.remove();
      }

      client.startNode.replaceWith(document.createElement('${name}_$n'));
      client.endNode.remove();
    }

    window.console.log(fragment);
  }

  Component build() {
    return Builder(builder: (context) {
      return fragment.childNodes.map((n) => RawNode(n, elementFactories: elementFactories));
    });
  }
}

List<ClientComponentAnchor> _findAnchors({required ClientByName clientByName, Node? root, bool runEagerly = true}) {
  var iterator = NodeIterator(root ?? document, NodeFilter.SHOW_COMMENT);

  List<ComponentAnchor> anchors = [];
  List<ClientComponentAnchor> clientAnchors = [];

  Comment? currNode;
  while ((currNode = iterator.nextNode() as Comment?) != null) {
    var value = currNode!.nodeValue ?? '';

    // Find client start anchor.
    var match = _clientStartRegex.firstMatch(value);
    if (match != null) {
      assert(anchors.isEmpty || anchors.last is ServerComponentAnchor,
          "Found directly nested client component anchor, which is not allowed.");

      var name = match.group(1)!;
      var data = match.group(2);
      anchors.add(ClientComponentAnchor(name, currNode, data));

      continue;
    }

    // Find client end anchor.
    match = _clientEndRegex.firstMatch(value);
    if (match != null) {
      var name = match.group(1)!;
      assert(anchors.isNotEmpty && anchors.last.name == name,
          "Found client component end anchor without matching start anchor.");

      var comp = anchors.removeLast() as ClientComponentAnchor;

      // Nested client components are handled recursively.
      if (anchors.isNotEmpty) continue;

      assert(anchors.isEmpty);

      var start = comp.startNode;
      assert(start.parentNode == currNode.parentNode, "Found client component anchors with different parent nodes.");

      comp.endNode = currNode;
      comp.builder = clientByName(name);

      // Remove the data string.
      start.text = '\$${comp.name}';

      if (runEagerly) {
        // Instantly run the client component.
        comp.run();
      }

      clientAnchors.add(comp);

      continue;
    }

    // Find server start anchor.
    match = _serverStartRegex.firstMatch(value);
    if (match != null) {
      assert(anchors.isNotEmpty, "Found non-nested server component anchor, which is not allowed.");
      assert(anchors.last is ClientComponentAnchor,
          "Found directly nested server component anchor, which is not allowed.");

      var name = match.group(1)!;
      anchors.add(ServerComponentAnchor(name, currNode));

      continue;
    }

    // Find server end anchor.
    match = _serverEndRegex.firstMatch(value);
    if (match != null) {
      var name = match.group(1)!;
      assert(anchors.isNotEmpty && anchors.last.name == name,
          "Found server component end anchor without matching start anchor.");

      var comp = anchors.removeLast() as ServerComponentAnchor;

      // Nested client components are handled recursively.
      if (anchors.length > 1) continue;

      var start = comp.startNode;
      assert(start.parentNode == currNode.parentNode, "Found server component anchors with different parent nodes.");

      comp.endNode = currNode;

      assert(anchors.isNotEmpty, "Found server component without ancestor client component.");
      (anchors.last as ClientComponentAnchor).serverAnchors[name] = comp;

      comp.recursivelyFindChildAnchors(clientByName);

      continue;
    }
  }

  return clientAnchors;
}
