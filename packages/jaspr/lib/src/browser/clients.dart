import 'dart:async';
import 'dart:convert';

import 'package:universal_web/web.dart' as web;

import '../components/basic.dart';
import '../components/raw_text/raw_text_web.dart';
import '../foundation/marker_utils.dart';
import '../framework/framework.dart';
import 'browser_binding.dart';
import 'utils.dart';

typedef ClientLoader = FutureOr<ClientBuilder> Function();
typedef ClientBuilder = Component Function(ConfigParams params);

typedef ClientByName = FutureOr<ClientBuilder> Function(String);

/// Called by the shared client components entrypoint.
void registerClients(Map<String, ClientLoader> clients) {
  final Map<String, ClientBuilder> builders = {};
  _findAnchors(clientByName: (name) {
    final client = (builders[name] ?? clients[name]!()) as FutureOr<ClientBuilder>;
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

final _clientStartRegex = RegExp('^$clientMarkerPrefixRegex(\\S+)(?:\\s+data=(.*))?\$');
final _clientEndRegex = RegExp('^/$clientMarkerPrefixRegex(\\S+)\$');

final _serverStartRegex = RegExp(r'^s\$(\d+)$');
final _serverEndRegex = RegExp(r'^/s\$(\d+)$');

sealed class ComponentAnchor {
  ComponentAnchor(this.name, this.startNode);

  final String name;
  final web.Node startNode;
  late web.Node endNode;
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
    var params = ConfigParams(data != null ? jsonDecode(unescapeMarkerText(data!)) : {}, serverAnchors);
    return (builder as ClientBuilder)(params);
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
  ServerComponentAnchor(super.name, super.startNode);

  late final web.DocumentFragment fragment;
  late final List<ClientComponentAnchor> clientAnchors;
  final Map<String, Component Function(web.Element)> elementFactories = {};

  Future<void> resolve() async {
    await Future.wait(clientAnchors.map((a) => a.resolve()));
  }

  void recursivelyFindChildAnchors(ClientByName clientByName) {
    fragment = web.document.createDocumentFragment();

    web.Node? curr = startNode.nextSibling;
    while (curr != null && curr != endNode) {
      fragment.append(curr.cloneNode(true));
      curr = curr.nextSibling;
    }

    clientAnchors = _findAnchors(clientByName: clientByName, root: fragment, runEagerly: false);

    web.console.log(fragment);

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

      while (client.startNode.nextSibling != null && client.startNode.nextSibling != client.endNode) {
        final next = client.startNode.nextSibling!;
        next.parentNode?.removeChild(next);
      }


      client.startNode.parentNode?.replaceChild(web.document.createElement('${name}_$n'), client.startNode);
      client.endNode.parentNode?.removeChild(client.endNode);
    }

    web.console.log(fragment);
  }

  Component build() {
    return Builder(builder: (context) {
      return fragment.childNodes.toIterable().map((n) => RawNode(n, elementFactories: elementFactories));
    });
  }
}

List<ClientComponentAnchor> _findAnchors({required ClientByName clientByName, web.Node? root, bool runEagerly = true}) {
  var iterator = web.document.createNodeIterator(web.document, 128 /* NodeFilter.SHOW_COMMENT */);

  List<ComponentAnchor> anchors = [];
  List<ClientComponentAnchor> clientAnchors = [];

  web.Comment? currNode;
  while ((currNode = iterator.nextNode() as web.Comment?) != null) {
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
      start.text = '$clientMarkerPrefix${comp.name}';

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
