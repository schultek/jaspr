import 'dart:convert';

import 'tree_snapshot.dart';

/// Represents a single change in a tree diff.
class NodeChange {
  NodeChange({required this.type, required this.nodeId, this.node, this.parentId});

  /// 'added', 'removed', or 'updated'.
  final String type;

  /// The ID of the changed node.
  final int nodeId;

  /// The new/updated node data (null for 'removed').
  final InspectorNode? node;

  /// Parent node ID (for 'added' to know where to insert).
  final int? parentId;

  Map<String, Object?> toJson() => {
        'type': type,
        'nodeId': nodeId,
        if (node != null) 'node': node!.toJson(),
        if (parentId != null) 'parentId': parentId,
      };

  factory NodeChange.fromJson(Map<String, Object?> json) => NodeChange(
        type: json['type'] as String,
        nodeId: json['nodeId'] as int,
        node: json['node'] != null ? InspectorNode.fromJson((json['node'] as Map).cast<String, Object?>()) : null,
        parentId: json['parentId'] as int?,
      );
}

/// Message types sent from the running app to the DevTools UI.
enum AppToDevToolsType {
  /// Full serialized component tree.
  treeUpdate,

  /// App metadata (name, mode, URL).
  appInfo,

  /// Detailed info about a specific element.
  elementDetails,
}

/// Message types sent from the DevTools UI to the running app.
enum DevToolsToAppType {
  /// Request a full tree snapshot.
  requestTree,

  /// Ask the embedded toolbar to highlight a specific node.
  highlightElement,

  /// Ask the embedded toolbar to select a specific node.
  selectElement,

  /// Request detailed info for a specific node ID.
  getElementDetails,
}

/// A message in the DevTools protocol, sent over WebSocket.
///
/// The [type] field identifies the kind of message. The [payload] carries the
/// message-specific data. Both directions (app↔devtools) use this same envelope.
class DevToolsMessage {
  DevToolsMessage({
    required this.type,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// The message type as a string (e.g. `'tree_update'`, `'request_tree'`).
  final String type;

  /// Message-specific data.
  final Map<String, Object?> payload;

  /// When the message was created.
  final DateTime timestamp;

  /// Serializes to a JSON string for WebSocket transport.
  String encode() => jsonEncode({
        'type': type,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'payload': payload,
      });

  /// Deserializes a [DevToolsMessage] from a JSON string.
  factory DevToolsMessage.decode(String raw) {
    final json = jsonDecode(raw) as Map<String, Object?>;
    return DevToolsMessage(
      type: json['type'] as String,
      payload: (json['payload'] as Map?)?.cast<String, Object?>() ?? {},
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int? ?? 0),
    );
  }

  // -- App → DevTools factory constructors --

  /// Creates a tree update message with the full serialized tree.
  factory DevToolsMessage.treeUpdate(InspectorNode tree) => DevToolsMessage(
        type: 'tree_update',
        payload: {'tree': tree.toJson()},
      );

  /// Creates an app info message with app metadata.
  factory DevToolsMessage.appInfo({
    required String appName,
    required String url,
    required bool isDebug,
  }) =>
      DevToolsMessage(
        type: 'app_info',
        payload: {
          'appName': appName,
          'url': url,
          'isDebug': isDebug,
        },
      );

  /// Creates an element details message for a specific node.
  factory DevToolsMessage.elementDetails({
    required int nodeId,
    required Map<String, Object?> details,
  }) =>
      DevToolsMessage(
        type: 'element_details',
        payload: {'nodeId': nodeId, 'details': details},
      );

  // -- DevTools → App factory constructors --

  /// Creates a request tree message.
  factory DevToolsMessage.requestTree() => DevToolsMessage(
        type: 'request_tree',
        payload: {},
      );

  /// Creates a highlight element message for the given node ID.
  factory DevToolsMessage.highlightElement(int nodeId) => DevToolsMessage(
        type: 'highlight_element',
        payload: {'nodeId': nodeId},
      );

  /// Creates a select element message for the given node ID.
  factory DevToolsMessage.selectElement(int nodeId) => DevToolsMessage(
        type: 'select_element',
        payload: {'nodeId': nodeId},
      );

  /// Creates a get element details request for the given node ID.
  factory DevToolsMessage.getElementDetails(int nodeId) => DevToolsMessage(
        type: 'get_element_details',
        payload: {'nodeId': nodeId},
      );

  /// Requests children of a specific node (for lazy tree loading).
  factory DevToolsMessage.requestChildren(int nodeId) => DevToolsMessage(
        type: 'request_children',
        payload: {'nodeId': nodeId},
      );

  /// Response with children of a node.
  factory DevToolsMessage.childrenResponse({
    required int nodeId,
    required List<InspectorNode> children,
  }) =>
      DevToolsMessage(
        type: 'children_response',
        payload: {
          'nodeId': nodeId,
          'children': children.map((c) => c.toJson()).toList(),
        },
      );
}
