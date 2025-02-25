import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

final counter = StateProvider((_) => 0);

@client
class Counter extends StatefulComponent {
  const Counter({super.key});
  
  @override
  State<StatefulComponent> createState() => CounterState();
}

class CounterState extends State<Counter> {

  int count = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div([
      text('$count'),
      text(' Shared: ${context.watch(counter)}'),
      button(onClick: () {
        context.read(counter.notifier).state++;
        setState(() {
          count++;
        });
      }, [
        text("Increase"),
      ])
    ]);
  }
}
