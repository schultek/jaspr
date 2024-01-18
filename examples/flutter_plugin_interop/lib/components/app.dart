import 'package:jaspr/jaspr.dart';

import 'counter.server.dart' if (dart.library.html) 'counter.web.dart';

// A simple [StatelessComponent] with a [build] method
@client
class App extends StatelessComponent {
  const App({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Counter();
  }
}
