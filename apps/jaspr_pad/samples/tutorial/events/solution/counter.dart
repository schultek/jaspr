import 'package:jaspr/jaspr.dart';

class Counter extends StatefulComponent {
  const Counter({Key? key}) : super(key: key);

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;

  void increment() {
    setState(() {
      count++;
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Text('Count: $count');

    yield DomComponent(
      tag: 'button',
      events: {'click': (e) => increment()},
      child: Text('Counter'),
    );
  }
}
