import 'dart:convert';
import 'dart:developer';

import 'package:meta/meta.dart';
import 'package:universal_web/web.dart' as web;

import '../client/slotted_child_view.dart';
import '../foundation/change_notifier.dart';
import '../foundation/constants.dart';
import '../foundation/diagnostics.dart';
import '../framework/framework.dart';
import 'models/tree_element.dart';

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

  final ValueNotifier<TreeElement?> selectedElement = ValueNotifier<TreeElement?>(null);

  bool get debugVerboseLoggingActive => _debugVerboseLoggingActive;
  bool _debugVerboseLoggingActive = false;

  @protected
  set debugVerboseLoggingActive(bool value) {
    _debugVerboseLoggingActive = value;
  }

  void attachDebugDataToDocument() {
    if (!kIsWeb) return;

    if (debugData case {'serverTree': final Map<String, Object?> serverTreeMap}) {
      final serverTree = DiagnosticsNode.fromJsonMap(serverTreeMap);

      DiagnosticsNode? findDocumentRoot(DiagnosticsNode node) {
        if (node.name == 'DomElement' && node.properties?.getTagForDomElement() == 'html') return node;
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
        final rootElement = RemoteElement.fromDiagnosticsNode(documentRoot);
        matchTreeChildren(rootElement, web.document.documentElement!);
      }
    }
  }

  void matchTreeChildren(RemoteElement treeParent, web.Element domParent) {
    if (domParent.children.length <= 0) return;

    web.Element? currentDomNode = domParent.children.item(0)!;
    final toVisit = [...treeParent.children.reversed];

    while (currentDomNode != null && toVisit.isNotEmpty) {
      final currentTreeNode = toVisit.removeLast();
      final tag = currentTreeNode.name == 'DomElement' ? currentTreeNode.properties.getTagForDomElement() : null;

      if (tag != null && tag == currentDomNode.tagName.toLowerCase()) {
        RemoteElement.nodeRegistry[currentDomNode] = currentTreeNode;
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
      LocalElement.nodeRegistry[node] = element;
    }
  }

  void initServiceExtensions() {
    registerExtension('ext.jaspr.inspector.setSelection', (method, parameters) async {
      final id = parameters['id'];
      if (id is String) {
        if (LocalElement.forId(id) case final element?) {
          selectedElement.value = element;
          return ServiceExtensionResponse.result('{"success":true}');
        }
        if (RemoteElement.forId(id) case final element?) {
          selectedElement.value = element;
          return ServiceExtensionResponse.result('{"success":true}');
        }
      }

      return ServiceExtensionResponse.error(ServiceExtensionResponse.invalidParams, 'Invalid or unknown element ID');
    });
  }

  void selectElement(TreeElement element, String url) {
    selectedElement.value = element;
    postEvent('ext.jaspr.inspector.selectionChanged', {
      'id': element.id,
      'url': url,
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
      'tree': _elementToNode(rootElement).toJsonMap(),
      'info': {
        'attachTarget': attachTarget,
        'title': web.window.document.title,
      },
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
        DiagnosticsProperty(name: 'id', value: LocalElement.toId(element)),
        ...element.debugFillProperties(),
        if (extensions?[element] case final extension?) ...extension.debugFillProperties(),
      ],
      children: children,
    );
  }
}
