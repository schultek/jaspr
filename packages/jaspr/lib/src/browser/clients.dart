import 'dart:async';
import 'dart:convert';
import 'dart:html';

import '../foundation/marker_utils.dart';
import '../framework/framework.dart';
import 'browser_binding.dart';

typedef ClientLoader = FutureOr<ClientBuilder> Function();
typedef ClientBuilder = Component Function(Map<String, dynamic> params);

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

void runAppWithParams(ClientBuilder appBuilder) {
  _applyClients((_) => appBuilder);
}

final _compStartRegex = RegExp('^$clientMarkerPrefixRegex(\\S+)(?:\\s+data=(.*))?\$');
final _compEndRegex = RegExp('^/$clientMarkerPrefixRegex(\\S+)\$');

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
        start.text = '$clientMarkerPrefix${comp.$1}';

        Map<String, dynamic> params = comp.$2 != null ? jsonDecode(unescapeMarkerText(comp.$2!)) : {};
        unawaited(_runBuilder(name, fn(name), params, between));
      }
    }
  }
}

Future<void> _runBuilder(
  String name,
  FutureOr<ClientBuilder> builder,
  Map<String, dynamic> params,
  (Node, Node) between,
) async {
  if (builder is Future<ClientBuilder>) {
    builder = await builder;
  }
  try {
    BrowserAppBinding().attachRootComponent((builder as ClientBuilder)(params), attachBetween: between);
  } catch (e, st) {
    throw Error.throwWithStackTrace(
      "Failed to attach client component '$name'. "
      "The following error occurred: $e",
      st,
    );
  }
}
