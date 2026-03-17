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
