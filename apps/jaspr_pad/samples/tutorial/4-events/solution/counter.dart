import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;

  @override
  Component build(BuildContext context) {
    return .fragment([
      .text('Count: $count'),
      button(
        onClick: () {
          setState(() {
            count++;
          });
        },
        [.text('Counter')],
      ),
    ]);
  }
}
