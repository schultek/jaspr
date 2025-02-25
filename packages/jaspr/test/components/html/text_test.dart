@TestOn('vm')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('html components', () {
    testComponents('renders text', (tester) async {
      tester.pumpComponent(div([
        a(
          download: "",
          href: "a",
          target: Target.blank,
          type: "",
          referrerPolicy: ReferrerPolicy.noReferrer,
          [],
        ),
        b([]),
        br(),
        code([]),
        em([]),
        i([]),
        s([]),
        small([]),
        span([]),
        strong([]),
        u([]),
      ]));

      expect(find.tag('a'), findsOneComponent);
      expect(find.tag('b'), findsOneComponent);
      expect(find.tag('br'), findsOneComponent);
      expect(find.tag('code'), findsOneComponent);
      expect(find.tag('em'), findsOneComponent);
      expect(find.tag('i'), findsOneComponent);
      expect(find.tag('s'), findsOneComponent);
      expect(find.tag('small'), findsOneComponent);
      expect(find.tag('span'), findsOneComponent);
      expect(find.tag('strong'), findsOneComponent);
      expect(find.tag('u'), findsOneComponent);
    });
  });
}
