import 'package:jaspr/jaspr.dart';

import '../../utils/test_component.dart';
import '../../utils/track_state_lifecycle.dart';

final myKey = GlobalKey();

class App extends TestComponent<int> {
  App() : super(initialValue: 0);

  final child = div([MyChildComponent()]);

  @override
  Iterable<Component> build(BuildContext context, int counter) sync* {
    yield MyInheritedComponent(
      value: counter,
      child: child,
    );
  }
}

class MyInheritedComponent extends InheritedComponent {
  MyInheritedComponent({required this.value, required super.child});

  final dynamic value;

  @override
  bool updateShouldNotify(covariant MyInheritedComponent oldComponent) {
    return value != oldComponent.value && value < 2;
  }
}

class MyChildComponent extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => MyChildState();
}

class MyChildState extends State<MyChildComponent> with TrackStateLifecycle<MyChildComponent> {
  dynamic inheritedValue;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    inheritedValue = context.dependOnInheritedComponentOfExactType<MyInheritedComponent>()!.value;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield* super.build(context);
    yield Text('Inherited value: $inheritedValue');
  }
}
