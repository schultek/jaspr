import 'package:jaspr/jaspr.dart';

@client
class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int counter = 0;

  @override
  Component build(BuildContext context) {
    return fragment([
      span([text("Count: $counter ")]),
      button(
        onClick: () {
          setState(() {
            counter++;
          });
        },
        [text("Increase")],
      ),
    ]);
  }
}
