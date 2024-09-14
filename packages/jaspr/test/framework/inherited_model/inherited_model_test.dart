@TestOn('vm')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../../utils/test_component.dart';
import 'inherited_model_app.dart';

void main() {
  group('inherited model test', () {
    testComponents('should inherit model', (tester) async {
      var controller = await tester.pumpTestComponent(App());

      // phase 1: inherited component should be mounted
      expect(find.text('A: 0'), findsOneComponent);
      expect(find.text('B: 0.0'), findsOneComponent);

      // build should be called initially.
      expect(buildCalledFor, <Key>{
        App.componentKey,
        ExampleComponent.componentKey,
        AComponent.componentKey,
        BComponent.componentKey,
      });

      // reset tracking of build
      buildCalledFor.clear();

      // phase 2: component should be update when inherited value changes
      await controller.rebuildWith(MyDto(a: 1, b: 2.5));
      expect(find.text('A: 1'), findsOneComponent);
      expect(find.text('B: 2.5'), findsOneComponent);

      // since both A and B have changed, both components should be rebuilt.
      expect(buildCalledFor, <Key>{
        App.componentKey,
        // ExampleComponent should NOT be rebuilt
        AComponent.componentKey,
        BComponent.componentKey,
      });

      // reset tracking of build
      buildCalledFor.clear();

      // phase 3: only b has changed, a should not rebuild
      await controller.rebuildWith(MyDto(a: 1, b: 3.5));
      expect(find.text('A: 1'), findsOneComponent);
      expect(find.text('B: 3.5'), findsOneComponent);

      // since only B has changed, only BComponent should be rebuilt.
      expect(buildCalledFor, <Key>{
        App.componentKey,
        // ExampleComponent should NOT be rebuilt
        // AComponent should NOT be rebuilt
        BComponent.componentKey,
      });

      // reset tracking of build
      buildCalledFor.clear();

      // phase 4: only a has changed, b should not rebuild
      await controller.rebuildWith(MyDto(a: 2, b: 3.5));
      expect(find.text('A: 2'), findsOneComponent);
      expect(find.text('B: 3.5'), findsOneComponent);

      // since only A has changed, only AComponent should be rebuilt.
      expect(buildCalledFor, <Key>{
        App.componentKey,
        // ExampleComponent should NOT be rebuilt
        // BComponent should NOT be rebuilt
        AComponent.componentKey,
      });

      // reset tracking of build
      buildCalledFor.clear();

      // phase 5: nothing changed, nothing should be rebuilt.
      await controller.rebuildWith(MyDto(a: 2, b: 3.5));
      expect(find.text('A: 2'), findsOneComponent);
      expect(find.text('B: 3.5'), findsOneComponent);

      // since only A has changed, only AComponent should be rebuilt.
      expect(buildCalledFor, <Key>{
        App.componentKey,
        // ExampleComponent should NOT be rebuilt
        // BComponent should NOT be rebuilt
        // AComponent should NOT be rebuilt
      });

      // reset tracking of build
      buildCalledFor.clear();
    });
  });
}
