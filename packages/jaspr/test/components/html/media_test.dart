@TestOn('vm')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('html components', () {
    testComponents('renders media', (tester) async {
      await tester.pumpComponent(div([
        audio([]),
        img(src: "a.png"),
        video([]),
        embed(src: "a"),
        iframe(src: "a.html", []),
        object([]),
        source(),
      ]));

      expect(find.tag('audio'), findsOneComponent);
      expect(find.tag('img'), findsOneComponent);
      expect(find.tag('video'), findsOneComponent);
      expect(find.tag('embed'), findsOneComponent);
      expect(find.tag('iframe'), findsOneComponent);
      expect(find.tag('object'), findsOneComponent);
      expect(find.tag('source'), findsOneComponent);
    });
  });
}
