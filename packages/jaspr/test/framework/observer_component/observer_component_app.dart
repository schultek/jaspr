import 'package:jaspr/jaspr.dart';

import '../../utils/test_component.dart';
import '../../utils/track_state_lifecycle.dart';

class ObserverParam {
  ObserverParam({
    required this.renderBoth,
    required this.events,
  });

  final List<MapEntry<Element, ObserverElementEvent>> events;
  final bool renderBoth;
}

class App extends TestComponent<ObserverParam> {
  const App(ObserverParam param) : super(initialValue: param);

  static const child = DomComponent(
    tag: 'div',
    child: MyChildComponent(value: false),
  );

  @override
  Iterable<Component> build(BuildContext context, ObserverParam value) sync* {
    yield MyObserverComponent(
      value: value,
      child: value.renderBoth
          ? MyObserverComponent(
              value: value,
              child: const DomComponent(
                tag: 'div',
                child: MyChildComponent(value: true),
              ),
            )
          : child,
    );
  }
}

class MyObserverComponent extends ObserverComponent {
  const MyObserverComponent({required this.value, required super.child});

  final ObserverParam value;

  @override
  MyObserverElement createElement() => MyObserverElement(this);
}

enum ObserverElementEvent {
  didRebuild,
  didUnmount,
  willRebuild,
}

class MyObserverElement extends ObserverElement {
  MyObserverElement(super.component);

  ObserverParam get value => (component as MyObserverComponent).value;

  @override
  void didRebuildElement(Element element) {
    value.events.add(MapEntry(element, ObserverElementEvent.didRebuild));
  }

  @override
  void didUnmountElement(Element element) {
    value.events.add(MapEntry(element, ObserverElementEvent.didUnmount));
  }

  @override
  void willRebuildElement(Element element) {
    value.events.add(MapEntry(element, ObserverElementEvent.willRebuild));
  }
}

class MyChildComponent extends StatefulComponent {
  const MyChildComponent({
    required this.value,
  });
  final dynamic value;
  @override
  State<StatefulComponent> createState() => MyChildState();
}

class MyChildState extends State<MyChildComponent> with TrackStateLifecycle<MyChildComponent> {
  late final ValueNotifier<bool> notifier;

  @override
  void initState() {
    super.initState();
    notifier = ValueNotifier(false);
    notifier.addListener(() {
      setState(() {});
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield* super.build(context);
    yield Text('Leaf ${component.value} ${notifier.value}');
  }
}
