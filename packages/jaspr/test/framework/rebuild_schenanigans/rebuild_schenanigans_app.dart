import 'package:jaspr/jaspr.dart';

import '../../utils/test_component.dart';
import '../../utils/track_state_lifecycle.dart';

final myKey = GlobalKey();

class App extends TestComponent<int> {
  App() : super(initialValue: 1);

  @override
  Iterable<Component> build(BuildContext context, int phase) sync* {
    yield ParentComponent();
  }
}

class ParentComponent extends StatefulComponent {
  const ParentComponent({Key? key}) : super(key: key);

  @override
  State<ParentComponent> createState() => ParentComponentState();
}

class ParentComponentState extends State<ParentComponent> with TrackStateLifecycle<ParentComponent> {
  void triggerRebuild() {
    setState(() {});
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    super.build(context);
    yield ChildComponent();
  }
}

class ChildComponent extends StatefulComponent {
  const ChildComponent({Key? key}) : super(key: key);

  @override
  State<ChildComponent> createState() => ChildComponentState();
}

class ChildComponentState extends State<ChildComponent> with TrackStateLifecycle<ChildComponent> {
  bool shouldTrigger = false;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    super.build(context);
    var parent = context.findAncestorStateOfType<ParentComponentState>()!;

    if (shouldTrigger) {
      parent.triggerRebuild();
    }

    yield DomComponent(
      tag: 'button',
      events: {
        'click': (e) {
          setState(() {
            shouldTrigger = true;
          });
        }
      },
      child: Text('Trigger $shouldTrigger'),
    );
  }
}
