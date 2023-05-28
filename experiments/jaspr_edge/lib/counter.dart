import 'package:jaspr/html.dart';

part 'counter.g.dart';

@client
class Counter extends StatefulComponent with _$Counter {
  const Counter({Key? key}) : super(key: key);

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button([text('Click Me')], events: {'click': (_) => setState(() => count++)});

    yield text('You clicked $count times.');
  }
}
