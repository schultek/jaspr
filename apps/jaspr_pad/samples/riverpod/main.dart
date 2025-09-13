// [sample=2] Jaspr Riverpod
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_riverpod/legacy.dart';

void main() {
  runApp(ProviderScope(child: App()));
}

final counterProvider = StateProvider((ref) => 0);

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div([
      Builder(
        builder: (context) {
          var count = context.watch(counterProvider);
          return text('Count is $count');
        },
      ),
      button(
        onClick: () {
          context.read(counterProvider.notifier).state++;
        },
        [text('Press Me')],
      ),
    ]);
  }
}
