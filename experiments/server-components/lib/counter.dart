import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

final counter = StateProvider((_) => 0);

@client
class Counter extends StatelessComponent {
  const Counter({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div([
      text('${context.watch(counter)}'),
      button(onClick: () {
        context.read(counter.notifier).state++;
      }, [
        text("Increase"),
      ])
    ]);
  }
}
