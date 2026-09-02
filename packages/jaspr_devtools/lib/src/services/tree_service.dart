import 'dart:async';

import 'package:jaspr/jaspr.dart';

import '../models/tree_state.dart';
import 'dev_tools_service.dart';

class TreeService with ChangeNotifier {
  static final TreeService instance = TreeService._();

  TreeService._() {
    DevToolsService.instance.addListener(onServiceUpdated);
  }

  StreamSubscription<Object?>? _clientTreeSub;

  final Map<String, TreeState> _trees = {};

  final ValueNotifier<String?> selectedElementId = ValueNotifier(null);

  List<String> get allUrls => _trees.keys.toList();

  void removeTree(String url) {
    _trees.remove(url);
    notifyListeners();
  }

  TreeState? getTree(String url) {
    return _trees[url];
  }

  void selectElement(String id) {
    if (selectedElementId.value == id) return;
    selectedElementId.value = id;
    DevToolsService.instance.setSelection(id);
  }

  void updateSelectedElement(String id, String url) {
    if (selectedElementId.value == id) return;
    selectedElementId.value = id;
    final tree = getTree(url);
    if (tree case final tree?) {
      if (id.startsWith(r'$c') && tree.activeMode.value == TreeMode.server) {
        tree.setMode(TreeMode.client);
      } else if (id.startsWith(r'$s') && tree.activeMode.value == TreeMode.client) {
        tree.setMode(TreeMode.server);
      } else {
        final didFindElement = tree.activeRoot.value?.expandToElement(id) ?? false;
        if (!didFindElement) {
          tree.activeRoot.value?.expandToLimit(30);
        }
      }
    }
  }

  void updateClientTree(
    String id,
    String url,
    Map<String, Object?> treeJson,
    String? attachTarget,
    String? title,
    int timestamp,
  ) {
    if (_trees[url] case final tree?) {
      if (tree.id != id) {
        if (tree.timestamp > timestamp) {
          return;
        }
        tree.id = id;
        tree.serverTree = null;
      }
      tree.clientTree = ClientTree(
        root: DiagnosticsNode.fromJsonMap(treeJson),
        attachTarget: attachTarget ?? '',
        title: title,
      );
      tree.timestamp = timestamp;
      tree.updateTree();
    } else {
      _trees[url] = TreeState(
        url: url,
        id: id,
        timestamp: timestamp,
        clientTree: ClientTree(
          root: DiagnosticsNode.fromJsonMap(treeJson),
          attachTarget: attachTarget ?? '',
          title: title,
        ),
      );
      notifyListeners();
    }
  }

  void updateServerTree(String id, String url, Map<String, Object?> treeJson, int timestamp) {
    if (_trees[url] case final tree?) {
      if (tree.id != id) {
        if (tree.timestamp > timestamp) {
          return;
        }
        tree.id = id;
        tree.clientTree = null;
      }
      tree.serverTree = ServerTree(root: DiagnosticsNode.fromJsonMap(treeJson));
      tree.timestamp = timestamp;
      tree.updateTree();
    } else {
      _trees[url] = TreeState(
        url: url,
        id: id,
        timestamp: timestamp,
        serverTree: ServerTree(root: DiagnosticsNode.fromJsonMap(treeJson)),
      );
      notifyListeners();
    }
  }

  Future<void> fetchTrees() async {
    final clientData = await DevToolsService.instance.getClientTree();
    String? renderId;
    String? pageUrl;

    if (clientData != null) {
      if (clientData case {
        'id': final String? id,
        'url': final String url,
        'tree': final Map<String, Object?> treeJson,
      }) {
        renderId = id;
        pageUrl = url;
        final info = clientData['info'] as Map<String, Object?>?;
        final attachTarget = info?['attachTarget'] as String?;
        final title = info?['title'] as String?;
        final timestamp = (clientData['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch;
        updateClientTree(id ?? '', url, treeJson, attachTarget, title, timestamp);
      }
    }

    if (renderId != null && renderId.isNotEmpty) {
      final serverData = await DevToolsService.instance.getServerTree(renderId);
      if (serverData != null) {
        if (serverData case {
          'id': final String id,
          'tree': final Map<String, Object?> treeJson,
        }) {
          final url = (serverData['url'] as String?) ?? pageUrl ?? '/';
          final timestamp = (serverData['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch;
          updateServerTree(id, url, treeJson, timestamp);
        }
      }
    }
  }

  void onServiceUpdated() {
    _clientTreeSub?.cancel();

    if (DevToolsService.instance.clientVmService case final clientVmService?) {
      _clientTreeSub = clientVmService.onExtensionEvent.listen((event) {
        if (event.extensionKind == 'ext.jaspr.inspector.selectionChanged') {
          if (event.extensionData?.data case {
            'id': final String id,
            'url': final String url,
          }) {
            updateSelectedElement(id, url);
          }
        }
      });
    }

    fetchTrees();
  }

  @override
  void dispose() {
    DevToolsService.instance.removeListener(onServiceUpdated);
    super.dispose();
  }
}
