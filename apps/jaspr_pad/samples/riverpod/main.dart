// [sample=2] Jaspr Riverpod
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

void main() {
  runApp(ProviderScope(child: App()));
}

final counterProvider = NotifierProvider<_CounterNotifier, int>(_CounterNotifier.new);

class _CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state = state + 1;
}

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
          context.read(counterProvider.notifier).increment();
        },
        [text('Press Me')],
      ),
    ]);
  }
}
