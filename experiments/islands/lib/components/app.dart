import 'package:jaspr/jaspr.dart';

import 'counter.island.g.dart';

class App extends StatelessComponent {
  final int numCounters;

  const App(this.numCounters);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      child: Text('Hello World'),
    );

    for (var i = 0; i < numCounters; i++) {
      yield CounterIsland(initialValue: i * 2);
    }
  }
}
