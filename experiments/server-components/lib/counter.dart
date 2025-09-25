import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_riverpod/legacy.dart';

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
  Component build(BuildContext context) {
    return div([
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
