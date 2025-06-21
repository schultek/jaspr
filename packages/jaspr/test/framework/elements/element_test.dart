@TestOn('vm')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('elements', () {
    testComponents('correctly handles empty fragments', (tester) async {
      final component = div([
        text('A'),
        Fragment(children: [
          text('B'),
          Fragment(children: []), // empty fragment
        ]),
        text('C'),
      ]);
      tester.pumpComponent(component);

      final render =
          find.byComponent(component).evaluate().first.lastRenderObjectElement?.renderObject as TestRenderObject;
      expect(render.tag, equals('div'));
      expect(render.children.length, equals(3));
      expect(render.children[0].text, equals('A'));
      expect(render.children[1].text, equals('B'));
      expect(render.children[2].text, equals('C'));
    });
  });
}
