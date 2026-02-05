// A minimal Jaspr example demonstrating the Flutter-like component model.
//
// Jaspr lets you build websites with a familiar component model that
// supports server-side rendering out of the box.
//
// To create and run a full Jaspr project:
//   dart pub global activate jaspr_cli
//   jaspr create my_website
//   cd my_website && jaspr serve
//
// For more examples, see: https://github.com/schultek/jaspr/tree/main/examples
// Documentation: https://docs.jaspr.site

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

void main() {
  Jaspr.initializeApp();

  runApp(
    Document(
      title: 'Jaspr Example',
      body: App(),
    ),
  );
}

/// A simple app demonstrating Jaspr's component model.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div([
      h1([.text('Jaspr Counter Example')]),
      const Counter(),
    ]);
  }
}

/// A stateful counter component with increment/decrement buttons.
class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => CounterState();
}

class CounterState extends State<Counter> {
  int count = 0;

  @override
  Component build(BuildContext context) {
    return div([
      p([.text('Count: $count')]),
      button(
        onClick: () => setState(() => count--),
        [.text('-')],
      ),
      button(
        onClick: () => setState(() => count++),
        [.text('+')],
      ),
    ]);
  }
}
