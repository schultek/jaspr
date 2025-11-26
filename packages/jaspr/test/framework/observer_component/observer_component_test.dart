@TestOn('vm')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

import '../../utils/test_component.dart';
import 'observer_component_app.dart';

void main() {
  group('observer component', () {
    testComponents('should track elements', (tester) async {
      ObserverParam params = ObserverParam(renderBoth: true, events: []);
      final events = params.events;
      final controller = tester.pumpTestComponent(App(params));

      // phase 1: observer component should be mounted
      expect(find.text('Leaf true false'), findsOneComponent);

      MyChildState state = (find.byType(MyChildComponent).evaluate().first as StatefulElement).state as MyChildState;

      // lifecycle: state should be initialized and built a first time
      expect(state.lifecycle, equals(['initState', 'didChangeDependencies', 'build']));
      state.lifecycle.clear();

      void checkEvents(List<MapEntry<TypeMatcher<Element>, ObserverElementEvent>> expected) {
        expect(
          events.map((e) => {'elem': e.key, 'event': e.value}),
          expected.map((e) => {'elem': e.key, 'event': e.value}),
        );
      }

      // First build with two MyObserverElements
      final initialEvents = [
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<StatelessElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<StatelessElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<DomElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<DomElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<TextElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<TextElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<TextElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<TextElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<DomElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<DomElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<StatelessElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<StatelessElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.didRebuild),
      ];
      checkEvents(initialEvents);
      events.clear();

      await controller.rebuild();

      expect(find.text('Leaf true false'), findsOneComponent);
      // lifecycle: state should be updated
      expect(state.lifecycle, equals(['didUpdateComponent', 'build']));

      // Same events as the first time on rebuild
      checkEvents([
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<StatelessElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<StatelessElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<DomElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<DomElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<DomElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<DomElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<StatelessElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<StatelessElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.didRebuild),
      ]);
      events.clear();

      params = ObserverParam(renderBoth: false, events: events);
      // phase 2: Remove child MyObserverElement
      await controller.rebuildWith(params);

      final newState = (find.byType(MyChildComponent).evaluate().first as StatefulElement).state as MyChildState;
      expect(state, isNot(newState));
      state = newState;
      expect(find.text('Leaf false false'), findsOneComponent);
      // lifecycle: state should be initialized and built a first time
      expect(state.lifecycle, equals(['initState', 'didChangeDependencies', 'build']));
      state.lifecycle.clear();

      // Second build with one MyObserverElement and unmount the others
      checkEvents([
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<StatelessElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<DomElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<TextElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<TextElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<DomElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<StatelessElement>(), ObserverElementEvent.didRebuild),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.didRebuild),
        // unmount
        MapEntry(isA<TextElement>(), ObserverElementEvent.didUnmount),
        MapEntry(isA<TextElement>(), ObserverElementEvent.didUnmount),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.didUnmount),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.didUnmount),
        MapEntry(isA<DomElement>(), ObserverElementEvent.didUnmount),
        MapEntry(isA<DomElement>(), ObserverElementEvent.didUnmount),
        MapEntry(isA<StatelessElement>(), ObserverElementEvent.didUnmount),
        MapEntry(isA<StatelessElement>(), ObserverElementEvent.didUnmount),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.didUnmount),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.didUnmount),
      ]);
      events.clear();

      await controller.rebuild();

      expect(find.text('Leaf false false'), findsOneComponent);
      // lifecycle: state should not be updated
      expect(state.lifecycle, equals([]));

      // Only MyObserverElement is rebuilt since child is the same
      checkEvents([
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<MyObserverElement>(), ObserverElementEvent.didRebuild),
      ]);
      events.clear();

      state.notifier.value = !state.notifier.value;
      await tester.pump();

      expect(find.text('Leaf false true'), findsOneComponent);
      // lifecycle: state should be updated
      expect(state.lifecycle, equals(['build']));
      state.lifecycle.clear();

      // Only Leaf StatefulElement is rebuilt it executed setState
      checkEvents([
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.willRebuild),
        MapEntry(isA<StatefulElement>(), ObserverElementEvent.didRebuild),
      ]);
      events.clear();

      // observer value should be updated, but without notifying dependants
      expect(
        find.byComponentPredicate((component) => component is MyObserverComponent && component.value == params),
        findsOneComponent,
      );
    });
  });
}
