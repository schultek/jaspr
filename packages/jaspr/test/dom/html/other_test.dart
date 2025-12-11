@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('html components', () {
    testComponents('renders other', (tester) async {
      tester.pumpComponent(
        div([
          details(open: false, []),
          dialog(open: false, []),
          summary([]),
          meta(httpEquiv: 'x-ua-compatible', content: 'ie=edge'),
          meta(name: 'description', content: 'Hello world'),
          link(href: 'a', rel: '', type: '', as: ''),
          script(async: false, defer: false, src: 'a.js'),
        ]),
      );

      expect(find.tag('details'), findsOneComponent);
      expect(find.tag('dialog'), findsOneComponent);
      expect(find.tag('summary'), findsOneComponent);
      expect(find.tag('meta'), findsNComponents(2));
      expect(find.tag('link'), findsOneComponent);
      expect(find.tag('script'), findsOneComponent);
    });
  });
}
