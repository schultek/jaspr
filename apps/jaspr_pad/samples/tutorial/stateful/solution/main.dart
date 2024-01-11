// [sample][hidden] Tutorial
import 'package:jaspr/jaspr.dart';

import 'counter.dart';

void main() {
  runApp(App());
}

class App extends StatelessComponent {
  const App({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div([
      h1([text('Hello World!')]),
      p([text('You\'re great!')]),
    ]);

    yield Counter();
  }
}
