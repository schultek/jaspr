import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:html/parser.dart';

import '../framework/framework.dart';
import 'browser_binding.dart';

typedef ClientLoader = FutureOr<ClientBuilder> Function();
typedef ClientBuilder = Component Function(ConfigParams);

class ConfigParams {
  final Map<String, dynamic> _params;

  ConfigParams(this._params);

  T get<T>(String key) {
    if (_params[key] is! T) {
      print("$key is not $T: ${_params[key]}");
    }
    return _params[key];
  }
}

void registerClientsSync(Map<String, ClientBuilder> clients) {
  _applyClients((name) => clients[name]!);
}

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

ClientLoader loadClient(Future<void> Function() loader, ClientBuilder builder) {
  return () => loader().then((_) => builder);
}

final _compStartRegex = RegExp(r'^\$(\S+)(?:\s+data=(.*))?$');
final _compEndRegex = RegExp(r'^/\$(\S+)$');

void _applyClients(FutureOr<ClientBuilder> Function(String) fn) {
  var iterator = NodeIterator(document, NodeFilter.SHOW_COMMENT);

  List<(String, String?, Node)> nodes = [];

  Comment? currNode;
  while ((currNode = iterator.nextNode() as Comment?) != null) {
    var value = currNode!.nodeValue ?? '';
    var match = _compStartRegex.firstMatch(value);
    if (match != null) {
      var name = match.group(1)!;
      var data = match.group(2);

      nodes.add((name, data, currNode));
    }

    match = _compEndRegex.firstMatch(value);
    if (match != null) {
      var name = match.group(1)!;

      if (nodes.last.$1 == name) {
        var comp = nodes.removeLast();
        var start = comp.$3;
        assert(start.parentNode == currNode.parentNode);

        var between = (start, currNode);

        // Remove the data string.
        start.text = '\$${comp.$1}';

        var params = ConfigParams(jsonDecode(parseFragment(comp.$2 ?? '{}').text!));

        var builder = fn(name);
        if (builder is ClientBuilder) {
          BrowserAppBinding().attachRootComponent(builder(params), attachBetween: between);
        } else {
          builder.then((b) => BrowserAppBinding().attachRootComponent(b(params), attachBetween: between));
        }
      }
    }
  }
}

void runAppWithParams(ClientBuilder appBuilder) {
  _applyClients((_) => appBuilder);
}
