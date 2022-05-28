import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_test/jaspr_test.dart';

import 'utils.dart';

final counter = StateProvider((ref) => 0);
final counterB = StateProvider((ref) => 10);

void main() {
  group('context.refresh', () {
    late ComponentTester tester;

    setUp(() {
      tester = ComponentTester.setUp();
    });

    test(
      'refreshes provider state',
      () async {
        await tester.pumpComponent(providerApp((context) sync* {
          yield Button(
            label: '${context.watch(counter)}',
            onPressed: () {
              context.read(counter.state).state++;
            },
          );

          yield Button(
            label: 'refresh',
            onPressed: () {
              context.refresh(counter);
            },
          );
        }));

        expect(find.text('0'), findsOneComponent);

        // increase counter
        await tester.click(find.componentWithText(Button, '0'));
        await tester.pump();

        expect(find.text('1'), findsOneComponent);

        // refresh counter
        await tester.click(find.componentWithText(Button, 'refresh'));
        await tester.pump();

        expect(find.text('0'), findsOneComponent);
      },
    );

    test(
      'refreshes overridden provider state',
      () async {
        await tester.pumpComponent(providerApp((context) sync* {
          yield Builder(builder: (context) sync* {
            yield Button(
              key: const ValueKey('a'),
              label: 'a ${context.watch(counter)}',
              onPressed: () {
                context.read(counter.state).state++;
              },
            );
            yield Button(
              label: 'refresh_a',
              onPressed: () {
                context.refresh(counter);
              },
            );
          });
          yield ProviderScope(
            overrides: [counter.overrideWithProvider(counterB)],
            child: Builder(builder: (context) sync* {
              yield Button(
                key: const ValueKey('b'),
                label: 'b ${context.watch(counter)}',
                onPressed: () {
                  context.read(counter.state).state++;
                },
              );
              yield Button(
                label: 'refresh_b',
                onPressed: () {
                  context.refresh(counter);
                },
              );
            }),
          );
        }));

        expect(find.text('a 0'), findsOneComponent);
        expect(find.text('b 10'), findsOneComponent);

        // increase counters
        await tester.click(find.byKey(const ValueKey('a')));
        await tester.pump();
        await tester.click(find.byKey(const ValueKey('b')));
        await tester.pump();

        expect(find.text('a 1'), findsOneComponent);
        expect(find.text('b 11'), findsOneComponent);

        // refresh counter a
        await tester.click(find.componentWithText(Button, 'refresh_a'));
        await tester.pump();

        expect(find.text('a 0'), findsOneComponent);
        expect(find.text('b 11'), findsOneComponent);

        // increase counter a, refresh counter b
        await tester.click(find.byKey(const ValueKey('a')));
        await tester.pump();
        await tester.click(find.componentWithText(Button, 'refresh_b'));
        await tester.pump();

        expect(find.text('a 1'), findsOneComponent);
        expect(find.text('b 10'), findsOneComponent);
      },
    );
  });
}
