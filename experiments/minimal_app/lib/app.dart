import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      child: Text('Hello World'),
    );

    yield Counter();
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
    var button = DomComponent(
      key: ValueKey('button'),
      tag: 'button',
      events: {
        'click': (e) {
          setState(() => count++);
        },
      },
      child: Text('Press Me'),
    );

    if (count > 5) {
      yield button;
    }

    yield Text('Count is $count', key: ValueKey('text'));

    if (count > 5) {
      yield Text('YAAAY');
    } else {
      yield button;
    }

    if (count > 6) {
      yield Text('Ended');
    }
  }
}
