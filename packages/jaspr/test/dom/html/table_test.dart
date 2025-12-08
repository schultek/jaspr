@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('html components', () {
    testComponents('renders table', (tester) async {
      tester.pumpComponent(
        table([
          thead([
            tr([
              th([Component.text('Name')]),
              th([Component.text('Age')]),
            ]),
          ]),
          tbody([
            tr([
              td([Component.text('Alice')]),
              td([Component.text('20')]),
            ]),
            tr([
              td([Component.text('Bob')]),
              td([Component.text('30')]),
            ]),
            tr([col(span: 2), colgroup(span: 2, [])]),
          ]),
          tfoot([]),
        ]),
      );

      expect(find.tag('table'), findsOneComponent);
      expect(find.tag('thead'), findsOneComponent);
      expect(find.tag('tbody'), findsOneComponent);
      expect(find.tag('tfoot'), findsOneComponent);

      expect(find.tag('tr'), findsNComponents(4));
      expect(find.tag('th'), findsNComponents(2));
      expect(find.tag('td'), findsNComponents(4));
      expect(find.tag('col'), findsOneComponent);
      expect(find.tag('colgroup'), findsOneComponent);
    });
  });
}
