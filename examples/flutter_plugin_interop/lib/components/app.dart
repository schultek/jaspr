import 'package:jaspr/jaspr.dart';

import 'counter.server.dart' if (dart.library.js_interop) 'counter.web.dart';

// A simple [StatelessComponent] with a [build] method
@client
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return Counter();
  }
}
