@TestOn('vm')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('html components', () {
    testComponents('renders other', (tester) async {
      tester.pumpComponent(div([
        details(open: false, []),
        dialog(open: false, []),
        summary([]),
        link(href: "a", rel: "", type: "", as: ""),
        script(async: false, defer: false, src: "a.js", []),
      ]));

      expect(find.tag('details'), findsOneComponent);
      expect(find.tag('dialog'), findsOneComponent);
      expect(find.tag('summary'), findsOneComponent);
      expect(find.tag('link'), findsOneComponent);
      expect(find.tag('script'), findsOneComponent);
    });
  });
}
