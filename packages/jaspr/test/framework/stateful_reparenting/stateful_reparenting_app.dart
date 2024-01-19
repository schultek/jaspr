import 'package:jaspr/jaspr.dart';

import '../../utils/test_component.dart';
import '../../utils/track_state_lifecycle.dart';

final myKey = GlobalKey();

class App extends TestComponent<int> {
  App() : super(initialValue: 1);

  @override
  Iterable<Component> build(BuildContext context, int phase) sync* {
    yield InheritedData(
      child: Home(phase),
    );
  }
}

class Home extends StatelessComponent {
  Home(this.phase);

  final int phase;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (phase == 1) {
      yield MyStatefulComponent(key: myKey);
    } else if (phase == 2) {
      yield DomComponent(
        tag: 'div',
        child: MyStatefulComponent(key: myKey),
      );
    }
  }
}

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
  Iterable<Component> build(BuildContext context) {
    context.dependOnInheritedComponentOfExactType<InheritedData>();
    return super.build(context);
  }
}
