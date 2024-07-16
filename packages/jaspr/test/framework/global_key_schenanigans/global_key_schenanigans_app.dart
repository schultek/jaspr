import 'package:jaspr/jaspr.dart';

import '../../utils/test_component.dart';
import '../../utils/track_state_lifecycle.dart';

class App extends TestComponent<int> {
  const App() : super(initialValue: 1);

  @override
  Iterable<Component> build(BuildContext context, int phase) sync* {
    if (phase == 1) {
      yield Child(key: GlobalObjectKey('test'));
    } else if (phase == 2) {
      yield DomComponent(
        tag: 'div',
        child: Child(
          key: GlobalObjectKey('test'),
        ),
      );
    }
  }
}

class Child extends StatefulComponent {
  const Child({super.key});

  @override
  State createState() => ChildState();
}

class ChildState extends State<Child> with TrackStateLifecycle<Child> {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield* super.build(context);
    yield const Text('Child');
  }
}
