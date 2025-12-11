// [sample][hidden] Tutorial
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'counter.dart';

void main() {
  runApp(App());
}

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return .fragment([
      div([
        h1([.text('Hello World!')]),
        p([.text('You\'re great!')]),
      ]),
      Counter(),
    ]);
  }
}
