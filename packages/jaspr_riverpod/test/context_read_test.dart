import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_test/jaspr_test.dart';

import 'utils.dart';

final counter = StateProvider((ref) => 0);

void main() {
  group('context.read', () {
    testComponents('returns provider state', (tester) async {
      tester.pumpComponent(
        providerApp((context) {
          return Component.text('${context.read(counter)}');
        }),
      );

      expect(find.text('0'), findsOneComponent);
      expect(find.text('1'), findsNothing);
    });

    testComponents('returns overridden provider state', (tester) async {
      tester.pumpComponent(
        providerApp((context) {
          return Component.fragment([
            Component.text('a ${context.read(counter)}'),
            ProviderScope(
              overrides: [counter.overrideWith((ref) => 1)],
              child: Builder(
                builder: (context) {
                  return Component.text('b ${context.read(counter)}');
                },
              ),
            ),
          ]);
        }),
      );

      expect(find.text('a 0'), findsOneComponent);
      expect(find.text('b 1'), findsOneComponent);
    });
  });
}
