@TestOn('browser')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart';

void main() {
  group('forms', () {
    testClient('controlled input value', (tester) async {
      String text = 'Hello';
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return input(value: text);
          },
        ),
      );

      final node = tester.findNode(find.tag('input')) as HTMLInputElement;

      expect(node.value, text);

      setState(() {
        text = 'World';
      });

      await pumpEventQueue();

      expect(node.value, text);
    });

    testClient('controls checked value', (tester) async {
      bool checked = false;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return input(type: InputType.checkbox, checked: checked);
          },
        ),
      );

      final node = tester.findNode(find.tag('input')) as HTMLInputElement;

      expect(node.checked, checked);

      setState(() {
        checked = true;
      });

      await pumpEventQueue();

      expect(node.checked, checked);
    });

    testClient('controls indeterminate value', (tester) async {
      bool indeterminate = false;
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return input(type: InputType.checkbox, indeterminate: indeterminate);
          },
        ),
      );

      final node = tester.findNode(find.tag('input')) as HTMLInputElement;

      expect(node.indeterminate, indeterminate);

      setState(() {
        indeterminate = true;
      });

      await pumpEventQueue();

      expect(node.indeterminate, indeterminate);
    });

    testClient('controlled select option', (tester) async {
      String value = 'a';
      late void Function(void Function() cb) setState;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return select(value: value, [option(value: 'a', []), option(value: 'b', [])]);
          },
        ),
      );

      final node = tester.findNode(find.tag('select')) as HTMLSelectElement;

      expect(node.value, value);

      setState(() {
        value = 'b';
      });

      await pumpEventQueue();

      expect(node.value, value);
    });
  });
}
