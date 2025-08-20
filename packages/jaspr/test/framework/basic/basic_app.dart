import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Fragment(children: [
      Text('App'),
      Counter(),
    ]);
  }
}

class Counter extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => CounterState();
}

class CounterState extends State<Counter> {
  int counter = 0;

  @override
  Component build(BuildContext context) {
    return Fragment(children: [
      Button(
        label: 'Click Me',
        onPressed: () {
          setState(() => counter++);
        },
      ),
      Text('Count: $counter'),
    ]);
  }
}

class Button extends StatelessComponent {
  const Button({required this.label, required this.onPressed});

  final String label;
  final void Function() onPressed;

  @override
  Component build(BuildContext context) {
    return button(
      events: {'click': (e) => onPressed()},
      [text(label)],
    );
  }
}
