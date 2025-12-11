@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../../utils/test_component.dart';
import '../../utils/track_state_lifecycle.dart';

class InheritedData extends InheritedComponent {
  InheritedData({required super.child});

  @override
  bool updateShouldNotify(covariant InheritedData oldComponent) {
    return true;
  }
}

class MyStatefulComponent extends StatefulComponent {
  MyStatefulComponent({super.key});
  @override
  State<StatefulComponent> createState() => MyState();
}

class MyState extends State<MyStatefulComponent> with TrackStateLifecycle<MyStatefulComponent> {
  @override
  Component build(BuildContext context) {
    context.dependOnInheritedComponentOfExactType<InheritedData>();
    trackBuild();
    return Component.text('');
  }
}

void main() {
  final myKey = GlobalKey();

  group('stateful reparenting test', () {
    testComponents('should keep state on reparenting', (tester) async {
      final component = FakeComponent(
        child: InheritedData(child: MyStatefulComponent(key: myKey)),
      );
      tester.pumpComponent(component);

      // phase 1: component should be mounted directly
      expect(find.byType(MyStatefulComponent), findsOneComponent);
      expect(find.tag('div'), findsNothing);

      final state = (find.byType(MyStatefulComponent).evaluate().first as StatefulElement).state as MyState;

      // lifecycle: state should be initialized and built a first time
      expect(state.lifecycle, equals(['initState', 'didChangeDependencies', 'build']));
      state.lifecycle.clear();

      // phase 2: component should be mounted as child of a div element
      component.updateChild(InheritedData(child: div([MyStatefulComponent(key: myKey)])));
      await tester.pump();

      expect(find.descendant(of: find.tag('div'), matching: find.byType(MyStatefulComponent)), findsOneComponent);

      // lifecycle: state should be reparented, updated and built again
      expect(
        state.lifecycle,
        equals(['deactivate', 'activate', 'didUpdateComponent', 'didChangeDependencies', 'build']),
      );
      state.lifecycle.clear();

      // phase 3: component should be unmounted
      component.updateChild(InheritedData(child: Component.text('')));
      await tester.pump();

      expect(find.byType(MyStatefulComponent), findsNothing);

      // lifecycle: state should be disposed
      expect(state.lifecycle, equals(['deactivate', 'dispose']));
      expect(state.mounted, equals(false));
    });
  });
}
