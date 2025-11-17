import 'dart:async';
import 'dart:convert';

import 'package:universal_web/web.dart' as web;

import '../foundation/validator.dart';
import '../framework/framework.dart';
import 'custom_node_component.dart';
import 'dom_render_object.dart';

typedef ClientLoader = FutureOr<ClientBuilder> Function();
typedef ClientBuilder = Component Function(Map<String, dynamic> params);

ClientLoader loadClient(Future<void> Function() loader, ClientBuilder builder) {
  return () => loader().then((_) => builder);
}

class ClientOptions {
  ClientOptions({this.clients = const {}});

  final Map<String, ClientLoader> clients;
}

class ClientApp extends Component {
  ClientApp({required this.options});

  final ClientOptions options;

  @override
  Element createElement() => _ClientAppElement(this);
}

class _ClientAppElement extends MultiChildRenderObjectElement {
  _ClientAppElement(ClientApp super.component);

  final Map<String, ClientBuilder> builders = {};
  late List<web.Node> nodes;
  final List<ClientComponentAnchor> anchors = [];

  FutureOr<ClientBuilder> getClientByName(String name) {
    final client = (builders[name] ?? (component as ClientApp).options.clients[name]!()) as FutureOr<ClientBuilder>;
    if (client is ClientBuilder) {
      return builders[name] = client;
    } else {
      return client.then((b) => builders[name] = b);
    }
  }

  @override
  void didMount() {
    final parent = parentRenderObjectElement!.renderObject;
    nodes = parent is HydratableDomRenderObject ? [...parent.toHydrate] : <web.Node>[];
    final anchors = _applyClients(getClientByName, root: nodes);

    for (final anchor in anchors) {
      if (anchor.builder is ClientBuilder) {
        this.anchors.add(anchor);
      } else {
        anchor
            .resolve()
            .then((b) {
              this.anchors.add(anchor);
              markNeedsBuild();
            })
            .onError((error, stackTrace) {
              print("Error loading client component '${anchor.name}': $error");
            });
      }
    }
    super.didMount();
  }

  @override
  List<Component> buildChildren() {
    return [
      for (final anchor in anchors)
        ClientComponent(
          key: GlobalObjectKey(anchor.key),
          anchor: anchor,
        ),
    ];
  }

  @override
  RenderObject createRenderObject() {
    final parent = parentRenderObjectElement!.renderObject;
    return DomRenderNodes(nodes, parent as DomRenderObject);
  }

  @override
  void updateRenderObject(covariant RenderObject renderObject) {}
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

sealed class ComponentAnchor {
  ComponentAnchor(this.name, this.key, this.startNode);

  final String name;
  final String key;
  final web.Node startNode;
  late web.Node endNode;
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

  Future<void> resolve() async {
    var r = await builder;
    builder = r;
  }

  Component build() {
    assert(builder is ClientBuilder, "ClientComponentAnchor was not resolved before calling build()");
    final params =
        data !=
            null //
        ? jsonDecode(const DomValidator().unescapeMarkerText(data!)) as Map<String, dynamic>
        : <String, dynamic>{};
    return (builder as ClientBuilder)(params);
  }
}

final _clientStartRegex = RegExp('^${DomValidator.clientMarkerPrefixRegex}(\\S+)(?:\\s+data=(.*))?\$');
final _clientEndRegex = RegExp('^/${DomValidator.clientMarkerPrefixRegex}(\\S+)\$');

List<ClientComponentAnchor> _applyClients(FutureOr<ClientBuilder> Function(String) fn, {List<web.Node>? root}) {
  root ??= [web.document];

  List<ComponentAnchor> anchors = [];
  List<ClientComponentAnchor> clientAnchors = [];
  Map<String, int> clientKeyCounters = {};

  web.Comment? currNode;
  for (final rootNode in root) {
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

        final key = (() {
          var count = clientKeyCounters[name] ?? -1;
          clientKeyCounters[name] = count + 1;
          return '@$name-$count';
        })();

        anchors.add(ClientComponentAnchor(name, key, currNode, data));
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
        comp.builder = fn(name);

        // Remove the data string.
        start.textContent = '${DomValidator.clientMarkerPrefix}${comp.name}';

        clientAnchors.add(comp);
        continue;
      }
    }
  }

  return clientAnchors;
}
