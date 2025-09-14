import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_test/jaspr_test.dart';

import 'utils.dart';

final counter = StateProvider((ref) => 0);
final counterB = StateProvider.autoDispose((ref) => 0);

void main() {
  group('context.listen', () {
    testComponents('listens to provider state', (tester) async {
      int? wasCalledWith;

      tester.pumpComponent(
        providerApp((context) {
          context.listen<int>(counter, (prev, next) {
            wasCalledWith = next;
          });

          return Button(
            label: 'tap',
            onPressed: () {
              context.read(counter.notifier).state++;
            },
          );
        }),
      );

      expect(wasCalledWith, isNull);

      // increase counter
      await tester.click(find.tag('button'));

      expect(wasCalledWith, equals(1));
    });

    testComponents('re-listens on rebuild', (tester) async {
      List<int> wasCalledWith = [];

      tester.pumpComponent(
        providerApp((context) {
          context.listen<int>(counter, (prev, next) {
            wasCalledWith.add(next);
          }, fireImmediately: true);

          return Button(
            label: '${context.watch(counter)}',
            onPressed: () {
              context.read(counter.notifier).state++;
            },
          );
        }),
      );

      expect(wasCalledWith, equals([0]));

      // increase counter
      await tester.click(find.tag('button'));

      expect(wasCalledWith, equals([0, 1]));
    });

    testComponents('un-listens on dispose', (tester) async {
      List<int> wasCalledWith = [];

      tester.pumpComponent(
        providerApp((context) {
          if (context.watch(counter.select((cnt) => cnt < 2))) {
            return Builder(
              builder: (context) {
                context.listen<int>(counter, (prev, next) {
                  wasCalledWith.add(next);
                }, fireImmediately: true);

                return button(
                  onClick: () {
                    context.read(counter.notifier).state++;
                  },
                  [text('a ${context.watch(counter)}')],
                );
              },
            );
          } else {
            return Button(
              label: 'b ${context.watch(counter)}',
              onPressed: () {
                context.read(counter.notifier).state++;
              },
            );
          }
        }),
      );

      expect(wasCalledWith, equals([0]));
      expect(find.text('a 0'), findsOneComponent);

      // increase counter
      await tester.click(find.tag('button'));

      expect(wasCalledWith, equals([0, 1]));
      expect(find.text('a 1'), findsOneComponent);

      // increase counter
      await tester.click(find.tag('button'));

      expect(wasCalledWith, equals([0, 1, 2]));
      expect(find.text('b 2'), findsOneComponent);

      // increase counter
      await tester.click(find.tag('button'));

      expect(wasCalledWith, equals([0, 1, 2]));
      expect(find.text('b 3'), findsOneComponent);
    });

    testComponents('omitting closes an active listener', (tester) async {
      List<int> wasCalledWith = [];

      late Element element;
      var shouldListen = true;

      tester.pumpComponent(
        providerApp((context) {
          if (shouldListen) {
            context.listen(counterB, (_, int value) {
              wasCalledWith.add(value);
            }, fireImmediately: true);
          }
          element = context as Element;
          return const Component.text('test');
        }),
      );

      expect(wasCalledWith, equals([0]));
      expect(element.read(counterB), equals(0));

      // increase counter
      element.read(counterB.notifier).state = 1;

      expect(wasCalledWith, equals([0, 1]));

      // remove listener
      shouldListen = false;
      element.markNeedsBuild();
      await tester.pump();

      expect(wasCalledWith, equals([0, 1]));

      // was disposed
      await tester.pump();
      expect(element.read(counterB), equals(0));
    });
  });
}
