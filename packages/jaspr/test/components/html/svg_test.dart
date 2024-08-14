@TestOn('vm')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('html components', () {
    testComponents('renders svg', (tester) async {
      await tester.pumpComponent(svg([
        rect([]),
        circle([]),
        ellipse([]),
        line([]),
        path([]),
        polygon([]),
        polyline([]),
      ]));

      expect(find.tag('svg'), findsOneComponent);
      expect(find.tag('rect'), findsOneComponent);
      expect(find.tag('circle'), findsOneComponent);
      expect(find.tag('ellipse'), findsOneComponent);
      expect(find.tag('line'), findsOneComponent);
      expect(find.tag('path'), findsOneComponent);
      expect(find.tag('polygon'), findsOneComponent);
      expect(find.tag('polyline'), findsOneComponent);
    });
  });
}
