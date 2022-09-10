import 'package:jaspr/jaspr.dart';

import 'counter.dart';

@app
class App extends StatelessComponent {
  final int numCounters;

  const App(this.numCounters);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      events: {
        'click': (e) {
          print("Clicked");
        }
      },
      child: Text('Hello World'),
    );
    yield DomComponent(
      tag: 'div',
      children: [
        for (var i = 0; i < numCounters; i++) Counter(initialValue: i * 2),
      ],
    );
  }
}
