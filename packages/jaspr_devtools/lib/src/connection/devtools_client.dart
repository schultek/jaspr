import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:jaspr/devtools.dart';
import 'package:universal_web/web.dart' as web;

/// WebSocket client that connects to the DevTools relay on the proxy server.
///
/// Receives tree updates from the running app and sends commands back.
class DevToolsClient {
  final _treeController = StreamController<InspectorNode>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  web.WebSocket? _socket;
  bool _connected = false;

  /// Stream of tree snapshots received from the running app.
  Stream<InspectorNode> get treeUpdates => _treeController.stream;

  /// Stream of connection state changes.
  Stream<bool> get connectionState => _connectionController.stream;

  /// Whether the WebSocket is currently connected.
  bool get isConnected => _connected;

  /// Connects to the DevTools relay WebSocket.
  ///
  /// The URL is read from the current page's query parameters or defaults
  /// to the same host on the proxy port.
  void connect([String? url]) {
    final wsUrl = url ?? _inferWsUrl();
    if (wsUrl == null) return;

    try {
      _socket = web.WebSocket(wsUrl);
    } catch (_) {
      return;
    }

    _socket!.addEventListener(
      'open',
      ((web.Event _) {
        _connected = true;
        _connectionController.add(true);
        // Request initial tree on connect.
        requestTree();
      }).toJS,
    );

    _socket!.addEventListener(
      'message',
      ((web.MessageEvent e) {
        final data = (e.data as JSString?)?.toDart;
        if (data == null) return;
        _handleMessage(data);
      }).toJS,
    );

    _socket!.addEventListener(
      'close',
      ((web.Event _) {
        _connected = false;
        _connectionController.add(false);
        _socket = null;
        // Attempt reconnect.
        Future<void>.delayed(const Duration(seconds: 2), () => connect(url));
      }).toJS,
    );
  }

  /// Infers the WebSocket URL from the page's query string or origin.
  String? _inferWsUrl() {
    // Check query param: ?ws=ws://host:port/$jasprDevTools
    final params = Uri.parse(web.window.location.href).queryParameters;
    final wsParam = params['ws'];
    if (wsParam != null) return wsParam;

    // Check global var (injected by CLI into DevTools HTML)
    try {
      final value = globalContext.getProperty(r'$jasprDevToolsUrl'.toJS);
      if (value != null && value.isA<JSString>()) {
        return (value as JSString).toDart.replaceFirst('role=app', 'role=devtools');
      }
    } catch (_) {}

    // Fallback: same origin, default proxy port
    final origin = web.window.location.origin;
    final wsOrigin = origin.replaceFirst('http', 'ws');
    return '$wsOrigin/\$jasprDevTools?role=devtools';
  }

  void _handleMessage(String raw) {
    try {
      final msg = DevToolsMessage.decode(raw);
      switch (msg.type) {
        case 'tree_update':
          final treeJson = msg.payload['tree'] as Map<String, Object?>?;
          if (treeJson != null) {
            _treeController.add(InspectorNode.fromJson(treeJson));
          }
        case 'element_details':
          // TODO: Route to detail panel when needed.
          break;
        case 'app_info':
          // TODO: Display app metadata.
          break;
      }
    } catch (e) {
      // Malformed message — ignore.
      web.console.warn('DevTools: failed to parse message: $e'.toJS);
    }
  }

  void _send(DevToolsMessage msg) {
    if (_socket != null && _connected) {
      _socket!.send(msg.encode().toJS);
    }
  }

  /// Request a fresh tree snapshot from the running app.
  void requestTree() => _send(DevToolsMessage.requestTree());

  /// Ask the running app to highlight a specific element.
  void highlightElement(int nodeId) => _send(DevToolsMessage.highlightElement(nodeId));

  /// Ask the running app to select a specific element.
  void selectElement(int nodeId) => _send(DevToolsMessage.selectElement(nodeId));

  /// Request detailed info for a specific element.
  void getElementDetails(int nodeId) => _send(DevToolsMessage.getElementDetails(nodeId));

  /// Closes the connection.
  void dispose() {
    _socket?.close();
    _treeController.close();
    _connectionController.close();
  }
}
