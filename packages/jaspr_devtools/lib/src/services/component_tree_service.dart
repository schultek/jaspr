import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:vm_service/vm_service.dart';

import '../models/tree_state.dart';
import 'dev_tools_service.dart';

class ComponentTreeService with ChangeNotifier {
  ComponentTreeService(this.service) {
    service.addListener(onServiceUpdated);
  }

  final JasprDevToolsService service;

  StreamSubscription<Event>? _clientTreeSub;
  StreamSubscription<Event>? _serverTreeSub;

  final Map<String, TreeState> _trees = {};

  String? selectedElementId;

  List<String> get allUrls => _trees.keys.toList();

  void removeTree(String url) {
    _trees.remove(url);
    notifyListeners();
  }

  DiagnosticsNode? getTree(String url, {TreeMode mode = TreeMode.combined}) {
    final tree = _trees[url];
    if (tree == null) return null;
    return switch (mode) {
      TreeMode.client => tree.clientTree?.tree,
      TreeMode.server => tree.serverTree?.tree,
      TreeMode.combined => _getCombinedTree(
        tree.serverTree,
        tree.clientTree,
      ),
    };
  }

  DiagnosticsNode _getCombinedTree(ServerTree? serverTree, ClientTree? clientTree) {
    final Map<String, DiagnosticsNode> clientAnchors = {};

    void visitClientNode(DiagnosticsNode? node) {
      if (node == null) return;
      if (node.properties?.get('component')?.properties?.get('kind')?.value == 'client-anchor') {
        final anchorName = node.properties?.get('component')?.properties?.get('anchor-name')?.value.toString();
        if (anchorName != null) {
          clientAnchors[anchorName] = node;
          return;
        }
      }
      if (node.children case final children?) {
        for (final child in children) {
          visitClientNode(child);
        }
      }
    }

    visitClientNode(clientTree?.tree);

    print('client anchors: $clientAnchors');

    if (clientAnchors.isEmpty) {
      return serverTree?.tree ?? DiagnosticsNode(name: 'root');
    }

    List<DiagnosticsNode> makeCombinedNode(DiagnosticsNode serverNode) {
      if (serverNode.properties?.get('kind')?.value == 'client-component') {
        final anchorName = serverNode.properties?.get('anchor-name')?.value.toString();
        if (clientAnchors[anchorName] case final clientNode?) {
          return clientNode.children ?? [];
        }
      }
      if (serverNode.children case final children?) {
        return [
          DiagnosticsNode(
            name: serverNode.name,
            properties: serverNode.properties,
            children: children.expand(makeCombinedNode).toList(),
          ),
        ];
      }
      return [serverNode];
    }

    return makeCombinedNode(serverTree?.tree ?? DiagnosticsNode(name: 'root')).first;
  }

  void onServiceUpdated() {
    _clientTreeSub?.cancel();
    _serverTreeSub?.cancel();

    if (service.clientVmService case final clientVmService?) {
      _clientTreeSub = clientVmService.onExtensionEvent.listen((event) {
        if (event.extensionKind == 'ext.jaspr.clientTree') {
          if (event.extensionData?.data case {
            'id': final String id,
            'url': final String url,
            'attachTarget': final String? attachTarget,
            'tree': final Map<String, Object?> treeJson,
          }) {
            if (_trees[url] case final tree?) {
              if (tree.id != id) {
                if (tree.timestamp > (event.timestamp ?? 0)) {
                  return;
                }
                tree.id = id;
                tree.serverTree = null;
              }
              final node = _tagTree(DiagnosticsNode.fromJsonMap(treeJson), 'client');
              tree.clientTree = ClientTree(
                attachTarget: attachTarget ?? '',
                tree: node,
              );
              tree.timestamp = event.timestamp ?? 0;
            } else {
              final node = _tagTree(DiagnosticsNode.fromJsonMap(treeJson), 'client');
              _trees[url] = TreeState(
                url: url,
                id: id,
                timestamp: event.timestamp ?? 0,
                clientTree: ClientTree(
                  attachTarget: attachTarget ?? '',
                  tree: node,
                ),
              );
            }
            print('client tree updated $url: ${_trees[url]!.id} ${_trees[url]!.clientTree} ${_trees[url]!.serverTree}');
            notifyListeners();
          }
        }
      });
    }
    if (service.serverVmService case final serverVmService?) {
      _serverTreeSub = serverVmService.onExtensionEvent.listen((event) {
        if (event.extensionKind == 'ext.jaspr.serverTree') {
          if (event.extensionData?.data case {
            'id': final String id,
            'url': final String url,
            'tree': final Map<String, Object?> treeJson,
          }) {
            if (_trees[url] case final tree?) {
              if (tree.id != id) {
                if (tree.timestamp > (event.timestamp ?? 0)) {
                  return;
                }
                tree.id = id;
                tree.clientTree = null;
              }
              final node = _tagTree(DiagnosticsNode.fromJsonMap(treeJson), 'server');
              tree.serverTree = ServerTree(
                tree: node,
              );
              tree.timestamp = event.timestamp ?? 0;
            } else {
              final node = _tagTree(DiagnosticsNode.fromJsonMap(treeJson), 'server');
              _trees[url] = TreeState(
                url: url,
                id: id,
                timestamp: event.timestamp ?? 0,
                serverTree: ServerTree(
                  tree: node,
                ),
              );
            }
            print('server tree updated $url: ${_trees[url]!.id} ${_trees[url]!.clientTree} ${_trees[url]!.serverTree}');
            notifyListeners();
          }
        }
      });
    }
  }

  DiagnosticsNode _tagTree(DiagnosticsNode node, String environment) {
    var props = node.properties?.toList() ?? <DiagnosticsProperty>[];
    if (!props.any((p) => p.name == 'environment')) {
      props.add(DiagnosticsProperty(name: 'environment', value: environment));
    }

    return DiagnosticsNode(
      name: node.name,
      properties: props,
      children: node.children?.map((c) => _tagTree(c, environment)).toList(),
    );
  }

  @override
  void dispose() {
    service.removeListener(onServiceUpdated);
    super.dispose();
  }
}
