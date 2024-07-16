import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield const Text('App');

    yield Counter();
  }
}

class Counter extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => CounterState();
}

class CounterState extends State<Counter> {
  int counter = 0;

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
