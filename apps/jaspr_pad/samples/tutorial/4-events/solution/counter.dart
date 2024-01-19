import 'package:jaspr/jaspr.dart';

class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield text('Count: $count');

    yield button(
      onClick: () {
        setState(() {
          count++;
        });
      },
      [text('Counter')],
    );
  }
}
