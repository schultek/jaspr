import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../../utils/test_component.dart';
import 'global_key_schenanigans_app.dart';

void main() {
  group('global key schenanigans test', () {
    testComponents('should keep state on reparenting', (tester) async {
      var controller = await tester.pumpTestComponent(App());

      // phase 1: component should be mounted directly
      expect(find.byType(Child), findsOneComponent);
      expect(find.tag('div'), findsNothing);

      var state = (find.byType(Child).evaluate().first as StatefulElement).state as ChildState;

      // lifecycle: state should be initialized and built a first time
      expect(state.lifecycle, equals(['initState', 'didChangeDependencies', 'build']));
      state.lifecycle.clear();

      // phase 2: component should be mounted as child of a div element
      await controller.rebuildWith(2);
      expect(find.descendant(of: find.tag('div'), matching: find.byType(Child)), findsOneComponent);

      // lifecycle: state should be reparented, updated and built again
      expect(state.lifecycle, equals(['deactivate', 'activate', 'didUpdateComponent', 'build']));
      state.lifecycle.clear();

      // phase 3: component should be unmounted
      await controller.rebuildWith(3);
      expect(find.byType(Child), findsNothing);

      // lifecycle: state should be disposed
      expect(state.lifecycle, equals(['deactivate', 'dispose']));
      expect(state.mounted, equals(false));
    }, timeout: Timeout.none);
  });
}
