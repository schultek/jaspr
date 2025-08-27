import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div([
      Text('App'),
      Counter(),
    ]);
  }
}

class Counter extends StatefulComponent {
  static int initialValue = 0;

  @override
  State<StatefulComponent> createState() => CounterState();
}

class CounterState extends State<Counter> {
  int counter = Counter.initialValue;

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
    yield button(
      events: {'click': (e) => onPressed()},
      [text(label)],
    );
  }
}
