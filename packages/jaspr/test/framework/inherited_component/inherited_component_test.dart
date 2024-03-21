@TestOn('vm')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../../utils/test_component.dart';
import 'inherited_component_app.dart';

void main() {
  group('inherited component test', () {
    testComponents('should inherit component', (tester) async {
      var controller = await tester.pumpTestComponent(App());

      // phase 1: inherited component should be mounted
      expect(find.text('Inherited value: 0'), findsOneComponent);

      var state = (find.byType(MyChildComponent).evaluate().first as StatefulElement).state as MyChildState;

      // lifecycle: state should be initialized and built a first time
      expect(state.lifecycle, equals(['initState', 'didChangeDependencies', 'build']));
      state.lifecycle.clear();

      // phase 2: component should be update when inherited value changes
      await controller.rebuildWith(1);
      expect(find.text('Inherited value: 1'), findsOneComponent);

      // lifecycle: state should be notified about changed dependencies and built again
      expect(state.lifecycle, equals(['didChangeDependencies', 'build']));
      state.lifecycle.clear();

      // phase 3: should not rebuild child when InheritedComponent.updateShouldNotify returns false
      await controller.rebuildWith(2);
      expect(find.text('Inherited value: 1'), findsOneComponent);

      // inherited value should be updated, but without notifying dependants
      expect(find.byComponentPredicate((component) => component is MyInheritedComponent && component.value == 2),
          findsOneComponent);

      // lifecycle: state should not be updated
      expect(state.lifecycle, equals([]));
      state.lifecycle.clear();
    });
  });
}
