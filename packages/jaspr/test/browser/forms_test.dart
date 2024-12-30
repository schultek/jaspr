@TestOn('browser')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr/src/foundation/events/web.dart';
import 'package:jaspr_test/browser_test.dart';

void main() {
  group('forms', () {
    testBrowser('controlled input value', (tester) async {
      String text = "Hello";
      late void Function(void Function() cb) setState;

      tester.pumpComponent(StatefulBuilder(builder: (context, s) sync* {
        setState = s;
        yield input(value: text, []);
      }));

      final node = tester.findNode(find.tag('input')) as HTMLInputElement;

      expect(node.value, text);

      setState(() {
        text = "World";
      });

      await pumpEventQueue();

      expect(node.value, text);
    });

    testBrowser('controlled select option', (tester) async {
      String value = "a";
      late void Function(void Function() cb) setState;

      tester.pumpComponent(StatefulBuilder(builder: (context, s) sync* {
        setState = s;
        yield select(value: value, [
          option(value: "a", []),
          option(value: "b", []),
        ]);
      }));

      final node = tester.findNode(find.tag('select')) as HTMLSelectElement;

      expect(node.value, value);

      setState(() {
        value = "b";
      });

      await pumpEventQueue();

      expect(node.value, value);
    });
  });
}
