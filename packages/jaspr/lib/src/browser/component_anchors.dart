import 'dart:async';
import 'dart:convert';

import 'package:universal_web/web.dart' as web;

import '../../jaspr.dart';
import 'options.dart';

sealed class ComponentAnchor {
  ComponentAnchor(this.name, this.startNode);

  final String name;
  final web.Node startNode;
  late web.Node endNode;
}

class ClientComponentAnchor extends ComponentAnchor {
  ClientComponentAnchor(super.name, super.startNode, this.data);

  String? data;
  late FutureOr<ClientBuilder> builder;

  late final params = data != null
      ? jsonDecode(const DomValidator().unescapeMarkerText(data!)) as Map<String, dynamic>
      : <String, dynamic>{};

  Future<void> resolve() async {
    var r = await builder;
    builder = r;
  }

  Component build() {
    assert(builder is ClientBuilder, "ClientComponentAnchor was not resolved before calling build()");
    return (builder as ClientBuilder)(params);
  }
}

final _clientStartRegex = RegExp('^${DomValidator.clientMarkerPrefixRegex}(\\S+)(?:\\s+data=(.*))?\$');
final _clientEndRegex = RegExp('^/${DomValidator.clientMarkerPrefixRegex}(\\S+)\$');

List<ClientComponentAnchor> extractClientAnchors(
  FutureOr<ClientBuilder> Function(String) byName, {
  List<web.Node>? nodes,
}) {
  nodes ??= [?web.document.body];

  List<ComponentAnchor> anchors = [];
  List<ClientComponentAnchor> clientAnchors = [];

  web.Comment? currNode;
  for (final rootNode in nodes) {
    final iterator = web.document.createNodeIterator(rootNode, 128 /* NodeFilter.SHOW_COMMENT */);

    while ((currNode = iterator.nextNode() as web.Comment?) != null) {
      final value = currNode!.nodeValue ?? '';

      // Find client start anchor.
      var match = _clientStartRegex.firstMatch(value);
      if (match != null) {
        assert(
          anchors.isEmpty,
          "Found nested client component anchor, which is not allowed.",
        );

        final name = match.group(1)!;
        final data = match.group(2);

        anchors.add(ClientComponentAnchor(name, currNode, data));
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
        comp.builder = byName(name);

        // Remove the data string.
        start.textContent = '${DomValidator.clientMarkerPrefix}${comp.name}';

        clientAnchors.add(comp);
        continue;
      }
    }
  }

  return clientAnchors;
}
