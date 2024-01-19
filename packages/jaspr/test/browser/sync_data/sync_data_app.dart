import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'div', children: [
      Text('App'),
      Counter(),
    ]);
  }
}

class Counter extends StatefulComponent {
  Counter({super.key});

  @override
  State<StatefulComponent> createState() => CounterState();
}

class CounterState extends State<Counter> with SyncStateMixin<Counter, int> {
  int counter = 0;

  @override
  int getState() => throw UnimplementedError();

  @override
  String get syncId => 'counter';

  @override
  void updateState(int? value) {
    counter = value ?? counter;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Button(
      label: 'Click Me',
      onPressed: () {
        setState(() => counter++);
      },
    );

    yield Text('Count: $counter');
  }
}

class Button extends StatelessComponent {
  const Button({required this.label, required this.onPressed});

  final String label;
  final void Function() onPressed;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      child: Text(label),
      events: {'click': (e) => onPressed()},
    );
  }
}
