import 'dart:async';
import 'dart:convert';

import 'package:web/web.dart' as web;

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

final _escapeRegex = RegExp(r'&(amp|lt|gt);');

void _applyClients(FutureOr<ClientBuilder> Function(String) fn) {
  var iterator = web.document.createNodeIterator(web.document, 128 /* NodeFilter.SHOW_COMMENT */);

  List<(String, String?, web.Node)> nodes = [];

  web.Comment? currNode;
  while ((currNode = iterator.nextNode() as web.Comment?) != null) {
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

        final data = (comp.$2 ?? '{}').replaceAllMapped(_escapeRegex,
            (match) => switch (match.group(1)) { 'amp' => '&', 'lt' => '<', 'gt' => '>', _ => match.group(0)! });
        var params = ConfigParams(jsonDecode(data));

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
