@TestOn('browser')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/client_test.dart';

void main() {
  group('events', () {
    testClient('handle click events', (tester) async {
      int clicked = 0;

      tester.pumpComponent(
        button(
          onClick: () {
            clicked++;
          },
          [],
        ),
      );

      await tester.click(find.tag('button'));
      expect(clicked, equals(1));
    });

    testClient('handle input:checkbox events', (tester) async {
      bool checkedInput = false;
      bool checkedChange = false;

      tester.pumpComponent(
        input<bool>(
          type: InputType.checkbox,
          onInput: (value) => checkedInput = value,
          onChange: (value) => checkedChange = value,
        ),
      );

      await tester.input(find.tag('input'), checked: true);
      expect(checkedInput, isTrue);

      await tester.change(find.tag('input'), checked: true);
      expect(checkedChange, isTrue);
    });

    testClient('handle input:number events', (tester) async {
      double numberInput = 0;
      double numberChange = 0;

      tester.pumpComponent(
        input<double>(
          type: InputType.number,
          onInput: (value) => numberInput = value,
          onChange: (value) => numberChange = value,
        ),
      );

      await tester.input(find.tag('input'), valueAsNumber: 2.0);
      expect(numberInput, equals(2.0));

      await tester.change(find.tag('input'), valueAsNumber: 2.0);
      expect(numberChange, equals(2.0));
    });

    testClient('handle input text events', (tester) async {
      String textInput = '';
      String textChange = '';

      tester.pumpComponent(
        input<String>(
          type: InputType.text,
          onInput: (value) => textInput = value,
          onChange: (value) => textChange = value,
        ),
      );

      await tester.input(find.tag('input'), value: 'Hello');
      expect(textInput, equals('Hello'));

      await tester.change(find.tag('input'), value: 'World');
      expect(textChange, equals('World'));
    });

    testClient('handle textarea events', (tester) async {
      String textInput = '';
      String textChange = '';

      tester.pumpComponent(
        textarea(
          onInput: (value) => textInput = value,
          onChange: (value) => textChange = value,
          [],
        ),
      );

      await tester.input(find.tag('textarea'), value: 'Hello');
      expect(textInput, equals('Hello'));

      await tester.change(find.tag('textarea'), value: 'World');
      expect(textChange, equals('World'));
    });
  });
}
