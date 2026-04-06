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
  final Map<int, Element> registry = {};

  /// Maps DOM nodes to element node IDs, for pick-mode hit testing.
  Map<web.Node, int> domNodeMap = {};

  /// Cached class→source location map.
  Map<String, String>? _classLocationsCache;

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
    }
  }

  /// Takes a tree snapshot and sends it over WebSocket.
  void _sendTreeUpdate() {
    final root = _binding.rootElement;
    if (root == null) return;

    registry.clear();
    final tree = snapshotTree(root, registry, classLocations: _classLocations);
    _rebuildDomNodeMap();

    _send(DevToolsMessage.treeUpdate(tree));
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
