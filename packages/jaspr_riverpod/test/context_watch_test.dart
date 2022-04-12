import 'package:jaspr/components.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_test/jaspr_test.dart';

import 'utils.dart';

final counter = StateProvider((ref) => 0);
final autoDisposeCounter = StateProvider.autoDispose((ref) => 0);

void main() {
  group('context.watch', () {
    late ComponentTester tester;

    setUp(() {
      tester = ComponentTester.setUp();
    });

    test('context.watch returns provider state and rebuilds on change', () async {
      await tester.pumpComponent(providerApp((context) sync* {
        yield Button(
          label: '${context.watch(counter)}',
          onPressed: () {
            context.read(counter.state).state++;
          },
        );
      }));

      expect(find.text('0'), findsOneComponent);

      await tester.click(find.tag('button'));
      await tester.pump();

      expect(find.text('1'), findsOneComponent);
    });

    test('context.watch returns overridden provider state', () async {
      await tester.pumpComponent(providerApp((context) sync* {
        yield Builder(builder: (context) sync* {
          yield Button(
            key: const ValueKey('a'),
            label: 'a ${context.watch(counter)}',
            onPressed: () {
              context.read(counter.state).state++;
            },
          );
        });
        yield ProviderScope(
          overrides: [counter.overrideWithValue(StateController(10))],
          child: Builder(builder: (context) sync* {
            yield Button(
              key: const ValueKey('b'),
              label: 'b ${context.watch(counter)}',
              onPressed: () {
                context.read(counter.state).state++;
              },
            );
          }),
        );
      }));

      expect(find.text('a 0'), findsOneComponent);
      expect(find.text('b 10'), findsOneComponent);

      await tester.click(find.byKey(const ValueKey('a')));
      await tester.pump();

      expect(find.text('a 1'), findsOneComponent);
      expect(find.text('b 10'), findsOneComponent);

      await tester.click(find.byKey(const ValueKey('b')));
      await tester.pump();

      expect(find.text('a 1'), findsOneComponent);
      expect(find.text('b 11'), findsOneComponent);
    });

    test('provider is autodisposed when no longer watched', () async {
      await tester.pumpComponent(providerApp((context) sync* {
        var showCounter = true;
        yield StatefulBuilder(
          builder: (context, setState) sync* {
            yield Button(
              label: showCounter ? '${context.watch(autoDisposeCounter)}' : 'hidden',
              onPressed: () {
                context.read(autoDisposeCounter.state).state++;
              },
            );
            yield Button(
              label: 'toggle',
              onPressed: () {
                setState(() {
                  showCounter = !showCounter;
                });
              },
            );
          },
        );
      }));

      expect(find.text('0'), findsOneComponent);
      expect(find.text('hidden'), findsNothing);

      // increase counter
      await tester.click(find.tag('button').first);
      await tester.pump();

      expect(find.text('1'), findsOneComponent);
      expect(find.text('hidden'), findsNothing);

      // hide counter
      await tester.click(find.componentWithText(Button, 'toggle'));
      await tester.pump();

      expect(find.text('1'), findsNothing);
      expect(find.text('hidden'), findsOneComponent);

      // show counter
      await tester.click(find.componentWithText(Button, 'toggle'));
      await tester.pump();

      expect(find.text('0'), findsOneComponent);
      expect(find.text('hidden'), findsNothing);
    });
  });
}
