import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_test/jaspr_test.dart';

import 'utils.dart';

final counter = StateProvider((ref) => 0);
final autoDisposeCounter = StateProvider.autoDispose((ref) => 0);

void main() {
  group('context.watch', () {
    testComponents('context.watch returns provider state and rebuilds on change', (tester) async {
      await tester.pumpComponent(providerApp((context) sync* {
        yield Button(
          label: '${context.watch(counter)}',
          onPressed: () {
            context.read(counter.notifier).state++;
          },
        );
      }));

      expect(find.text('0'), findsOneComponent);

      await tester.click(find.tag('button'));
      await tester.pump();

      expect(find.text('1'), findsOneComponent);
    });

    testComponents('context.watch returns overridden provider state', (tester) async {
      await tester.pumpComponent(providerApp((context) sync* {
        yield Builder(builder: (context) sync* {
          yield Button(
            key: const ValueKey('a'),
            label: 'a ${context.watch(counter)}',
            onPressed: () {
              context.read(counter.notifier).state++;
            },
          );
        });
        yield ProviderScope(
          overrides: [counter.overrideWith((ref) => 10)],
          child: Builder(builder: (context) sync* {
            yield Button(
              key: const ValueKey('b'),
              label: 'b ${context.watch(counter)}',
              onPressed: () {
                context.read(counter.notifier).state++;
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

    testComponents('provider is autodisposed when no longer watched', (tester) async {
      await tester.pumpComponent(providerApp((context) sync* {
        var showCounter = true;
        yield StatefulBuilder(
          builder: (context, setState) sync* {
            yield Button(
              label: showCounter ? '${context.watch(autoDisposeCounter)}' : 'hidden',
              onPressed: () {
                context.read(autoDisposeCounter.notifier).state++;
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
