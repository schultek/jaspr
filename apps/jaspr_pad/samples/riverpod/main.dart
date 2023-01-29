// [sample=2] Jaspr Riverpod
import 'package:jaspr/components.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

void main() {
  runApp(ProviderScope(child: App()));
}

final counterProvider = StateProvider((ref) => 0);

class App extends StatelessComponent {
  const App({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Builder(builder: (context) sync* {
      var count = context.watch(counterProvider);
      yield Text('Count is $count');
    });

    yield DomComponent(
      tag: 'button',
      events: {
        'click': (e) {
          context.read(counterProvider.state).state++;
        },
      },
      child: Text('Press Me'),
    );
  }
}
