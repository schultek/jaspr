@TestOn('browser')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/browser_test.dart';

void main() {
  group('events', () {
    testBrowser('handle click events', (tester) async {
      int clicked = 0;

      tester.pumpComponent(button(onClick: () {
        clicked++;
      }, []));

      await tester.click(find.tag('button'));
      expect(clicked, equals(1));
    });

    testBrowser('handle input:checkbox events', (tester) async {
      bool checkedInput = false;
      bool checkedChange = false;

      tester.pumpComponent(input(
        type: InputType.checkbox,
        onInput: (value) => checkedInput = value,
        onChange: (value) => checkedChange = value,
        [],
      ));

      await tester.input(find.tag('input'), checked: true);
      expect(checkedInput, isTrue);

      await tester.change(find.tag('input'), checked: true);
      expect(checkedChange, isTrue);
    });

    testBrowser('handle input:number events', (tester) async {
      double numberInput = 0;
      double numberChange = 0;

      tester.pumpComponent(input(
        type: InputType.number,
        onInput: (value) => numberInput = value,
        onChange: (value) => numberChange = value,
        [],
      ));

      await tester.input(find.tag('input'), valueAsNumber: 2.0);
      expect(numberInput, equals(2.0));

      await tester.change(find.tag('input'), valueAsNumber: 2.0);
      expect(numberChange, equals(2.0));
    });

    testBrowser('handle input text events', (tester) async {
      String textInput = "";
      String textChange = "";

      tester.pumpComponent(input(
        type: InputType.text,
        onInput: (value) => textInput = value,
        onChange: (value) => textChange = value,
        [],
      ));

      await tester.input(find.tag('input'), value: "Hello");
      expect(textInput, equals("Hello"));

      await tester.change(find.tag('input'), value: "World");
      expect(textChange, equals("World"));
    });

    testBrowser('handle textarea events', (tester) async {
      String textInput = "";
      String textChange = "";

      tester.pumpComponent(textarea(
        onInput: (value) => textInput = value,
        onChange: (value) => textChange = value,
        [],
      ));

      await tester.input(find.tag('textarea'), value: "Hello");
      expect(textInput, equals("Hello"));

      await tester.change(find.tag('textarea'), value: "World");
      expect(textChange, equals("World"));
    });
  });
}
