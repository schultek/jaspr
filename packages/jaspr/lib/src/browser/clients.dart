import 'dart:async';
import 'dart:convert';

import 'package:universal_web/web.dart' as web;

import '../foundation/validator.dart';
import '../framework/framework.dart';
import 'browser_binding.dart';
import 'dom_render_object.dart';
import 'utils.dart';

typedef ClientLoader = FutureOr<ClientBuilder> Function();
typedef ClientBuilder = Component Function(ConfigParams params);

typedef ClientByName = FutureOr<ClientBuilder> Function(String);

/// Called by the shared client components entrypoint.
void registerClients(Map<String, ClientLoader> clients) {
  final Map<String, ClientBuilder> builders = {};
  _findAnchors(
    clientByName: (name) {
      final client = (builders[name] ?? clients[name]!()) as FutureOr<ClientBuilder>;
      if (client is ClientBuilder) {
        return builders[name] = client;
      } else {
        return client.then((b) => builders[name] = b);
      }
    },
  );
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
      assert(sId is String && sId.startsWith('s${DomValidator.clientMarkerPrefixRegex}'));
      var s = serverComponents[sId.substring(2)];
      if (s != null) {
        return s.build() as T;
      } else {
        return const Component.text("") as T;
      }
    }
    if (_params[key] is! T) {
      print("$key is not $T: ${_params[key]}");
    }
    return _params[key];
  }
}

final _clientStartRegex = RegExp('^${DomValidator.clientMarkerPrefixRegex}(\\S+)(?:\\s+data=(.*))?\$');
final _clientEndRegex = RegExp('^/${DomValidator.clientMarkerPrefixRegex}(\\S+)\$');

final _serverStartRegex = RegExp('^s${DomValidator.clientMarkerPrefixRegex}(\\d+)\$');
final _serverEndRegex = RegExp('^/s${DomValidator.clientMarkerPrefixRegex}(\\d+)\$');

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
    var params = ConfigParams(
      data != null ? jsonDecode(const DomValidator().unescapeMarkerText(data!)) : {},
      serverAnchors,
    );
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

  final List<Component> children = [];

  Future<void> resolve() async {
    await Future.wait(clientAnchors.map((a) => a.resolve()));
  }

  void recursivelyFindChildAnchors(ClientByName clientByName) {
    fragment = web.document.createDocumentFragment();

    web.Node? curr = startNode.nextSibling;
    while (curr != null && curr != endNode) {
      final next = curr.nextSibling;
      fragment.append(curr);
      curr = next;
    }

    clientAnchors = _findAnchors(clientByName: clientByName, root: fragment, runEagerly: false);

    for (var client in clientAnchors) {
      children.add(
        ClientComponent(
          key: GlobalKey(),
          anchor: client,
        ),
      );
    }
  }

  Component build() {
    return ServerComponentNode(key: GlobalKey(), fragment, children);
  }
}

List<ClientComponentAnchor> _findAnchors({required ClientByName clientByName, web.Node? root, bool runEagerly = true}) {
  var iterator = web.document.createNodeIterator(root ?? web.document, 128 /* NodeFilter.SHOW_COMMENT */);

  List<ComponentAnchor> anchors = [];
  List<ClientComponentAnchor> clientAnchors = [];

  web.Comment? currNode;
  while ((currNode = iterator.nextNode() as web.Comment?) != null) {
    var value = currNode!.nodeValue ?? '';

    // Find client start anchor.
    var match = _clientStartRegex.firstMatch(value);
    if (match != null) {
      assert(
        anchors.isEmpty || anchors.last is ServerComponentAnchor,
        "Found directly nested client component anchor, which is not allowed.",
      );

      var name = match.group(1)!;
      var data = match.group(2);
      anchors.add(ClientComponentAnchor(name, currNode, data));

      continue;
    }

    // Find client end anchor.
    match = _clientEndRegex.firstMatch(value);
    if (match != null) {
      var name = match.group(1)!;
      assert(
        anchors.isNotEmpty && anchors.last.name == name,
        "Found client component end anchor without matching start anchor.",
      );

      var comp = anchors.removeLast() as ClientComponentAnchor;

      // Nested client components are handled recursively.
      if (anchors.isNotEmpty) continue;

      var start = comp.startNode;
      assert(start.parentNode == currNode.parentNode, "Found client component anchors with different parent nodes.");

      comp.endNode = currNode;
      comp.builder = clientByName(name);

      // Remove the data string.
      start.textContent = '${DomValidator.clientMarkerPrefix}${comp.name}';

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
      assert(
        anchors.last is ClientComponentAnchor,
        "Found directly nested server component anchor, which is not allowed.",
      );

      var name = match.group(1)!;
      anchors.add(ServerComponentAnchor(name, currNode));

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

class NestedClientDomRenderObject extends DomRenderObject with MultiChildDomRenderObject, HydratableDomRenderObject {
  NestedClientDomRenderObject(this.node, DomRenderObject parent, [List<web.Node>? nodes]) {
    this.parent = parent;
    toHydrate = [...nodes ?? node.childNodes.toIterable()];
    beforeStart = toHydrate.firstOrNull?.previousSibling;
  }

  factory NestedClientDomRenderObject.between(DomRenderObject parent, web.Node start, web.Node end) {
    final nodes = <web.Node>[];
    web.Node? curr = start.nextSibling;
    while (curr != null && curr != end) {
      nodes.add(curr);
      curr = curr.nextSibling;
    }
    return NestedClientDomRenderObject(start.parentElement!, parent, nodes);
  }

  @override
  final web.Element node;
  late final web.Node? beforeStart;

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    attachChild(child, after, startNode: beforeStart);
  }

  @override
  void remove(DomRenderObject child) {
    removeChild(child);
  }
}

class ClientComponent extends Component {
  ClientComponent({required this.anchor, super.key});

  final ClientComponentAnchor anchor;

  @override
  Element createElement() => ClientComponentElement(this);
}

class ClientComponentElement extends MultiChildRenderObjectElement {
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
  RenderObject createRenderObject() {
    return NestedClientDomRenderObject.between(
      parentRenderObjectElement!.renderObject as DomRenderObject,
      component.anchor.startNode,
      component.anchor.endNode,
    );
  }

  @override
  void updateRenderObject(RenderObject renderObject) {}
}

class ServerComponentNode extends Component {
  ServerComponentNode(this.fragment, this.children, {super.key});

  final web.DocumentFragment fragment;
  final List<Component> children;

  @override
  Element createElement() => ServerComponentNodeElement(this);
}

class ServerComponentNodeElement extends MultiChildRenderObjectElement {
  ServerComponentNodeElement(ServerComponentNode super.component);

  @override
  ServerComponentNode get component => super.component as ServerComponentNode;

  @override
  void update(ServerComponentNode newComponent) {
    assert(
      newComponent.fragment == component.fragment,
      'ServerComponentNode cannot be updated with a different fragment.',
    );
    super.update(newComponent);
  }

  @override
  List<Component> buildChildren() {
    return component.children;
  }

  @override
  RenderObject createRenderObject() {
    final parent = parentRenderObjectElement!.renderObject;
    return ServerComponentDomRenderObject(component.fragment, parent as DomRenderObject);
  }

  @override
  void updateRenderObject(RenderObject renderObject) {}

  @override
  void unmount() {
    super.unmount();
    _clearEventListeners(this);
  }

  static _clearEventListeners(Element e) {
    if (e case RenderObjectElement(renderObject: DomRenderElement r)) {
      r.events?.forEach((type, binding) {
        binding.clear();
      });
      r.events = null;
    }

    e.visitChildren(_clearEventListeners);
  }
}

class ServerComponentDomRenderObject extends DomRenderFragment {
  ServerComponentDomRenderObject(super.fragment, super.parent) : super.from() {
    if (node.childNodes.length > 0) {
      firstChild = DomRenderNode(node.childNodes.item(0)!);
      lastChild = DomRenderNode(node.childNodes.item(node.childNodes.length - 1)!);
    }
  }

  @override
  void attach(covariant RenderObject child, {covariant RenderObject? after}) {
    if (child is NestedClientDomRenderObject) {
      return;
    }
    throw UnsupportedError('Server nodes cannot have children attached to them.');
  }

  @override
  void remove(covariant RenderObject child) {
    throw UnsupportedError('Server nodes cannot have children removed from them.');
  }
}

class DomRenderNode extends DomRenderObject {
  DomRenderNode(this.node);

  @override
  final web.Node node;

  @override
  void attach(covariant RenderObject child, {covariant RenderObject? after}) {
    throw UnsupportedError('Raw nodes cannot have children attached to them.');
  }

  @override
  void remove(covariant RenderObject child) {
    throw UnsupportedError('Text nodes cannot have children removed from them.');
  }

  @override
  void finalize() {}

  @override
  web.Node? retakeNode(bool Function(web.Node node) visitNode) {
    return null; // Not applicable for raw nodes
  }
}
