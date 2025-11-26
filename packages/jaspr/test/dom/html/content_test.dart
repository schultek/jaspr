@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('html components', () {
    testComponents('renders content', (tester) async {
      tester.pumpComponent(
        html([
          head([]),
          body([
            header([nav([])]),
            main_([
              article([h1([]), h2([]), h3([]), h4([]), h5([]), h6([]), p([])]),
              section([
                blockquote([]),
                div([]),
                ul([li([])]),
                ol([]),
                hr(),
                pre([]),
              ]),
            ]),
            aside([]),
            footer([]),
          ]),
        ]),
      );

      expect(find.tag('html'), findsOneComponent);
      expect(find.tag('head'), findsOneComponent);
      expect(find.tag('body'), findsOneComponent);
      expect(find.tag('header'), findsOneComponent);
      expect(find.tag('nav'), findsOneComponent);
      expect(find.tag('main'), findsOneComponent);
      expect(find.tag('article'), findsOneComponent);
      expect(find.tag('h1'), findsOneComponent);
      expect(find.tag('h2'), findsOneComponent);
      expect(find.tag('h3'), findsOneComponent);
      expect(find.tag('h4'), findsOneComponent);
      expect(find.tag('h5'), findsOneComponent);
      expect(find.tag('h6'), findsOneComponent);
      expect(find.tag('p'), findsOneComponent);
      expect(find.tag('section'), findsOneComponent);
      expect(find.tag('blockquote'), findsOneComponent);
      expect(find.tag('div'), findsOneComponent);
      expect(find.tag('ul'), findsOneComponent);
      expect(find.tag('li'), findsOneComponent);
      expect(find.tag('ol'), findsOneComponent);
      expect(find.tag('hr'), findsOneComponent);
      expect(find.tag('pre'), findsOneComponent);
      expect(find.tag('aside'), findsOneComponent);
      expect(find.tag('footer'), findsOneComponent);
    });
  });
}
