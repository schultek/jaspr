import 'package:jaspr/dom.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_riverpod/legacy.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../utils.dart';

final counter = StateProvider((ref) => 0);

void main() {
  group('context.invalidate', () {
    testComponents('invalidates provider state', (tester) async {
      tester.pumpComponent(
        providerApp((context) {
          return div([
            Button(
              label: '${context.watch(counter)}',
              onPressed: () {
                context.read(counter.notifier).state++;
              },
            ),
            Button(
              label: 'invalidate',
              onPressed: () {
                context.invalidate(counter);
              },
            ),
          ]);
        }),
      );

      expect(find.text('0'), findsOneComponent);

      // increase counter
      await tester.click(find.componentWithText(Button, '0'));
      await tester.pump();

      expect(find.text('1'), findsOneComponent);

      // invalidate counter
      await tester.click(find.componentWithText(Button, 'invalidate'));
      await tester.pump();

      expect(find.text('0'), findsOneComponent);
    });

    testComponents('invalidates overridden provider state', (tester) async {
      tester.pumpComponent(
        providerApp((context) {
          return div([
            Builder(
              builder: (context) {
                return div([
                  Button(
                    key: const ValueKey('a'),
                    label: 'a ${context.watch(counter)}',
                    onPressed: () {
                      context.read(counter.notifier).state++;
                    },
                  ),
                  Button(
                    label: 'invalidate_a',
                    onPressed: () {
                      context.invalidate(counter);
                    },
                  ),
                ]);
              },
            ),
            ProviderScope(
              overrides: [counter.overrideWith((ref) => 10)],
              child: Builder(
                builder: (context) {
                  return div([
                    Button(
                      key: const ValueKey('b'),
                      label: 'b ${context.watch(counter)}',
                      onPressed: () {
                        context.read(counter.notifier).state++;
                      },
                    ),
                    Button(
                      label: 'invalidate_b',
                      onPressed: () {
                        context.invalidate(counter);
                      },
                    ),
                  ]);
                },
              ),
            ),
          ]);
        }),
      );

      expect(find.text('a 0'), findsOneComponent);
      expect(find.text('b 10'), findsOneComponent);

      // increase counters
      await tester.click(find.byKey(const ValueKey('a')));
      await tester.pump();
      await tester.click(find.byKey(const ValueKey('b')));
      await tester.pump();

      expect(find.text('a 1'), findsOneComponent);
      expect(find.text('b 11'), findsOneComponent);

      // invalidate counter a
      await tester.click(find.componentWithText(Button, 'invalidate_a'));
      await tester.pump();

      expect(find.text('a 0'), findsOneComponent);
      expect(find.text('b 11'), findsOneComponent);

      // increase counter a, invalidate counter b
      await tester.click(find.byKey(const ValueKey('a')));
      await tester.pump();
      await tester.click(find.componentWithText(Button, 'invalidate_b'));
      await tester.pump();

      expect(find.text('a 1'), findsOneComponent);
      expect(find.text('b 10'), findsOneComponent);
    });
  });
}
