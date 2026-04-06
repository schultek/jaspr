@TestOn('vm')
library;

// ignore: implementation_imports
import 'package:jaspr/src/devtools/devtools_protocol.dart';
// ignore: implementation_imports
import 'package:jaspr/src/devtools/tree_snapshot.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('DevToolsMessage', () {
    test('encode/decode roundtrip preserves type and payload', () {
      final msg = DevToolsMessage(
        type: 'test_type',
        payload: {'key': 'value', 'num': 42},
      );

      final encoded = msg.encode();
      final decoded = DevToolsMessage.decode(encoded);

      expect(decoded.type, equals('test_type'));
      expect(decoded.payload['key'], equals('value'));
      expect(decoded.payload['num'], equals(42));
    });

    test('treeUpdate roundtrip', () {
      final tree = InspectorNode(
        id: 1,
        componentType: 'Root',
        displayLabel: 'Root',
        depth: 0,
        isStateful: false,
        domTag: null,
        textContent: null,
        hasRenderObject: false,
        children: [],
      );

      final msg = DevToolsMessage.treeUpdate(tree);
      final decoded = DevToolsMessage.decode(msg.encode());

      expect(decoded.type, equals('tree_update'));
      final treeJson = decoded.payload['tree'] as Map;
      expect(treeJson['componentType'], equals('Root'));
    });

    test('requestTree roundtrip', () {
      final msg = DevToolsMessage.requestTree();
      final decoded = DevToolsMessage.decode(msg.encode());
      expect(decoded.type, equals('request_tree'));
    });

    test('highlightElement roundtrip', () {
      final msg = DevToolsMessage.highlightElement(42);
      final decoded = DevToolsMessage.decode(msg.encode());
      expect(decoded.type, equals('highlight_element'));
      expect(decoded.payload['nodeId'], equals(42));
    });

    test('selectElement roundtrip', () {
      final msg = DevToolsMessage.selectElement(99);
      final decoded = DevToolsMessage.decode(msg.encode());
      expect(decoded.type, equals('select_element'));
      expect(decoded.payload['nodeId'], equals(99));
    });

    test('childrenResponse roundtrip', () {
      final children = [
        InspectorNode(
          id: 10,
          componentType: 'Child',
          displayLabel: 'Child',
          depth: 1,
          isStateful: false,
          domTag: null,
          textContent: null,
          hasRenderObject: false,
          children: [],
        ),
      ];

      final msg = DevToolsMessage.childrenResponse(nodeId: 1, children: children);
      final decoded = DevToolsMessage.decode(msg.encode());

      expect(decoded.type, equals('children_response'));
      expect(decoded.payload['nodeId'], equals(1));
      final childList = decoded.payload['children'] as List;
      expect(childList, hasLength(1));
    });
  });

  group('NodeChange', () {
    test('toJson/fromJson roundtrip for added', () {
      final node = InspectorNode(
        id: 5,
        componentType: 'New',
        displayLabel: 'New',
        depth: 2,
        isStateful: false,
        domTag: null,
        textContent: null,
        hasRenderObject: false,
        children: [],
      );

      final change = NodeChange(type: 'added', nodeId: 5, node: node, parentId: 1);
      final json = change.toJson();
      final restored = NodeChange.fromJson(json);

      expect(restored.type, equals('added'));
      expect(restored.nodeId, equals(5));
      expect(restored.parentId, equals(1));
      expect(restored.node, isNotNull);
      expect(restored.node!.componentType, equals('New'));
    });

    test('toJson/fromJson roundtrip for removed', () {
      final change = NodeChange(type: 'removed', nodeId: 7);
      final restored = NodeChange.fromJson(change.toJson());

      expect(restored.type, equals('removed'));
      expect(restored.nodeId, equals(7));
      expect(restored.node, isNull);
      expect(restored.parentId, isNull);
    });

    test('toJson/fromJson roundtrip for updated', () {
      final node = InspectorNode(
        id: 3,
        componentType: 'Updated',
        displayLabel: 'Updated [Stateful]',
        depth: 1,
        isStateful: true,
        domTag: null,
        textContent: null,
        hasRenderObject: false,
        children: [],
        stateFields: {'count': '10'},
      );

      final change = NodeChange(type: 'updated', nodeId: 3, node: node);
      final restored = NodeChange.fromJson(change.toJson());

      expect(restored.type, equals('updated'));
      expect(restored.nodeId, equals(3));
      expect(restored.node!.stateFields!['count'], equals('10'));
    });
  });
}
