import 'dart:async';
import 'dart:js_interop';

import 'package:jaspr/jaspr.dart';
import 'package:vm_service/vm_service.dart';
import 'package:web/web.dart' as web;

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

  List<String> get allUrls => _trees.keys.toList();

  void removeTree(String url) {
    _trees.remove(url);
    notifyListeners();
  }

  DiagnosticsNode? getTree(String url, {TreeMode mode = TreeMode.combined}) {
    final tree = _trees[url];
    print('getTree $url $mode $tree');
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

    DiagnosticsNode makeCombinedNode(DiagnosticsNode serverNode) {
      if (serverNode.properties?.get('kind')?.value == 'client-component') {
        final anchorName = serverNode.properties?.get('anchor-name')?.value.toString();
        if (clientAnchors[anchorName] case final clientNode?) {
          return DiagnosticsNode(
            name: 'ClientComponent',
            properties: serverNode.properties,
            children: [clientNode],
          );
        }
      }
      if (serverNode.children case final children?) {
        return DiagnosticsNode(
          name: serverNode.name,
          properties: serverNode.properties,
          children: children.map(makeCombinedNode).toList(),
        );
      }
      return serverNode;
    }

    return makeCombinedNode(serverTree?.tree ?? DiagnosticsNode(name: 'root'));
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
              tree.clientTree = ClientTree(
                attachTarget: attachTarget ?? '',
                tree: DiagnosticsNode.fromJsonMap(treeJson),
              );
              tree.timestamp = event.timestamp ?? 0;
            } else {
              _trees[url] = TreeState(
                url: url,
                id: id,
                timestamp: event.timestamp ?? 0,
                clientTree: ClientTree(
                  attachTarget: attachTarget ?? '',
                  tree: DiagnosticsNode.fromJsonMap(treeJson),
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
              tree.serverTree = ServerTree(
                tree: DiagnosticsNode.fromJsonMap(treeJson),
              );
              tree.timestamp = event.timestamp ?? 0;
            } else {
              _trees[url] = TreeState(
                url: url,
                id: id,
                timestamp: event.timestamp ?? 0,
                serverTree: ServerTree(
                  tree: DiagnosticsNode.fromJsonMap(treeJson),
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

  @override
  void dispose() {
    service.removeListener(onServiceUpdated);
    super.dispose();
  }
}
