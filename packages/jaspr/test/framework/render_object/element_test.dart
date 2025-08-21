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
        () => root.createChildRenderObject(),
        () => child.parent,
        () => child.updateElement(
            'div', 'test', 'test-class', {'color': 'red'}, {'data-test': 'value'}, any(that: hasLength(1))),
        () => root.attach(child, after: null),
        () => child.parent,
      ]);

      verifyNoMoreRenderInteractions(root);
    });

    test('should create and attach multiple html elements', () {
      final binding = MockRenderObjectBinding('/', true);
      final root = binding.root;

      autoMockChildren(root);

      binding.attachRootComponent(Fragment(children: [h1([]), h2([])]));

      expect(root.children, hasLength(2));
      final child1 = root.children[0];
      final child2 = root.children[1];

      verifyInOrder([
        () => root.createChildRenderObject(),
        () => child1.parent,
        () => child1.updateElement('h1', null, null, null, null, null),
        () => root.attach(child1, after: null),
        () => child1.parent,
        () => root.createChildRenderObject(),
        () => child2.parent,
        () => child2.updateElement('h2', null, null, null, null, null),
        () => root.attach(child2, after: child1),
        () => child2.parent,
      ]);

      verifyNoMoreRenderInteractions(root);
    });

    test('should re-attach element after reordering', () async {
      final binding = MockRenderObjectBinding('/', true);
      final root = binding.root;

      autoMockChildren(root);

      final component = FakeComponent(children: [
        h1(key: ValueKey(1), []),
        h2(key: ValueKey(2), []),
      ]);

      binding.attachRootComponent(component);

      expect(root.children, hasLength(2));
      final child1 = root.children[0];
      final child2 = root.children[1];

      verifyInOrder([
        () => root.createChildRenderObject(),
        () => child1.parent,
        () => child1.updateElement('h1', null, null, null, null, null),
        () => root.attach(child1, after: null),
        () => child1.parent,
        () => root.createChildRenderObject(),
        () => child2.parent,
        () => child2.updateElement('h2', null, null, null, null, null),
        () => root.attach(child2, after: child1),
        () => child2.parent,
      ]);

      verifyNoMoreRenderInteractions(root);

      component.updateChildren([
        h2(key: ValueKey(2), []),
        h1(key: ValueKey(1), []),
      ]);
      await pumpEventQueue();

      // TODO: Fix duplicate attach calls
      verifyInOrder([
        () => root.attach(child2, after: null),
        () => child2.parent,
        () => root.attach(child2, after: null),
        () => child2.parent,
        () => root.attach(child1, after: child2),
        () => child1.parent,
        () => root.attach(child1, after: child2),
        () => child1.parent,
      ]);

      verifyNoMoreRenderInteractions(root);
    });

    test('should remove element after update', () async {
      final binding = MockRenderObjectBinding('/', true);
      final root = binding.root;

      autoMockChildren(root);

      final component = FakeComponent(children: [
        h1([]),
        h2([]),
      ]);

      binding.attachRootComponent(component);

      expect(root.children, hasLength(2));
      final child1 = root.children[0];
      final child2 = root.children[1];

      verifyInOrder([
        () => root.createChildRenderObject(),
        () => child1.parent,
        () => child1.updateElement('h1', null, null, null, null, null),
        () => root.attach(child1, after: null),
        () => child1.parent,
        () => root.createChildRenderObject(),
        () => child2.parent,
        () => child2.updateElement('h2', null, null, null, null, null),
        () => root.attach(child2, after: child1),
        () => child2.parent,
      ]);

      verifyNoMoreRenderInteractions(root);

      component.updateChildren([
        h2([]),
      ]);
      await pumpEventQueue();

      verifyInOrder([
        // TODO: Fix to remove child1 instead and don't update the element.
        () => child1.updateElement('h2', null, null, null, null, null),
        () => root.attach(child1, after: null),
        () => child1.parent,
        () => root.remove(child2),
        () => child2.parent,
      ]);

      verifyNoMoreRenderInteractions(root);
    });
  });
}
