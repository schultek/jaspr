import 'package:jaspr/jaspr.dart';

import '../../utils/test_component.dart';
import '../../utils/track_state_lifecycle.dart';

final myKey = GlobalKey();

class App extends TestComponent<int> {
  App() : super(initialValue: 1);

  @override
  Iterable<Component> build(BuildContext context, int phase) sync* {
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

class MyStatefulComponent extends StatefulComponent {
  MyStatefulComponent({Key? key}) : super(key: key);
  @override
  State<StatefulComponent> createState() => MyState();
}

class MyState extends State<MyStatefulComponent> with TrackStateLifecycle<MyStatefulComponent> {}
