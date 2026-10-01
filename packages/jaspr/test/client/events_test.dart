@TestOn('browser')
library;

import 'package:jaspr/client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart';

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

    testClient('removes listeners and inherited values from elements left in place', (tester) async {
      var ownEvents = 0;
      var appliedEvents = 0;

      tester.pumpComponent(
        .apply(
          classes: 'applied',
          events: {'applied': (_) => appliedEvents++},
          child: button(classes: 'own', events: {'own': (_) => ownEvents++}, []),
        ),
      );

      final btn = window.document.querySelector('button')!;
      void dispatchEvents() {
        btn.dispatchEvent(Event('own'));
        btn.dispatchEvent(Event('applied'));
      }

      expect(btn.className, 'own applied');
      dispatchEvents();
      expect(ownEvents, 1);
      expect(appliedEvents, 1);

      // Detaching the root component leaves its DOM in place,
      // but without the values and listeners that its components added.
      tester.binding.detachRootComponent();
      expect(btn.isConnected, isTrue);
      expect(btn.className, 'own');
      dispatchEvents();
      expect(ownEvents, 1);
      expect(appliedEvents, 1);
    });

    testClient('adds inherited values to an element moved into them with a global key', (tester) async {
      var moved = false;
      late void Function(void Function() cb) setState;
      final movable = button(key: GlobalKey(), classes: 'own', []);

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return Component.fragment([
              div(id: 'source', [if (!moved) movable]),
              .apply(
                target: const .descendantWith(tag: 'button'),
                classes: 'applied',
                child: div(id: 'destination', [if (moved) movable]),
              ),
            ]);
          },
        ),
      );

      final btn = window.document.querySelector('button')!;
      expect(btn.className, 'own');

      // The same component is moved, so only the new inherited params make it render again.
      setState(() => moved = true);
      await pumpEventQueue();
      expect(window.document.querySelector('#destination > button'), equals(btn));
      expect(btn.className, 'own applied');
    });
  });
}
