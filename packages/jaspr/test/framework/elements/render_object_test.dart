@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('elements', () {
    testComponents('correctly handles empty fragments', (tester) async {
      final component = div([
        Component.text('A'),
        Component.fragment([
          Component.text('B'),
          Component.fragment([]), // empty fragment
        ]),
        Component.text('C'),
      ]);
      tester.pumpComponent(component);

      final render = find.byComponent(component).evaluate().first.slot.target?.renderObject as TestRenderElement;
      expect(render.tag, equals('div'));
      expect(render.children.length, equals(3));
      expect(render.children[0], isA<TestRenderText>().having((e) => e.text, 'text', equals('A')));
      expect(render.children[1], isA<TestRenderFragment>().having((e) => e.children, 'children', hasLength(2)));
      final subChildren = (render.children[1] as TestRenderFragment).children;
      expect(subChildren[0], isA<TestRenderText>().having((e) => e.text, 'text', equals('B')));
      expect(subChildren[1], isA<TestRenderFragment>().having((e) => e.children, 'children', isEmpty));
      expect(render.children[2], isA<TestRenderText>().having((e) => e.text, 'text', equals('C')));
    });
  });
}
