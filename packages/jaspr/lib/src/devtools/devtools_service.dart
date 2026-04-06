import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:universal_web/web.dart' as web;

import '../foundation/binding.dart';
import '../framework/framework.dart';
import 'devtools_protocol.dart';
import 'inspector_highlight.dart';
import 'source_resolver.dart';
import 'tree_snapshot.dart';

/// Core data service for the Jaspr DevTools.
///
/// Manages the element registry, takes tree snapshots after each build cycle,
/// and communicates with the standalone DevTools app over a WebSocket relay
/// provided by the CLI proxy.
class DevToolsService {
  DevToolsService(this._binding) {
    _sourceResolver = SourceResolver();
    _classLocationsCache = _sourceResolver.buildClassLocations();
  }

  final AppBinding _binding;
  late final SourceResolver _sourceResolver;

  /// Maps element hashCode → live [Element] for lookup/highlighting.
  ///
  /// Managed via reference counting: each snapshot increments the generation
  /// counter. Entries not seen in the latest snapshot are eligible for removal.
  final Map<int, Element> registry = {};

  /// Tracks which node IDs were seen in the latest snapshot generation.
  Set<int> _currentGeneration = {};

  /// Node IDs from the previous snapshot generation.
  Set<int> _previousGeneration = {};

  /// Maps DOM nodes to element node IDs, for pick-mode hit testing.
  Map<web.Node, int> domNodeMap = {};

  /// Cached class→source location map.
  Map<String, String>? _classLocationsCache;

  /// Previous tree snapshot for diffing.
  InspectorNode? _previousTree;

  web.WebSocket? _socket;
  bool _connected = false;
  bool _postFrameScheduled = false;

  /// Callback invoked when a `highlight_element` message is received.
  void Function(int nodeId)? onHighlightRequested;

  /// Callback invoked when a `select_element` message is received.
  void Function(int nodeId)? onSelectRequested;

  /// Returns the latest class→source location map.
  Map<String, String>? get classLocations => _classLocationsCache;

  /// Whether the WebSocket is currently connected.
  bool get isConnected => _connected;

  /// Connects to the DevTools WebSocket relay.
  ///
  /// The WebSocket URL is typically injected by the CLI proxy into the page's
  /// bootstrap script as `window.$jasprDevToolsUrl`.
  void connect() {
    final url = _readWsUrl();
    if (url == null) return;

    try {
      _socket = web.WebSocket(url);
    } catch (_) {
      return;
    }

    _socket!.addEventListener(
      'open',
      ((web.Event _) {
        _connected = true;
        _sendTreeUpdate();
      }).toJS,
    );

    _socket!.addEventListener(
      'message',
      ((web.MessageEvent e) {
        final data = (e.data as JSString?)?.toDart;
        if (data == null) return;
        _handleMessage(DevToolsMessage.decode(data));
      }).toJS,
    );

    _socket!.addEventListener(
      'close',
      ((web.Event _) {
        _connected = false;
        _socket = null;
        // Attempt to reconnect after a delay.
        Future<void>.delayed(const Duration(seconds: 2), connect);
      }).toJS,
    );
  }

  /// Reads the WebSocket URL from the global `$jasprDevToolsUrl` variable
  /// injected by the CLI proxy.
  String? _readWsUrl() {
    try {
      final value = globalContext.getProperty(r'$jasprDevToolsUrl'.toJS);
      if (value != null && value.isA<JSString>()) {
        return (value as JSString).toDart;
      }
    } catch (_) {}
    return null;
  }

  void _handleMessage(DevToolsMessage msg) {
    switch (msg.type) {
      case 'request_tree':
        _sendTreeUpdate();
      case 'highlight_element':
        final nodeId = msg.payload['nodeId'] as int?;
        if (nodeId != null) onHighlightRequested?.call(nodeId);
      case 'select_element':
        final nodeId = msg.payload['nodeId'] as int?;
        if (nodeId != null) onSelectRequested?.call(nodeId);
      case 'get_element_details':
        final nodeId = msg.payload['nodeId'] as int?;
        if (nodeId != null) _sendElementDetails(nodeId);
      case 'request_children':
        final nodeId = msg.payload['nodeId'] as int?;
        if (nodeId != null) _sendChildren(nodeId);
    }
  }

  /// Takes a tree snapshot and sends it over WebSocket.
  ///
  /// If a previous snapshot exists, computes a diff and sends only the changes.
  /// Falls back to a full tree update on the first snapshot or when the tree
  /// structure has changed significantly.
  void _sendTreeUpdate() {
    final root = _binding.rootElement;
    if (root == null) return;

    _previousGeneration = _currentGeneration;
    _currentGeneration = {};
    registry.clear();
    final tree = snapshotTree(root, registry, classLocations: _classLocations);
    _currentGeneration = registry.keys.toSet();
    // Remove entries that were in the previous generation but not the current one.
    final staleIds = _previousGeneration.difference(_currentGeneration);
    for (final id in staleIds) {
      registry.remove(id);
    }
    _rebuildDomNodeMap();

    if (_previousTree != null) {
      final diff = _computeDiff(_previousTree!, tree);
      if (diff.isNotEmpty && diff.length < _countNodes(tree)) {
        // Diff is smaller than full tree — send incremental update.
        _send(DevToolsMessage(type: 'tree_diff', payload: {
          'changes': diff.map((c) => c.toJson()).toList(),
        }));
        _previousTree = tree;
        return;
      }
    }

    // Full tree update (first time or structural change).
    _send(DevToolsMessage.treeUpdate(tree));
    _previousTree = tree;
  }

  int _countNodes(InspectorNode node) {
    var count = 1;
    for (final child in node.children) {
      count += _countNodes(child);
    }
    return count;
  }

  /// Sends detailed element info for a specific node.
  void _sendElementDetails(int nodeId) {
    final element = registry[nodeId];
    if (element == null) return;

    final component = element.component;
    final details = <String, Object?>{
      'componentType': component.runtimeType.toString(),
      'depth': element.depth,
    };

    if (component is DomComponent) {
      details['domTag'] = component.tag;
      details['domId'] = component.id;
      details['domClasses'] = component.classes;
      details['domAttributes'] = component.attributes;
      details['eventCount'] = component.events?.length ?? 0;
    }

    if (element is StatefulElement) {
      details['stateType'] = element.state.runtimeType.toString();
      details['stateFields'] = element.state.debugDescribeState();
    }

    _send(DevToolsMessage.elementDetails(nodeId: nodeId, details: details));
  }

  /// Computes a list of changes between [oldTree] and [newTree].
  List<NodeChange> _computeDiff(InspectorNode oldTree, InspectorNode newTree) {
    final changes = <NodeChange>[];
    final oldIndex = <int, InspectorNode>{};
    _indexTree(oldTree, oldIndex);
    _diffNode(oldTree, newTree, null, oldIndex, changes);
    return changes;
  }

  void _indexTree(InspectorNode node, Map<int, InspectorNode> index) {
    index[node.id] = node;
    for (final child in node.children) {
      _indexTree(child, index);
    }
  }

  void _diffNode(
    InspectorNode? oldNode,
    InspectorNode newNode,
    int? parentId,
    Map<int, InspectorNode> oldIndex,
    List<NodeChange> changes,
  ) {
    if (oldNode == null) {
      // New node added.
      changes.add(NodeChange(type: 'added', nodeId: newNode.id, node: newNode, parentId: parentId));
      return;
    }

    // Check if properties changed.
    if (oldNode.displayLabel != newNode.displayLabel ||
        oldNode.stateFields?.toString() != newNode.stateFields?.toString() ||
        oldNode.properties?.toString() != newNode.properties?.toString() ||
        oldNode.childCount != newNode.childCount) {
      changes.add(NodeChange(type: 'updated', nodeId: newNode.id, node: newNode));
    }

    // Diff children.
    final oldChildren = {for (final c in oldNode.children) c.id: c};
    for (final newChild in newNode.children) {
      _diffNode(oldChildren.remove(newChild.id), newChild, newNode.id, oldIndex, changes);
    }
    // Remaining old children were removed.
    for (final removed in oldChildren.values) {
      changes.add(NodeChange(type: 'removed', nodeId: removed.id));
    }
  }

  /// Sends the direct children of a specific node (for lazy tree expansion).
  void _sendChildren(int nodeId) {
    final element = registry[nodeId];
    if (element == null) return;

    final children = <InspectorNode>[];
    element.visitChildren((child) {
      children.add(
        _snapshotSingleElement(child),
      );
    });

    _send(DevToolsMessage.childrenResponse(nodeId: nodeId, children: children));
  }

  /// Snapshots a single element with its immediate metadata but without
  /// recursing into children (they get `childCount` only).
  InspectorNode _snapshotSingleElement(Element element) {
    final childRegistry = <int, Element>{};
    return snapshotTree(element, childRegistry, classLocations: _classLocations, maxDepth: 1);
  }

  Map<String, String>? get _classLocations {
    _classLocationsCache ??= _sourceResolver.buildClassLocations();
    return _classLocationsCache;
  }

  void _rebuildDomNodeMap() {
    final map = <web.Node, int>{};
    for (final entry in registry.entries) {
      final domNode = findDomNodeForElement(entry.value);
      if (domNode != null) map[domNode] = entry.key;
    }
    domNodeMap = map;
  }

  void _send(DevToolsMessage msg) {
    if (_socket != null && _connected) {
      _socket!.send(msg.encode().toJS);
    }
  }

  /// Sends a `select_element` message to the DevTools app (from pick mode).
  void notifyElementPicked(int nodeId) {
    _send(DevToolsMessage.selectElement(nodeId));
  }

  /// Schedules a post-frame callback to refresh the tree when connected.
  void schedulePostFrameRefresh() {
    if (_postFrameScheduled) return;
    _postFrameScheduled = true;
    _binding.addPostFrameCallback(() {
      _postFrameScheduled = false;
      if (_connected) {
        _sendTreeUpdate();
      }
      // Always re-schedule so we catch the next build cycle.
      schedulePostFrameRefresh();
    });
  }
}
