import 'package:jaspr/islands.dart';
import 'package:jaspr/jaspr.dart';

class CounterIsland extends Island<int> {
  CounterIsland() : super(name: 'cnt');

  Component build(BuildContext context, int value) {
    return Counter(initialValue: value);
  }

  static Component create(int i) {
    return Island.put(CounterIsland(), i);
  }
}

class Counter extends StatefulComponent {
  final int initialValue;

  const Counter({this.initialValue = 0, Key? key}) : super(key: key);

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    count = component.initialValue;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Text('Count is $count');

    yield DomComponent(
      tag: 'button',
      events: {
        'click': (e) {
          setState(() => count++);
        },
      },
      child: Text('Press Me'),
    );
  }
}
