@TestOn('vm')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('html components', () {
    testComponents('renders button', (tester) async {
      await tester.pumpComponent(button([]));

      expect(find.tag('button'), findsOneComponent);
    });

    testComponents('renders form', (tester) async {
      await tester.pumpComponent(form(method: FormMethod.post, [
        input(type: InputType.text, name: "a", []),
        label(htmlFor: 'a', []),
        datalist([]),
        legend([]),
        meter([]),
        progress(value: 100, []),
        select([
          optgroup(label: 'a', [option([])])
        ]),
        fieldset([]),
        textarea([]),
      ]));

      expect(find.tag('form'), findsOneComponent);
      expect(find.tag('input'), findsOneComponent);
      expect(find.tag('label'), findsOneComponent);
      expect(find.tag('datalist'), findsOneComponent);
      expect(find.tag('legend'), findsOneComponent);
      expect(find.tag('meter'), findsOneComponent);
      expect(find.tag('progress'), findsOneComponent);
      expect(find.tag('select'), findsOneComponent);
      expect(find.tag('optgroup'), findsOneComponent);
      expect(find.tag('option'), findsOneComponent);
      expect(find.tag('fieldset'), findsOneComponent);
      expect(find.tag('textarea'), findsOneComponent);
    });
  });
}
