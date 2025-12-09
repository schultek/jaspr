@TestOn('vm')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../../utils/test_component.dart';
import '../../utils/track_state_lifecycle.dart';

class MyInheritedComponent extends InheritedComponent {
  MyInheritedComponent({required this.value, required super.child});

  final int value;

  @override
  bool updateShouldNotify(covariant MyInheritedComponent oldComponent) {
    return value != oldComponent.value && value < 2;
  }
}

class MyChildComponent extends StatefulComponent {
  const MyChildComponent();

  @override
  State<StatefulComponent> createState() => MyChildState();
}

class MyChildState extends State<MyChildComponent> with TrackStateLifecycle<MyChildComponent> {
  int? inheritedValue;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    inheritedValue = context.dependOnInheritedComponentOfExactType<MyInheritedComponent>()!.value;
  }

  @override
  Component build(BuildContext context) {
    trackBuild();
    return Component.text('Inherited value: $inheritedValue');
  }
}

void main() {
  group('inherited component test', () {
    testComponents('should inherit component', (tester) async {
      final component = FakeComponent(child: MyInheritedComponent(value: 0, child: const MyChildComponent()));

      tester.pumpComponent(component);

      // phase 1: inherited component should be mounted
      expect(find.text('Inherited value: 0'), findsOneComponent);

      final state = (find.byType(MyChildComponent).evaluate().first as StatefulElement).state as MyChildState;

      // lifecycle: state should be initialized and built a first time
      expect(state.lifecycle, equals(['initState', 'didChangeDependencies', 'build']));
      state.lifecycle.clear();

      // phase 2: component should be update when inherited value changes
      component.updateChild(MyInheritedComponent(value: 1, child: const MyChildComponent()));
      await tester.pump();

      expect(find.text('Inherited value: 1'), findsOneComponent);

      // lifecycle: state should be notified about changed dependencies and built again
      expect(state.lifecycle, equals(['didChangeDependencies', 'build']));
      state.lifecycle.clear();

      // phase 3: should not rebuild child when InheritedComponent.updateShouldNotify returns false
      component.updateChild(MyInheritedComponent(value: 2, child: const MyChildComponent()));
      await tester.pump();

      expect(find.text('Inherited value: 1'), findsOneComponent);

      // inherited value should be updated, but without notifying dependants
      expect(
        find.byComponentPredicate((component) => component is MyInheritedComponent && component.value == 2),
        findsOneComponent,
      );

      // lifecycle: state should not be updated
      expect(state.lifecycle, equals([]));
      state.lifecycle.clear();
    });
  });
}
