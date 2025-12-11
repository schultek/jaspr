@TestOn('vm')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../../utils/test_component.dart';
import 'inherited_model_app.dart';

void testAgainstDto(MyDto src, {required Set<Key> expectedRebuilds}) {
  expect(find.text('A: ${src.a}'), findsOneComponent);
  expect(find.text('B: ${src.b}'), findsOneComponent);

  // build should be called initially.
  expect(buildCalledFor, equals(expectedRebuilds));

  // reset tracking of build
  buildCalledFor.clear();
}

void main() {
  group('inherited model test', () {
    testComponents('should update dependencies only', (tester) async {
      final controller = tester.pumpTestComponent(App());
      Future<void> rebuildThenTestAgainstDto(MyDto src, {required Set<Key> expectedRebuilds}) async {
        await controller.rebuildWith(src);
        testAgainstDto(src, expectedRebuilds: expectedRebuilds);
      }

      // phase 1: inherited component should be mounted
      testAgainstDto(
        MyDto(a: 0, b: 0),
        expectedRebuilds: {
          App.componentKey,
          ExampleComponent.componentKey,
          AComponent.componentKey,
          BComponent.componentKey,
        },
      );

      // phase 2: component should be update when inherited value changes
      await rebuildThenTestAgainstDto(
        MyDto(a: 1, b: 2.5),
        expectedRebuilds: {
          App.componentKey,
          // ExampleComponent should NOT be rebuilt
          AComponent.componentKey,
          BComponent.componentKey,
        },
      );

      // phase 3: only b has changed, a should not rebuild
      await rebuildThenTestAgainstDto(
        MyDto(a: 1, b: 3.5),
        expectedRebuilds: {
          App.componentKey,
          // ExampleComponent should NOT be rebuilt
          // AComponent should NOT be rebuilt
          BComponent.componentKey,
        },
      );

      // phase 4: only a has changed, b should not rebuild
      await rebuildThenTestAgainstDto(
        MyDto(a: 2, b: 3.5),
        expectedRebuilds: {
          App.componentKey,
          // ExampleComponent should NOT be rebuilt
          AComponent.componentKey,
          // BComponent should NOT be rebuilt
        },
      );

      // phase 5: nothing changed, nothing should be rebuilt.
      await rebuildThenTestAgainstDto(
        MyDto(a: 2, b: 3.5),
        expectedRebuilds: {
          App.componentKey,
          // ExampleComponent should NOT be rebuilt
          // BComponent should NOT be rebuilt
          // AComponent should NOT be rebuilt
        },
      );
    });
  });
}
