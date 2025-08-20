import 'package:jaspr/jaspr.dart';

import '../../utils/test_component.dart';
import '../../utils/track_state_lifecycle.dart';

class App extends TestComponent<int> {
  App() : super(initialValue: 1);

  @override
  Component build(BuildContext context, int phase) {
    if (phase == 1) {
      return Child(key: GlobalObjectKey('test'));
    } else if (phase == 2) {
      return div([
        Child(
          key: GlobalObjectKey('test'),
        ),
      ]);
    } else {
      return text('');
    }
  }
}

class Child extends StatefulComponent {
  Child({super.key});

  @override
  State createState() => ChildState();
}

class ChildState extends State<Child> with TrackStateLifecycle<Child> {
  @override
  Component build(BuildContext context) {
    return Fragment(children: [
      super.build(context),
      Text('Child'),
    ]);
  }
}
