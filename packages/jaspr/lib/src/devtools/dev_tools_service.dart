import 'dart:convert';
import 'dart:developer';

import 'package:meta/meta.dart';
import 'package:universal_web/web.dart' as web;

import '../client/slotted_child_view.dart';
import '../foundation/change_notifier.dart';
import '../foundation/constants.dart';
import '../foundation/diagnostics.dart';
import '../framework/framework.dart';

class ServerElement extends DiagnosticsNode {
  ServerElement({
    required super.name,
    this.parent,
    required super.properties,
    required this.children,
    this.node,
  }) : super(children: children);

  final ServerElement? parent;
  @override
  // ignore: overridden_fields
  final List<ServerElement> children;

  web.Element? node;

  factory ServerElement.fromDiagnosticsNode(DiagnosticsNode node, {ServerElement? parent}) {
    final element = ServerElement(
      name: node.name,
      parent: parent,
      properties: node.properties ?? [],
      children: [],
    );

    if (node.children case final children?) {
      element.children.addAll([
        for (final child in children) ServerElement.fromDiagnosticsNode(child, parent: element),
      ]);
    }
    return element;
  }
}

extension on DiagnosticsNode {
  String? _getTagForDomElement() {
    if (name != 'DomElement') return null;
    return properties
        ?.where((p) => p.name == 'component')
        .firstOrNull
        ?.properties
        ?.where((p) => p.name == 'tag')
        .firstOrNull
        ?.value
        .toString();
  }
}

class DevToolsService {
  static final instance = DevToolsService._();

  DevToolsService._() {
    if (kIsWeb) {
      initServiceExtensions();
    }
  }

  final Map<String, Object?> debugData = () {
    if (!kIsWeb) return <String, Object?>{};

    final data = web.document.querySelector('meta[name="jaspr-debug-data"]')?.getAttribute('content');
    return jsonDecode(data ?? '{}') as Map<String, Object?>;
  }();

  final Expando<Element> domRegistry = Expando<Element>();
  final Expando<ServerElement> serverNodeRegistry = Expando<ServerElement>();

  final ValueNotifier<Object?> selectedElement = ValueNotifier<Object?>(null);

  bool get debugVerboseLoggingActive => _debugVerboseLoggingActive;
  bool _debugVerboseLoggingActive = false;

  @protected
  set debugVerboseLoggingActive(bool value) {
    _debugVerboseLoggingActive = value;
  }

  final Map<String, WeakReference<Element>> _idToElement = {};
  final Map<String, WeakReference<ServerElement>> _idToServerElement = {};
  final Expando<String> _elementToId = Expando<String>();
  int _nextId = 0;

  void attachDebugDataToDocument() {
    if (!kIsWeb) return;

    if (debugData case {'serverTree': final Map<String, Object?> serverTreeMap}) {
      final serverTree = DiagnosticsNode.fromJsonMap(serverTreeMap);

      DiagnosticsNode? findDocumentRoot(DiagnosticsNode node) {
        if (node._getTagForDomElement() == 'html') return node;
        if (node.children case final children?) {
          for (final child in children) {
            final found = findDocumentRoot(child);
            if (found != null) return found;
          }
        }
        return null;
      }

      final documentRoot = findDocumentRoot(serverTree);
      if (documentRoot != null) {
        final rootElement = ServerElement.fromDiagnosticsNode(documentRoot);
        fillServerElementIds(rootElement);
        matchTreeChildren(rootElement, web.document.documentElement!);
      }
    }
  }

  void fillServerElementIds(ServerElement element) {
    final id = element.properties?.where((p) => p.name == 'id').firstOrNull?.value.toString();
    if (id != null) {
      _idToServerElement[id] = WeakReference(element);
    }
    for (final child in element.children) {
      fillServerElementIds(child);
    }
  }

  void matchTreeChildren(ServerElement treeParent, web.Element domParent) {
    if (domParent.children.length <= 0) return;

    web.Element? currentDomNode = domParent.children.item(0)!;
    final toVisit = [...treeParent.children.reversed];

    while (currentDomNode != null && toVisit.isNotEmpty) {
      final currentTreeNode = toVisit.removeLast();
      final tag = currentTreeNode._getTagForDomElement();

      if (tag != null && tag == currentDomNode.tagName.toLowerCase()) {
        serverNodeRegistry[currentDomNode] = currentTreeNode;
        currentTreeNode.node = currentDomNode;
        matchTreeChildren(currentTreeNode, currentDomNode);
        currentDomNode = currentDomNode.nextElementSibling;
      } else {
        if (tag == null) {
          toVisit.addAll(currentTreeNode.children.reversed);
        }
      }
    }
  }

  void registerRenderObject(RenderObjectElement element) {
    final renderObject = element.renderObject;
    if (renderObject is ChildSlotRenderObject) return;
    final node = renderObject.node;
    if (node != null) {
      domRegistry[node] = element;
    }
  }

  String toId(Element element) {
    var id = _elementToId[element];
    if (id == null) {
      id = '\$${kIsWeb ? 'c' : 's'}${_nextId++}';
      _elementToId[element] = id;
      _idToElement[id] = WeakReference(element);
    }
    return id;
  }

  void initServiceExtensions() {
    registerExtension('ext.jaspr.inspector.setSelection', (method, parameters) async {
      final id = parameters['id'];
      if (id is String && _idToElement.containsKey(id)) {
        final element = _idToElement[id]?.target;
        if (element != null) {
          selectedElement.value = element;
          return ServiceExtensionResponse.result('{"success":true}');
        }
      }

      if (id is String && _idToServerElement.containsKey(id)) {
        final element = _idToServerElement[id]?.target;
        if (element != null) {
          selectedElement.value = element;
          return ServiceExtensionResponse.result('{"success":true}');
        }
      }

      return ServiceExtensionResponse.error(ServiceExtensionResponse.invalidParams, 'Invalid or unknown element ID');
    });
  }

  void selectElement(Element element) {
    selectedElement.value = element;
    postEvent('ext.jaspr.inspector.selectionChanged', {
      'id': toId(element),
      'elementType': element.runtimeType.toString(),
    });
  }

  void sendServerTree(
    String? id,
    String url,
    Element rootElement,
    Map<Element, Diagnosticable> extensions, [
    void Function(DiagnosticsNode node)? onTreeBuilt,
  ]) {
    final tree = _elementToNode(rootElement, extensions);
    onTreeBuilt?.call(tree);
    postEvent('ext.jaspr.serverTree', {
      'id': id,
      'url': url,
      'tree': tree.toJsonMap(),
    });
  }

  void sendClientTree(String url, String attachTarget, Element rootElement) {
    postEvent('ext.jaspr.clientTree', {
      'id': debugData['renderId'],
      'url': url,
      'attachTarget': attachTarget,
      'tree': _elementToNode(rootElement).toJsonMap(),
    });
  }

  DiagnosticsNode _elementToNode(Element element, [Map<Element, Diagnosticable>? extensions]) {
    final children = <DiagnosticsNode>[];
    element.debugVisitChildren((element) {
      children.add(_elementToNode(element, extensions));
    });

    return DiagnosticsNode(
      name: element.runtimeType.toString(),
      properties: [
        DiagnosticsProperty(name: 'id', value: toId(element)),
        ...element.debugFillProperties(),
        if (extensions?[element] case final extension?) ...extension.debugFillProperties(),
      ],
      children: children,
    );
  }
}
