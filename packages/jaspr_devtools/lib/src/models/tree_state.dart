import 'package:jaspr/jaspr.dart';

import '../services/dev_tools_service.dart';
import '../services/tree_service.dart';

enum TreeMode {
  client,
  server,
  combined,
}

class TreeState {
  final String url;
  String id;
  int timestamp;
  ClientTree? clientTree;
  ServerTree? serverTree;

  final ValueNotifier<TreeMode> activeMode = ValueNotifier(TreeMode.client);
  final ValueNotifier<ActiveTreeItem?> activeRoot = ValueNotifier(null);

  TreeState({
    required this.url,
    required this.id,
    required this.timestamp,
    this.clientTree,
    this.serverTree,
  }) {
    activeMode.value = DevToolsService.instance.projectMode == ProjectMode.client ? TreeMode.client : TreeMode.combined;
    activeRoot.value = _createActiveTree();
  }

  void setMode(TreeMode mode) {
    if (activeMode.value == mode) return;
    activeMode.value = mode;
    activeRoot.value = _createActiveTree();
    if (TreeService.instance.selectedElementId.value case final id?) {
      final didFindElement = activeRoot.value?.expandToElement(id) ?? false;
      if (!didFindElement) {
        activeRoot.value?.expandToLimit(30);
      }
    }
  }

  ActiveTreeItem? _createActiveTree() {
    final root = switch (activeMode.value) {
      TreeMode.client => _getClientTree(),
      TreeMode.server => _getServerTree(),
      TreeMode.combined => _getCombinedTree(),
    };
    root?.expandToLimit(30);
    return root;
  }

  ActiveTreeItem? _getClientTree() {
    if (clientTree?.root case final root?) {
      return _buildTree(root, isClient: true);
    }
    return null;
  }

  ActiveTreeItem? _getServerTree() {
    if (serverTree?.root case final root?) {
      return _buildTree(root, isClient: false);
    }
    return null;
  }

  ActiveTreeItem? _getCombinedTree() {
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

    visitClientNode(clientTree?.root);

    if (clientAnchors.isEmpty) {
      return _getServerTree();
    }

    List<ActiveTreeItem> makeCombinedNode(DiagnosticsNode serverNode) {
      if (serverNode.properties?.get('kind')?.value == 'client-component') {
        final anchorName = serverNode.properties?.get('anchor-name')?.value.toString();
        if (clientAnchors[anchorName] case final clientNode?) {
          return clientNode.children?.map((node) => _buildTree(node, isClient: true)).toList() ?? [];
        }
      }
      if (serverNode.children case final children?) {
        return [
          ActiveTreeItem(
            node: serverNode,
            isClient: false,
            children: children.expand((child) => makeCombinedNode(child)).toList(),
            expanded: false,
          ),
        ];
      }
      return [_buildTree(serverNode, isClient: false)];
    }

    return makeCombinedNode(serverTree?.root ?? DiagnosticsNode(name: 'root')).first;
  }

  ActiveTreeItem _buildTree(DiagnosticsNode node, {required bool isClient}) {
    return ActiveTreeItem(
      node: node,
      isClient: isClient,
      children: node.children?.map((child) => _buildTree(child, isClient: isClient)).toList() ?? [],
      expanded: false,
    );
  }

  void updateTree() {
    activeRoot.value = _createActiveTree();
  }
}

class ServerTree {
  final DiagnosticsNode root;

  ServerTree({required this.root});
}

class ClientTree {
  final DiagnosticsNode root;
  final String attachTarget;
  final String? title;

  ClientTree({
    required this.root,
    required this.attachTarget,
    required this.title,
  });
}

extension PropMap on List<DiagnosticsProperty> {
  DiagnosticsProperty? get(String key) {
    return where((p) => p.name == key).firstOrNull;
  }
}

class ActiveTreeItem {
  ActiveTreeItem({required this.node, required this.isClient, required this.children, required bool expanded}) {
    this.expanded = ValueNotifier<bool>(expanded);
  }

  final DiagnosticsNode node;
  final bool isClient;
  final List<ActiveTreeItem> children;

  late final ValueNotifier<bool> expanded;

  String? get id => node.properties?.where((prop) => prop.name == 'id').firstOrNull?.value?.toString();

  bool expandToElement(String? id) {
    if (this.id == id) {
      expanded.value = true;
      return true;
    } else {
      for (final child in children) {
        if (child.expandToElement(id)) {
          expanded.value = true;
          return true;
        }
      }
      expanded.value = false;
      return false;
    }
  }

  void toggleExpanded() {
    if (expanded.value) {
      expanded.value = false;
    } else {
      expanded.value = true;
      expandToLimit(10);
    }
  }

  void expandToLimit(int limit) {
    int limitLeft = limit;
    List<ActiveTreeItem> childItems = [this];

    while (limitLeft > 0 && childItems.isNotEmpty) {
      final nextChildItems = <ActiveTreeItem>[];
      for (final item in childItems) {
        item.expanded.value = true;
        limitLeft -= item.children.length;
        nextChildItems.addAll(item.children);
      }
      childItems = nextChildItems;
    }

    for (final item in childItems) {
      item.expanded.value = false;
    }
  }

  DiagnosticsNode? findNodeById(String? id) {
    if (id == null) return null;
    if (node.properties?.any((prop) => prop.name == 'id' && prop.value?.toString() == id) ?? false) {
      return node;
    }
    for (final child in children) {
      final found = child.findNodeById(id);
      if (found != null) return found;
    }
    return null;
  }
}
