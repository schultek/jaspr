import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils/mock_render_object.dart';
import '../../utils/test_component.dart';
import 'utils.dart';

void main() {
  group('RenderObjectElement', () {
    testRenderObjectMock('should create and attach single html element', (binding) {
      final root = binding.root;
      binding.attachRootComponent(
        div(
          id: 'test',
          classes: 'test-class',
          styles: Styles(color: Colors.red),
          attributes: {'data-test': 'value'},
          events: {'click': (event) {}},
          [],
        ),
      );

      expect(root.children, hasLength(1));
      final child = root.children[0];

      verifyInOrder([
        () => root.createChildRenderElement('div'),
        () => child.parent,
        () => (child as RenderElement).update(
          'test',
          'test-class',
          {'color': 'red'},
          {'data-test': 'value'},
          any(that: hasLength(1)),
        ),
        () => root.attach(child, after: null),
        () => child.parent,
      ]);
    });

    testRenderObjectMock('should update element params', (binding) async {
      final root = binding.root;
      final component = FakeComponent(
        child: div(
          id: 'test',
          classes: 'test-class',
          styles: Styles(color: Colors.red),
          attributes: {'data-test': 'value'},
          events: {'click': (event) {}},
          [],
        ),
      );
      binding.attachRootComponent(component);

      expect(root.children, hasLength(1));
      final child = root.children[0];

      verifyInOrder([
        () => root.createChildRenderElement('div'),
        () => child.parent,
        () => (child as RenderElement).update(
          'test',
          'test-class',
          {'color': 'red'},
          {'data-test': 'value'},
          any(that: hasLength(1)),
        ),
        () => root.attach(child, after: null),
        () => child.parent,
      ]);

      verifyNoMoreRenderInteractions(root);

      component.updateChild(
        div(
          id: 'test2',
          classes: 'test-class2',
          styles: Styles(color: Colors.blue),
          attributes: {'data-test': 'value2'},
          events: {'click': (event) {}},
          [],
        ),
      );
      await pumpEventQueue();

      verifyInOrder([
        () => (child as RenderElement).update(
          'test2',
          'test-class2',
          {'color': 'blue'},
          {'data-test': 'value2'},
          any(that: hasLength(1)),
        ),
      ]);
    });

    testRenderObjectMock('should create and attach multiple html elements', (binding) {
      final root = binding.root;
      binding.attachRootComponent(div([h1([]), h2([])]));

      expect(root.children, hasLength(1));
      final rDiv = root.children[0];
      expect(rDiv.children, hasLength(2));
      final eH1 = rDiv.children[0];
      final rH2 = rDiv.children[1];

      verifyInOrder([
        () => root.createChildRenderElement('div'),
        () => rDiv.parent,
        () => (rDiv as RenderElement).update(null, null, null, null, null),
        () => rDiv.createChildRenderElement('h1'),
        () => eH1.parent,
        () => (eH1 as RenderElement).update(null, null, null, null, null),
        () => rDiv.attach(eH1, after: null),
        () => eH1.parent,
        () => rDiv.createChildRenderElement('h2'),
        () => rH2.parent,
        () => (rH2 as RenderElement).update(null, null, null, null, null),
        () => rDiv.attach(rH2, after: eH1),
        () => rH2.parent,
        () => root.attach(rDiv, after: null),
        () => rDiv.parent,
      ]);
    });

    testRenderObjectMock('should re-attach element after reordering', (binding) async {
      final root = binding.root;
      final component = FakeComponent(
        child: div([h1(key: ValueKey(1), []), h2(key: ValueKey(2), [])]),
      );
      binding.attachRootComponent(component);

      expect(root.children, hasLength(1));
      final rDiv = root.children[0];
      expect(rDiv.children, hasLength(2));
      final rH1 = rDiv.children[0];
      final rH2 = rDiv.children[1];

      verifyInOrder([
        () => root.createChildRenderElement('div'),
        () => rDiv.parent,
        () => (rDiv as RenderElement).update(null, null, null, null, null),
        () => rDiv.createChildRenderElement('h1'),
        () => rH1.parent,
        () => (rH1 as RenderElement).update(null, null, null, null, null),
        () => rDiv.attach(rH1, after: null),
        () => rH1.parent,
        () => rDiv.createChildRenderElement('h2'),
        () => rH2.parent,
        () => (rH2 as RenderElement).update(null, null, null, null, null),
        () => rDiv.attach(rH2, after: rH1),
        () => rH2.parent,
        () => root.attach(rDiv, after: null),
        () => rDiv.parent,
      ]);

      verifyNoMoreRenderInteractions(root);

      component.updateChild(div([h2(key: ValueKey(2), []), h1(key: ValueKey(1), [])]));
      await pumpEventQueue();

      verifyInOrder([
        () => rDiv.attach(rH2, after: null),
        () => rH2.parent,
        () => rDiv.attach(rH1, after: rH2),
        () => rH1.parent,
      ]);
    });

    testRenderObjectMock('should remove element after update', (binding) async {
      final root = binding.root;
      final component = FakeComponent(child: div([h1([]), h2([])]));
      binding.attachRootComponent(component);

      expect(root.children, hasLength(1));
      final rDiv = root.children[0];
      expect(rDiv.children, hasLength(2));
      final rH1 = rDiv.children[0];
      final rH2 = rDiv.children[1];

      verifyInOrder([
        () => root.createChildRenderElement('div'),
        () => rDiv.parent,
        () => (rDiv as RenderElement).update(null, null, null, null, null),
        () => rDiv.createChildRenderElement('h1'),
        () => rH1.parent,
        () => (rH1 as RenderElement).update(null, null, null, null, null),
        () => rDiv.attach(rH1, after: null),
        () => rH1.parent,
        () => rDiv.createChildRenderElement('h2'),
        () => rH2.parent,
        () => (rH2 as RenderElement).update(null, null, null, null, null),
        () => rDiv.attach(rH2, after: rH1),
        () => rH2.parent,
        () => root.attach(rDiv, after: null),
        () => rDiv.parent,
      ]);

      verifyNoMoreRenderInteractions(root);

      component.updateChild(div([h2([])]));
      await pumpEventQueue();

      verifyInOrder([() => rDiv.remove(rH1), () => rH1.parent, () => rDiv.attach(rH2, after: null), () => rH2.parent]);
    });

    testRenderObjectMock('should attach on keyed reparenting', (binding) async {
      final root = binding.root;
      final component = FakeComponent(
        child: div([
          h1(key: GlobalObjectKey(1), [Component.text('Hello World!')]),
        ]),
      );
      binding.attachRootComponent(component);

      expect(root.children, hasLength(1));
      final rDiv = root.children[0];
      expect(rDiv.children, hasLength(1));
      final rH1 = rDiv.children[0];
      expect(rH1.children, hasLength(1));
      final rText = rH1.children[0];

      verifyInOrder([
        () => root.createChildRenderElement('div'),
        () => rDiv.parent,
        () => (rDiv as RenderElement).update(null, null, null, null, null),
        () => rDiv.createChildRenderElement('h1'),
        () => rH1.parent,
        () => (rH1 as RenderElement).update(null, null, null, null, null),
        () => rH1.createChildRenderText('Hello World!'),
        () => rText.parent,
        () => rH1.attach(rText, after: null),
        () => rText.parent,
        () => rDiv.attach(rH1, after: null),
        () => rH1.parent,
        () => root.attach(rDiv, after: null),
        () => rDiv.parent,
      ]);

      verifyNoMoreRenderInteractions(root);

      component.updateChild(h1(key: GlobalObjectKey(1), [Component.text('Hello World!')]));
      await pumpEventQueue();

      verifyInOrder([
        () => root.remove(rDiv),
        () => rDiv.parent,
        () => root.attach(rH1, after: null),
        () => rH1.parent,
      ]);
    });
  });
}
