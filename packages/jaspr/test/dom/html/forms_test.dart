@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('html components', () {
    testComponents('renders button', (tester) async {
      tester.pumpComponent(button(autofocus: false, disabled: false, type: ButtonType.button, onClick: () {}, []));

      expect(find.tag('button'), findsOneComponent);
    });

    testComponents('renders form', (tester) async {
      tester.pumpComponent(
        form(
          action: '',
          method: FormMethod.post,
          encType: FormEncType.text,
          name: '',
          noValidate: false,
          target: Target.self,
          [
            input(type: InputType.text, name: 'a', value: 'a', disabled: false, onInput: (_) {}, onChange: (_) {}),
            label(htmlFor: 'a', []),
            datalist([]),
            legend([]),
            meter(value: 100, min: 0, max: 100, low: 0, high: 100, optimum: 100, []),
            progress(value: 100, max: 100, []),
            select(
              name: 'a',
              multiple: false,
              required: false,
              disabled: false,
              autofocus: false,
              autocomplete: '',
              size: 100,
              onInput: (_) {},
              onChange: (_) {},
              [
                optgroup(label: 'a', disabled: false, [
                  option(label: 'a', value: 'a', selected: true, disabled: false, []),
                ]),
              ],
            ),
            fieldset(name: 'a', disabled: false, []),
            textarea(
              autoComplete: AutoComplete.on,
              autofocus: false,
              cols: 2,
              disabled: false,
              minLength: 10,
              name: 'a',
              placeholder: 'a',
              readonly: false,
              required: false,
              rows: 2,
              spellCheck: SpellCheck.isTrue,
              wrap: TextWrap.soft,
              onInput: (_) {},
              onChange: (_) {},
              [],
            ),
          ],
        ),
      );

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
