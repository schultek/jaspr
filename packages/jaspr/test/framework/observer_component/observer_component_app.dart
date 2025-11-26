import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../utils/test_component.dart';
import '../../utils/track_state_lifecycle.dart';

class ObserverParam {
  final List<MapEntry<Element, ObserverElementEvent>> events;
  final bool renderBoth;

  ObserverParam({required this.renderBoth, required this.events});
}

class App extends TestComponent<ObserverParam> {
  App(ObserverParam param) : super(initialValue: param);

  final child = div([MyChildComponent(value: false)]);

  @override
  Component build(BuildContext context, ObserverParam value) {
    return MyObserverComponent(
      value: value,
      child: value.renderBoth ? MyObserverComponent(value: value, child: div([MyChildComponent(value: true)])) : child,
    );
  }
}

class MyObserverComponent extends ObserverComponent {
  MyObserverComponent({required this.value, required super.child});

  final ObserverParam value;

  @override
  MyObserverElement createElement() => MyObserverElement(this);
}

enum ObserverElementEvent { didRebuild, didUnmount, willRebuild }

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
  final dynamic value;
  MyChildComponent({required this.value});
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
  Component build(BuildContext context) {
    trackBuild();
    return Component.text('Leaf ${component.value} ${notifier.value}');
  }
}
