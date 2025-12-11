@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('html components', () {
    testComponents('renders svg', (tester) async {
      tester.pumpComponent(
        svg(viewBox: '0 0 100 100', width: 100.px, height: 100.px, [
          rect(
            x: '0',
            y: '0',
            width: '100',
            height: '100',
            fill: Colors.black,
            stroke: Colors.black,
            strokeWidth: '1',
            [],
          ),
          circle(cx: '0', cy: '0', r: '100', fill: Colors.black, stroke: Colors.black, strokeWidth: '1', []),
          ellipse(
            cx: '0',
            cy: '0',
            rx: '100',
            ry: '100',
            fill: Colors.black,
            stroke: Colors.black,
            strokeWidth: '1',
            [],
          ),
          line(x1: '0', y1: '0', x2: '100', y2: '100', fill: Colors.black, stroke: Colors.black, strokeWidth: '1', []),
          path(d: '', fill: Colors.black, stroke: Colors.black, strokeWidth: '1', []),
          polygon(points: '', fill: Colors.black, stroke: Colors.black, strokeWidth: '1', []),
          polyline(points: '', fill: Colors.black, stroke: Colors.black, strokeWidth: '1', []),
        ]),
      );

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
