import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
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
      p([.text('Count: $count')]),
      button(
        events: {
          'click': (_) {
            print("clicked $count");
            setState(() => count++);
          },
        },
        [.text('Increment')],
      ),
    ]);
  }
}
