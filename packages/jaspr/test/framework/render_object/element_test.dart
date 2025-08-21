import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils/mock_render_object.dart';
import '../../utils/test_component.dart';

void main() {
  group('RenderObjectElement', () {
    test('should create and attach single html element', () {
      final binding = MockRenderObjectBinding('/', true);
      final root = binding.root;

      autoMockChildren(root);

      binding.attachRootComponent(div(
        id: 'test',
        classes: 'test-class',
        styles: Styles(color: Colors.red),
        attributes: {'data-test': 'value'},
        events: {'click': (event) {}},
        [],
      ));

      expect(root.children, hasLength(1));
      final child = root.children[0];

      verifyInOrder([
        () => root.createChildRenderElement('div'),
        () => child.parent,
        () => (child as RenderElement).update(
            'test', 'test-class', {'color': 'red'}, {'data-test': 'value'}, any(that: hasLength(1))),
        () => root.attach(child, after: null),
        () => child.parent,
      ]);

      verifyNoMoreRenderInteractions(root);
    });

    test('should create and attach multiple html elements', () {
      final binding = MockRenderObjectBinding('/', true);
      final root = binding.root;

      autoMockChildren(root);

      binding.attachRootComponent(div([h1([]), h2([])]));

      expect(root.children, hasLength(1));
      final base = root.children[0];
      expect(base.children, hasLength(2));
      final child1 = base.children[0];
      final child2 = base.children[1];

      verifyInOrder([
        () => root.createChildRenderElement('div'),
        () => base.parent,
        () => (base as RenderElement).update(null, null, null, null, null),
        () => base.createChildRenderElement('h1'),
        () => child1.parent,
        () => (child1 as RenderElement).update(null, null, null, null, null),
        () => base.attach(child1, after: null),
        () => child1.parent,
        () => base.createChildRenderElement('h2'),
        () => child2.parent,
        () => (child2 as RenderElement).update(null, null, null, null, null),
        () => base.attach(child2, after: child1),
        () => child2.parent,
        () => root.attach(base, after: null),
        () => base.parent,
      ]);

      verifyNoMoreRenderInteractions(root);
    });

    test('should re-attach element after reordering', () async {
      final binding = MockRenderObjectBinding('/', true);
      final root = binding.root;

      autoMockChildren(root);

      final component = FakeComponent(child: div([
        h1(key: ValueKey(1), []),
        h2(key: ValueKey(2), []),
      ]));

      binding.attachRootComponent(component);

      expect(root.children, hasLength(1));
      final base = root.children[0];
      expect(base.children, hasLength(2));
      final child1 = base.children[0];
      final child2 = base.children[1];

      verifyInOrder([
        () => root.createChildRenderElement('div'),
        () => base.parent,
        () => (base as RenderElement).update(null, null, null, null, null),
        () => base.createChildRenderElement('h1'),
        () => child1.parent,
        () => (child1 as RenderElement).update(null, null, null, null, null),
        () => base.attach(child1, after: null),
        () => child1.parent,
        () => base.createChildRenderElement('h2'),
        () => child2.parent,
        () => (child2 as RenderElement).update(null, null, null, null, null),
        () => base.attach(child2, after: child1),
        () => child2.parent,
        () => root.attach(base, after: null),
        () => base.parent,
      ]);

      verifyNoMoreRenderInteractions(root);

      component.updateChild(div([
        h2(key: ValueKey(2), []),
        h1(key: ValueKey(1), []),
      ]));
      await pumpEventQueue();

      verifyInOrder([
        () => base.attach(child2, after: null),
        () => child2.parent,
        () => base.attach(child1, after: child2),
        () => child1.parent,
      ]);

      verifyNoMoreRenderInteractions(root);
    });

    test('should remove element after update', () async {
      final binding = MockRenderObjectBinding('/', true);
      final root = binding.root;

      autoMockChildren(root);

      final component = FakeComponent(child: div([
        h1([]),
        h2([]),
      ]));

      binding.attachRootComponent(component);

      expect(root.children, hasLength(1));
      final base = root.children[0];
      expect(base.children, hasLength(2));
      final child1 = base.children[0];
      final child2 = base.children[1];

      verifyInOrder([
        () => root.createChildRenderElement('div'),
        () => base.parent,
        () => (base as RenderElement).update(null, null, null, null, null),
        () => base.createChildRenderElement('h1'),
        () => child1.parent,
        () => (child1 as RenderElement).update(null, null, null, null, null),
        () => base.attach(child1, after: null),
        () => child1.parent,
        () => base.createChildRenderElement('h2'),
        () => child2.parent,
        () => (child2 as RenderElement).update(null, null, null, null, null),
        () => base.attach(child2, after: child1),
        () => child2.parent,
        () => root.attach(base, after: null),
        () => base.parent,
      ]);

      verifyNoMoreRenderInteractions(root);

      component.updateChild(div([
        h2([]),
      ]));
      await pumpEventQueue();

      verifyInOrder([
        () => base.remove(child1),
        () => child1.parent,
        () => base.attach(child2, after: null),
        () => child2.parent,
      ]);

      verifyNoMoreRenderInteractions(root);
    });
  });
}
