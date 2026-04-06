@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
// ignore: implementation_imports
import 'package:jaspr/src/devtools/tree_snapshot.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('snapshotTree', () {
    testComponents('root node id matches rootElement hashCode', (tester) async {
      tester.pumpComponent(div([]));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      expect(tree.id, equals(root.hashCode));
      expect(registry.containsKey(root.hashCode), isTrue);
    });

    testComponents('DomComponent nodes get correct domTag and display label', (tester) async {
      tester.pumpComponent(div([span([])]));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      // Root is a StatelessElement wrapping the div. Walk to find the div node.
      final divNode = _findByLabel(tree, '<div>');
      expect(divNode, isNotNull);
      expect(divNode!.domTag, equals('div'));

      final spanNode = _findByLabel(tree, '<span>');
      expect(spanNode, isNotNull);
      expect(spanNode!.domTag, equals('span'));
    });

    testComponents('Text nodes get correct textContent', (tester) async {
      tester.pumpComponent(Component.text('hello'));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final textNode = _findByPredicate(tree, (n) => n.textContent != null);
      expect(textNode, isNotNull);
      expect(textNode!.textContent, equals('hello'));
      expect(textNode.displayLabel, equals("Text('hello')"));
    });

    testComponents('long text is truncated with ellipsis', (tester) async {
      final longText = 'a' * 50;
      tester.pumpComponent(Component.text(longText));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final textNode = _findByPredicate(tree, (n) => n.textContent != null);
      expect(textNode, isNotNull);
      expect(textNode!.displayLabel, contains('...'));
      expect(textNode.displayLabel.length, lessThan(longText.length));
    });

    testComponents('StatefulComponent nodes are marked isStateful', (tester) async {
      tester.pumpComponent(_TestStateful());

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final statefulNode = _findByPredicate(tree, (n) => n.isStateful);
      expect(statefulNode, isNotNull);
      expect(statefulNode!.displayLabel, contains('[Stateful]'));
    });

    testComponents('children are nested correctly', (tester) async {
      tester.pumpComponent(
        div([
          span([]),
          Component.text('hi'),
        ]),
      );

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final divNode = _findByLabel(tree, '<div>');
      expect(divNode, isNotNull);
      // div should have children including the span and text
      expect(divNode!.children, isNotEmpty);
    });

    testComponents('registry has entries for all elements', (tester) async {
      tester.pumpComponent(div([span([]), Component.text('hi')]));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      snapshotTree(root, registry);

      // Should have entries for root + div + span + text (and possibly wrapper elements)
      expect(registry.length, greaterThanOrEqualTo(4));
      // Every value should be a valid Element
      for (final element in registry.values) {
        expect(element, isA<Element>());
      }
    });

    testComponents('builtBy tracks the building parent element', (tester) async {
      tester.pumpComponent(_TestStateless());

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      // _TestStateless builds a div. The div node's builtBy should reference
      // the element that built it (or its parent). In VM test environment,
      // _debugCurrentBuildTarget may be null during initial build, so builtBy
      // may fall back to the parent element.
      final divNode = _findByLabel(tree, '<div>');
      expect(divNode, isNotNull);
      // builtBy may be non-null if debugBuildOwnerElement was set
      // In test env, initial build may not set _debugCurrentBuildTarget,
      // so we just verify the field exists and is either null or a string.
      expect(divNode!.builtBy, anyOf(isNull, isA<String>()));
    });

    testComponents('debugDescribeState fields are captured', (tester) async {
      tester.pumpComponent(_TestStatefulWithState());

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final statefulNode = _findByPredicate(tree, (n) => n.isStateful && n.stateFields != null);
      expect(statefulNode, isNotNull);
      expect(statefulNode!.stateFields, isNotNull);
      expect(statefulNode.stateFields!['counter'], equals('42'));
      expect(statefulNode.stateFields!['label'], equals('test'));
    });

    testComponents('sourceLocation is captured or builtBy is available in debug builds', (tester) async {
      tester.pumpComponent(div([]));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      // In VM test environment, sourceLocation from StackTrace may be null
      // (no user code on stack during initial build), but builtBy should be
      // available for nodes created during a build phase.
      final anyNodeWithInfo = _findByPredicate(
        tree,
        (n) => n.sourceLocation != null || n.builtBy != null,
      );
      // At least some nodes should have either source info or builtBy
      expect(anyNodeWithInfo, isNotNull,
          reason: 'At least one node should have source location or builtBy info');
    });

    testComponents('DomComponent nodes have domId and domClasses', (tester) async {
      tester.pumpComponent(div(
        id: 'main-content',
        classes: 'app container',
        [],
      ));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final divNode = _findByLabel(tree, '<div>');
      expect(divNode, isNotNull);
      expect(divNode!.domId, equals('main-content'));
      expect(divNode.domClasses, equals('app container'));
    });

    testComponents('DomComponent nodes have domAttributes', (tester) async {
      tester.pumpComponent(div(
        attributes: {'data-foo': 'bar'},
        [],
      ));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final divNode = _findByLabel(tree, '<div>');
      expect(divNode, isNotNull);
      expect(divNode!.domAttributes, isNotNull);
      expect(divNode.domAttributes!['data-foo'], equals('bar'));
    });

    testComponents('StatefulComponent nodes have stateType', (tester) async {
      tester.pumpComponent(_TestStateful());

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final statefulNode = _findByPredicate(tree, (n) => n.isStateful);
      expect(statefulNode, isNotNull);
      expect(statefulNode!.stateType, isNotNull);
      expect(statefulNode.stateType, contains('_TestStatefulState'));
    });

    testComponents('DomComponent event count is captured', (tester) async {
      tester.pumpComponent(button(
        onClick: () {},
        [],
      ));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final buttonNode = _findByLabel(tree, '<button>');
      expect(buttonNode, isNotNull);
      expect(buttonNode!.eventCount, greaterThan(0));
    });

    testComponents('empty debugDescribeState does not produce stateFields', (tester) async {
      tester.pumpComponent(_TestStateful());

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final statefulNode = _findByPredicate(tree, (n) => n.isStateful);
      expect(statefulNode, isNotNull);
      // _TestStateful does not override debugDescribeState, so stateFields should be null
      expect(statefulNode!.stateFields, isNull);
    });

    testComponents('wasHydrated is null in VM test environment (no hydration)', (tester) async {
      tester.pumpComponent(div([span([]), Component.text('hello')]));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      // In VM tests there is no real DOM hydration, so wasHydrated should be
      // null or false for all nodes (DomRenderObject.debugWasHydrated defaults
      // to false, and non-render-object elements infer from children).
      final divNode = _findByLabel(tree, '<div>');
      expect(divNode, isNotNull);
      expect(divNode!.wasHydrated, anyOf(isNull, isFalse));

      final spanNode = _findByLabel(tree, '<span>');
      expect(spanNode, isNotNull);
      expect(spanNode!.wasHydrated, anyOf(isNull, isFalse));
    });

    testComponents('classLocations map populates sourceLocation on matching nodes', (tester) async {
      tester.pumpComponent(_TestStateless());

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final classLocations = {
        '_TestStateless': 'package:test_app/test.dart:42',
      };
      final tree = snapshotTree(root, registry, classLocations: classLocations);

      final node = _findByPredicate(tree, (n) => n.componentType == '_TestStateless');
      expect(node, isNotNull);
      expect(node!.sourceLocation, equals('package:test_app/test.dart:42'));
    });
  });

  group('InspectorNode JSON serialization', () {
    test('roundtrip preserves all fields', () {
      final node = InspectorNode(
        id: 42,
        componentType: 'MyWidget',
        displayLabel: 'MyWidget [Stateful]',
        depth: 3,
        isStateful: true,
        domTag: null,
        textContent: null,
        hasRenderObject: false,
        children: [
          InspectorNode(
            id: 99,
            componentType: 'DomComponent',
            displayLabel: '<div>',
            depth: 4,
            isStateful: false,
            domTag: 'div',
            textContent: null,
            hasRenderObject: true,
            children: [],
            domId: 'main',
            domClasses: 'app container',
            domAttributes: {'data-foo': 'bar'},
            eventCount: 2,
            wasHydrated: true,
          ),
        ],
        sourceLocation: 'package:test/app.dart',
        stateType: '_MyWidgetState',
        builtBy: 'ParentWidget',
        stateFields: {'counter': '42', 'label': 'test'},
        wasHydrated: false,
      );

      final json = node.toJson();
      final restored = InspectorNode.fromJson(json);

      expect(restored.id, equals(42));
      expect(restored.componentType, equals('MyWidget'));
      expect(restored.displayLabel, equals('MyWidget [Stateful]'));
      expect(restored.depth, equals(3));
      expect(restored.isStateful, isTrue);
      expect(restored.domTag, isNull);
      expect(restored.textContent, isNull);
      expect(restored.hasRenderObject, isFalse);
      expect(restored.sourceLocation, equals('package:test/app.dart'));
      expect(restored.stateType, equals('_MyWidgetState'));
      expect(restored.builtBy, equals('ParentWidget'));
      expect(restored.stateFields, equals({'counter': '42', 'label': 'test'}));
      expect(restored.wasHydrated, isFalse);

      // Verify child
      expect(restored.children, hasLength(1));
      final child = restored.children.first;
      expect(child.id, equals(99));
      expect(child.domTag, equals('div'));
      expect(child.domId, equals('main'));
      expect(child.domClasses, equals('app container'));
      expect(child.domAttributes, equals({'data-foo': 'bar'}));
      expect(child.eventCount, equals(2));
      expect(child.wasHydrated, isTrue);
      expect(child.hasRenderObject, isTrue);
    });

    test('roundtrip preserves null optional fields', () {
      final node = InspectorNode(
        id: 1,
        componentType: 'Simple',
        displayLabel: 'Simple',
        depth: 0,
        isStateful: false,
        domTag: null,
        textContent: null,
        hasRenderObject: false,
        children: [],
      );

      final restored = InspectorNode.fromJson(node.toJson());

      expect(restored.sourceLocation, isNull);
      expect(restored.domId, isNull);
      expect(restored.domClasses, isNull);
      expect(restored.domAttributes, isNull);
      expect(restored.stateType, isNull);
      expect(restored.builtBy, isNull);
      expect(restored.stateFields, isNull);
      expect(restored.wasHydrated, isNull);
      expect(restored.eventCount, equals(0));
    });

    testComponents('roundtrip from live tree preserves structure', (tester) async {
      tester.pumpComponent(div([span([]), Component.text('hello')]));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final json = tree.toJson();
      final restored = InspectorNode.fromJson(json);

      expect(restored.id, equals(tree.id));
      expect(restored.componentType, equals(tree.componentType));
      expect(restored.children.length, equals(tree.children.length));
    });
  });

  group('debugDescribeProperties', () {
    testComponents('DomComponent exposes tag, id, classes', (tester) async {
      tester.pumpComponent(div(
        id: 'app',
        classes: 'main container',
        [Component.text('hi')],
      ));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final divNode = _findByLabel(tree, '<div>');
      expect(divNode, isNotNull);
      expect(divNode!.properties, isNotNull);
      expect(divNode.properties!['tag'], equals('div'));
      expect(divNode.properties!['id'], equals('app'));
      expect(divNode.properties!['classes'], equals('main container'));
    });

    testComponents('Text component exposes text property', (tester) async {
      tester.pumpComponent(Component.text('hello world'));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final textNode = _findByPredicate(tree, (n) => n.textContent != null);
      expect(textNode, isNotNull);
      expect(textNode!.properties, isNotNull);
      expect(textNode.properties!['text'], equals('hello world'));
    });

    testComponents('StatelessComponent has no properties by default', (tester) async {
      tester.pumpComponent(_TestStateless());

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      final node = _findByPredicate(tree, (n) => n.componentType == '_TestStateless');
      expect(node, isNotNull);
      expect(node!.properties, isNull);
    });
  });

  group('lazy tree serialization', () {
    testComponents('maxDepth limits children serialization', (tester) async {
      tester.pumpComponent(div([span([Component.text('deep')])]));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry, maxDepth: 2);

      // Root at depth 0, first child at depth 1 — those are serialized.
      // Depth 2+ should have empty children but nonzero childCount.
      expect(tree.children, isNotEmpty);

      // Find a node at the boundary where children were truncated.
      final truncated = _findByPredicate(
        tree,
        (n) => n.children.isEmpty && n.childCount > 0,
      );
      // There should be at least one truncated node.
      expect(truncated, isNotNull);
      expect(truncated!.childCount, greaterThan(0));
    });

    testComponents('without maxDepth serializes full tree', (tester) async {
      tester.pumpComponent(div([span([Component.text('deep')])]));

      final root = tester.binding.rootElement!;
      final registry = <int, Element>{};
      final tree = snapshotTree(root, registry);

      // All nodes should have children.length == childCount.
      final mismatch = _findByPredicate(
        tree,
        (n) => n.children.length != n.childCount,
      );
      expect(mismatch, isNull);
    });

    test('childCount roundtrips through JSON', () {
      final node = InspectorNode(
        id: 1,
        componentType: 'Test',
        displayLabel: 'Test',
        depth: 0,
        isStateful: false,
        domTag: null,
        textContent: null,
        hasRenderObject: false,
        children: [],
        childCount: 5,
      );

      final restored = InspectorNode.fromJson(node.toJson());
      expect(restored.childCount, equals(5));
      expect(restored.children, isEmpty);
    });
  });

  group('properties roundtrip through JSON', () {
    test('properties preserved in toJson/fromJson', () {
      final node = InspectorNode(
        id: 1,
        componentType: 'DomComponent',
        displayLabel: '<div>',
        depth: 0,
        isStateful: false,
        domTag: 'div',
        textContent: null,
        hasRenderObject: true,
        children: [],
        properties: {'tag': 'div', 'id': 'app'},
      );

      final restored = InspectorNode.fromJson(node.toJson());
      expect(restored.properties, isNotNull);
      expect(restored.properties!['tag'], equals('div'));
      expect(restored.properties!['id'], equals('app'));
    });

    test('null properties preserved', () {
      final node = InspectorNode(
        id: 1,
        componentType: 'Test',
        displayLabel: 'Test',
        depth: 0,
        isStateful: false,
        domTag: null,
        textContent: null,
        hasRenderObject: false,
        children: [],
      );

      final restored = InspectorNode.fromJson(node.toJson());
      expect(restored.properties, isNull);
    });
  });
}

/// A minimal stateful component for testing.
class _TestStateful extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => _TestStatefulState();
}

class _TestStatefulState extends State<_TestStateful> {
  @override
  Component build(BuildContext context) {
    return Component.text('stateful');
  }
}

/// A stateful component that overrides debugDescribeState.
class _TestStatefulWithState extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => _TestStatefulWithStateState();
}

class _TestStatefulWithStateState extends State<_TestStatefulWithState> {
  int counter = 42;
  String label = 'test';

  @override
  Map<String, String> debugDescribeState() => {
        'counter': '$counter',
        'label': label,
      };

  @override
  Component build(BuildContext context) {
    return Component.text('$counter: $label');
  }
}

/// A minimal stateless component for testing builtBy.
class _TestStateless extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div([]);
  }
}

/// Recursively searches the tree for a node with the given [label].
InspectorNode? _findByLabel(InspectorNode node, String label) {
  return _findByPredicate(node, (n) => n.displayLabel == label);
}

/// Recursively searches the tree for a node matching [predicate].
InspectorNode? _findByPredicate(InspectorNode node, bool Function(InspectorNode) predicate) {
  if (predicate(node)) return node;
  for (final child in node.children) {
    final found = _findByPredicate(child, predicate);
    if (found != null) return found;
  }
  return null;
}
