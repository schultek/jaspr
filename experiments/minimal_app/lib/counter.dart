
import 'package:jaspr/jaspr.dart';

@island
class Counter extends StatefulComponent {
  final int initialValue;
  final String someText;

  const Counter({this.initialValue = 0, this.someText = 'hello_test'});

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
    yield DomComponent(
      tag: 'span',
      child: Text('Count is $count'),
    );

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
