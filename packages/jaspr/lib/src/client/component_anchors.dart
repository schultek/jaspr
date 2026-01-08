import 'dart:async';
import 'dart:convert';

import 'package:universal_web/web.dart' as web;

import '../../jaspr.dart';
import '../dom/validator.dart';
import 'options.dart';
import 'slotted_child_view.dart';

sealed class ComponentAnchor {
  ComponentAnchor(this.name, this.key, this.startNode);

  final String name;
  final String key;
  final web.Node startNode;
  late final web.Node endNode;
}

final Expando<ClientComponentAnchor> _clientAnchorExpando = Expando();

extension ClientAnchorExtension on web.Node {
  ClientComponentAnchor? get clientAnchor => _clientAnchorExpando[this];

  set clientAnchor(ClientComponentAnchor? anchor) {
    _clientAnchorExpando[this] = anchor;
  }
}

class ClientComponentAnchor extends ComponentAnchor {
  ClientComponentAnchor._(super.name, super.key, super.startNode, this.data);

  String? data;
  late FutureOr<ClientBuilder> builder;
  final Map<String, ServerComponentAnchor> serverAnchors = {};

  void Function(void Function())? _setState;

  late final Map<String, Object?> params = data != null
      ? jsonDecode(const DomValidator().unescapeMarkerText(data!)) as Map<String, Object?>
      : {};

  Future<void> resolve() async {
    final r = await (Future.value(builder), Future.wait(serverAnchors.values.map((a) => a.resolve()))).wait;
    builder = r.$1;
  }

  Component build() {
    assert(builder is ClientBuilder, 'ClientComponentAnchor was not resolved before calling build()');
    return StatefulBuilder(
      key: GlobalObjectKey(key),
      builder: (context, setState) {
        _setState = setState;
        final params = ClientParams(
          data != null
              ? jsonDecode(const DomValidator().unescapeMarkerText(data!)) as Map<String, Object?>
              : <String, Object?>{},
          serverAnchors,
        );
        return (builder as ClientBuilder)(params);
      },
    );
  }

  void rebuild(String? data, Map<String, ServerComponentAnchor> serverAnchors) {
    assert(_setState != null, 'ClientComponentAnchor was not built before calling rebuild()');
    _setState!(() {
      this.data = data;
      this.serverAnchors.clear();
      this.serverAnchors.addAll(serverAnchors);
    });
  }

  ChildSlot createSlot() {
    return _AnchorChildSlot(
      key: UniqueKey(),
      start: startNode,
      end: endNode,
      child: build(),
    );
  }
}

class _AnchorChildSlot extends ChildSlot {
  _AnchorChildSlot({required this.start, required this.end, required this.child, super.key});

  final web.Node start;
  final web.Node end;
  @override
  final Component child;

  @override
  ChildSlotRenderObject createRenderObject(SlottedDomRenderObject parent) {
    return ChildSlotRenderObject.between(parent, start, end);
  }

  @override
  bool canUpdate(ChildSlot oldComponent) {
    return oldComponent is _AnchorChildSlot && oldComponent.start == start && oldComponent.end == end;
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

    return SlottedChildView.withNodes(
      key: UniqueKey(),
      nodes: nodes,
      slots: [
        for (final client in clientAnchors) client.createSlot(),
      ],
    );
  }
}

final _clientStartRegex = RegExp('^${DomValidator.clientMarkerPrefixRegex}(\\S+)(?:\\s+#(\\S*))?(?:\\s+data=(.*))?\$');
final _clientEndRegex = RegExp('^/${DomValidator.clientMarkerPrefixRegex}(\\S+)\$');

final _serverStartRegex = RegExp('^s${DomValidator.clientMarkerPrefixRegex}(\\d+)(?:\\s+#(\\S*))?\$');
final _serverEndRegex = RegExp('^/s${DomValidator.clientMarkerPrefixRegex}(\\d+)\$');

FutureOr<ClientBuilder> getClientByName(String name) {
  final clients = Jaspr.options.clients;
  assert(clients.containsKey(name), "No client component registered with name '$name'.");
  return clients[name]!.loadedBuilder;
}

List<ClientComponentAnchor> extractAnchors({
  List<web.Node>? nodes,
}) {
  nodes ??= [?web.document.body];

  final List<ComponentAnchor> anchors = [];
  final List<ClientComponentAnchor> clientAnchors = [];
  final Map<String, int> clientKeyCounters = {};

  web.Comment? currNode;
  for (final rootNode in nodes) {
    final iterator = web.document.createNodeIterator(rootNode, 128 /* NodeFilter.SHOW_COMMENT */);

    while ((currNode = iterator.nextNode() as web.Comment?) != null) {
      final value = currNode!.nodeValue;
      if (value == null) continue;

      // Find client start anchor.
      if (_clientStartRegex.firstMatch(value) case final match?) {
        assert(
          anchors.isEmpty || anchors.last is ServerComponentAnchor,
          'Found directly nested client component anchor, which is not allowed.',
        );

        final name = match.group(1)!;
        final key = match.group(2);
        final data = match.group(3);

        final resolvedKey = key != null
            ? '@$name#$key'
            : (() {
                final count = clientKeyCounters[name] ?? -1;
                clientKeyCounters[name] = count + 1;
                return '@$name-${anchors.length}-$count';
              })();

        anchors.add(ClientComponentAnchor._(name, resolvedKey, currNode, data));
        continue;
      }

      // Find client end anchor.
      if (_clientEndRegex.firstMatch(value) case final match?) {
        final name = match.group(1)!;
        assert(
          anchors.isNotEmpty && anchors.last.name == name,
          'Found client component end anchor without matching start anchor.',
        );

        final comp = anchors.removeLast() as ClientComponentAnchor;

        final start = comp.startNode;
        assert(start.parentNode == currNode.parentNode, 'Found client component anchors with different parent nodes.');

        comp.endNode = currNode;
        comp.builder = getClientByName(name);

        // Remove the data string.
        start.textContent = '${DomValidator.clientMarkerPrefix}${comp.name}';

        start.clientAnchor = comp;
        if (anchors.isEmpty) {
          clientAnchors.add(comp);
        } else {
          (anchors.last as ServerComponentAnchor).clientAnchors.add(comp);
        }
        continue;
      }

      // Find server start anchor.
      if (_serverStartRegex.firstMatch(value) case final match?) {
        assert(anchors.isNotEmpty, 'Found non-nested server component anchor, which is not allowed.');
        assert(
          anchors.last is ClientComponentAnchor,
          'Found directly nested server component anchor, which is not allowed.',
        );

        final name = match.group(1)!;
        final key = match.group(2);

        final count = (anchors.last as ClientComponentAnchor).serverAnchors.length;
        final resolvedKey = key != null ? 's#$key' : 's-${anchors.length}-$count';

        anchors.add(ServerComponentAnchor(name, resolvedKey, currNode));

        continue;
      }

      // Find server end anchor.
      if (_serverEndRegex.firstMatch(value) case final match?) {
        final name = match.group(1)!;
        assert(
          anchors.isNotEmpty && anchors.last.name == name,
          'Found server component end anchor without matching start anchor.',
        );

        final comp = anchors.removeLast() as ServerComponentAnchor;

        final start = comp.startNode;
        assert(start.parentNode == currNode.parentNode, 'Found server component anchors with different parent nodes.');

        comp.endNode = currNode;

        assert(anchors.isNotEmpty, 'Found server component without ancestor client component.');
        (anchors.last as ClientComponentAnchor).serverAnchors[name] = comp;

        continue;
      }
    }
  }

  return clientAnchors;
}
