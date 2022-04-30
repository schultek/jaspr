import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../../utils/test_component.dart';
import 'rebuild_schenanigans_app.dart';

void main() {
  group('rebuild schenanigans test', () {
    late ComponentTester tester;

    setUp(() {
      tester = ComponentTester.setUp();
    });

    test('should keep state on reparenting', () async {
      await tester.pumpTestComponent(App());

      var state = (find.byType(ParentComponent).evaluate().first as StatefulElement).state as ParentComponentState;

      // lifecycle: state should be initialized and built a first time
      expect(state.lifecycle, equals(['initState', 'didChangeDependencies']));
      state.lifecycle.clear();

      await tester.click(find.tag('button'));
      expect(find.text('Trigger true'), findsOneComponent);

      // lifecycle: state should be built again
      //expect(state.lifecycle, equals(['deactivate', 'activate', 'didUpdateComponent', 'didChangeDependencies', 'build']));
      state.lifecycle.clear();
    });
  });
}
