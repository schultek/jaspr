import 'dart:async';
import 'dart:convert';
import 'dart:html';

import '../../browser.dart';

typedef ClientBuilder = Component Function(ConfigParams);
typedef ClientLoader = FutureOr<ClientBuilder> Function();

/// Called by the shared client components entrypoint.
void registerClients(Map<String, ClientLoader> clients) {
  final Map<String, ClientBuilder> builders = {};
  _applyClients((name) {
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
  _applyClients((name) => clients[name]!);
}

class ConfigParams {
  ConfigParams(this._params, this.serverComponents);

  final Map<String, dynamic> _params;
  final Map<String, (Node, Node)> serverComponents;

  T get<T>(String key) {
    if (T == Component) {
      var sId = _params[key];
      assert(sId is String && sId.startsWith(r's$'));
      var s = serverComponents[sId.substring(2)];
      if (s != null) {
        var nodes = <Node>[];
        Node? curr = s.$1.nextNode;
        while (curr != null && curr != s.$2) {
          nodes.add(curr.clone(true));
          curr = curr.nextNode;
        }

        return Builder(builder: (context) {
          return nodes.map((n) => RawNode(n));
        }) as T;
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

void _applyClients(FutureOr<ClientBuilder> Function(String) fn) {
  var iterator = NodeIterator(document, NodeFilter.SHOW_COMMENT);

  List<(String, String?, Node, Map<String, (Node, Node)>?, bool)> nodes = [];

  Comment? currNode;
  while ((currNode = iterator.nextNode() as Comment?) != null) {
    var value = currNode!.nodeValue ?? '';

    print("VALUE $value");

    var match = _clientStartRegex.firstMatch(value);
    if (match != null) {
      assert(nodes.isEmpty || nodes.last.$5 == false,
          "Found directly nested client component anchor, which is not allowed.");

      var name = match.group(1)!;
      var data = match.group(2);
      nodes.add((name, data, currNode, {}, true));

      continue;
    }

    match = _clientEndRegex.firstMatch(value);
    if (match != null) {
      var name = match.group(1)!;
      assert(nodes.isNotEmpty && nodes.last.$1 == name,
          "Found client component end anchor without matching start anchor.");

      var comp = nodes.removeLast();
      var start = comp.$3;
      assert(start.parentNode == currNode.parentNode, "Found client component anchors with different parent nodes.");

      var between = (start, currNode);
      var params = ConfigParams(jsonDecode(comp.$2 ?? '{}'), comp.$4!);

      var builder = fn(name);
      if (builder is ClientBuilder) {
        _runClient(builder, params, between);
      } else {
        builder.then((b) => _runClient(b, params, between));
      }
      continue;
    }

    match = _serverStartRegex.firstMatch(value);
    if (match != null) {
      assert(nodes.isNotEmpty, "Found non-nested server component anchor, which is not allowed.");
      assert(nodes.last.$5 == true, "Found directly nested server component anchor, which is not allowed.");

      var name = match.group(1)!;
      nodes.add((name, null, currNode, null, false));

      continue;
    }

    match = _serverEndRegex.firstMatch(value);
    if (match != null) {
      var name = match.group(1)!;
      assert(nodes.isNotEmpty && nodes.last.$1 == name,
          "Found server component end anchor without matching start anchor.");

      var comp = nodes.removeLast();
      var start = comp.$3;
      assert(start.parentNode == currNode.parentNode, "Found server component anchors with different parent nodes.");

      assert(nodes.isNotEmpty && nodes.last.$4 != null, "Found server component without ancestor client component.");

      var between = (start, currNode);
      nodes.last.$4![name] = between;

      continue;
    }
  }
}

void _runClient(ClientBuilder builder, ConfigParams params, (Node, Node) between) {
  BrowserAppBinding().attachRootComponent(builder(params), attachBetween: between);
}
