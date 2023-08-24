import 'package:jaspr/components.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_test/jaspr_test.dart';

import 'utils.dart';

final counter = StateProvider((ref) => 0);
final counterB = StateProvider.autoDispose((ref) => 0);

void main() {
  group('context.listen', () {
    testComponents(
      'listens to provider state',
      (tester) async {
        int? wasCalledWith;

        await tester.pumpComponent(providerApp((context) sync* {
          context.listen<int>(counter, (prev, next) {
            wasCalledWith = next;
          });

          yield Button(
            label: 'tap',
            onPressed: () {
              context.read(counter.notifier).state++;
            },
          );
        }));

        expect(wasCalledWith, isNull);

        // increase counter
        await tester.click(find.tag('button'));

        expect(wasCalledWith, equals(1));
      },
    );

    testComponents(
      'context.listen re-listens on rebuild',
      (tester) async {
        List<int> wasCalledWith = [];

        await tester.pumpComponent(providerApp((context) sync* {
          context.listen<int>(counter, (prev, next) {
            wasCalledWith.add(next);
          }, fireImmediately: true);

          yield Button(
            label: '${context.watch(counter)}',
            onPressed: () {
              context.read(counter.notifier).state++;
            },
          );
        }));

        expect(wasCalledWith, equals([0]));

        // increase counter
        await tester.click(find.tag('button'));

        expect(wasCalledWith, equals([0, 1]));
      },
    );

    testComponents(
      'context.listen un-listens on dispose',
      (tester) async {
        List<int> wasCalledWith = [];

        await tester.pumpComponent(providerApp((context) sync* {
          if (context.watch(counter.select((cnt) => cnt < 2))) {
            yield Builder(
              builder: (context) sync* {
                context.listen<int>(counter, (prev, next) {
                  wasCalledWith.add(next);
                }, fireImmediately: true);

                yield Button(
                  label: 'a ${context.watch(counter)}',
                  onPressed: () {
                    context.read(counter.notifier).state++;
                  },
                );
              },
            );
          } else {
            yield Button(
              label: 'b ${context.watch(counter)}',
              onPressed: () {
                context.read(counter.notifier).state++;
              },
            );
          }
        }));

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
      },
    );

    testComponents(
      'omitting closes an active listener',
      (tester) async {
        List<int> wasCalledWith = [];

        late Element element;
        var shouldListen = true;

        await tester.pumpComponent(providerApp((context) sync* {
          if (shouldListen) {
            context.listen(counterB, (_, int value) {
              wasCalledWith.add(value);
            }, fireImmediately: true);
          }
          element = context as Element;
          yield const Text('test');
        }));

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
      },
    );
  });
}
