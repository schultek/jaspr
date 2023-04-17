import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../../utils/test_component.dart';
import 'stateful_reparenting_app.dart';

void main() {
  group('stateful reparenting test', () {
    testComponents('should keep state on reparenting', (tester) async {
      var controller = await tester.pumpTestComponent(App());

      // phase 1: component should be mounted directly
      expect(find.byType(MyStatefulComponent), findsOneComponent);
      expect(find.tag('div'), findsNothing);

      var state = (find.byType(MyStatefulComponent).evaluate().first as StatefulElement).state as MyState;

      // lifecycle: state should be initialized and built a first time
      expect(state.lifecycle, equals(['initState', 'didChangeDependencies', 'build']));
      state.lifecycle.clear();

      // phase 2: component should be mounted as child of a div element
      await controller.rebuildWith(2);
      expect(find.descendant(of: find.tag('div'), matching: find.byType(MyStatefulComponent)), findsOneComponent);

      // lifecycle: state should be reparented, updated and built again
      expect(
          state.lifecycle, equals(['deactivate', 'activate', 'didUpdateComponent', 'didChangeDependencies', 'build']));
      state.lifecycle.clear();

      // phase 3: component should be unmounted
      await controller.rebuildWith(3);
      expect(find.byType(MyStatefulComponent), findsNothing);

      // lifecycle: state should be disposed
      expect(state.lifecycle, equals(['deactivate', 'dispose']));
      expect(state.mounted, equals(false));
    });
  });
}
