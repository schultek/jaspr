@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../../utils/test_component.dart';
import '../../utils/track_state_lifecycle.dart';

class Child extends StatefulComponent {
  Child({super.key});

  @override
  State createState() => ChildState();
}

class ChildState extends State<Child> with TrackStateLifecycle<Child> {
  @override
  Component build(BuildContext context) {
    trackBuild();
    return Component.text('Child');
  }
}

void main() {
  final myKey = GlobalKey();

  group('global key schenanigans test', () {
    testComponents('should keep state on reparenting', (tester) async {
      final component = FakeComponent(child: Child(key: myKey));

      tester.pumpComponent(component);

      // phase 1: component should be mounted directly
      expect(find.byType(Child), findsOneComponent);
      expect(find.tag('div'), findsNothing);

      final state = (find.byType(Child).evaluate().first as StatefulElement).state as ChildState;

      // lifecycle: state should be initialized and built a first time
      expect(state.lifecycle, equals(['initState', 'didChangeDependencies', 'build']));
      state.lifecycle.clear();

      // phase 2: component should be mounted as child of a div element
      component.updateChild(div([Child(key: myKey)]));
      await tester.pump();

      expect(find.descendant(of: find.tag('div'), matching: find.byType(Child)), findsOneComponent);

      // lifecycle: state should be reparented, updated and built again
      expect(state.lifecycle, equals(['deactivate', 'activate', 'didUpdateComponent', 'build']));
      state.lifecycle.clear();

      // phase 3: component should be unmounted
      component.updateChild(Component.text(''));
      await tester.pump();

      expect(find.byType(Child), findsNothing);

      // lifecycle: state should be disposed
      expect(state.lifecycle, equals(['deactivate', 'dispose']));
      expect(state.mounted, equals(false));
    }, timeout: Timeout.none);
  });
}
