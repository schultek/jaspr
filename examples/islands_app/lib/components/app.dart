import 'package:jaspr/jaspr.dart';

import 'content.dart';

// A normal component wich is not part of a island subtree
// - will not be bundled to javascript
// - will not be hydrated and made interactive on the client
class App extends StatelessComponent {
  const App({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    // island components can be used multiple times, but not nested
    yield Content(greet: 'World');
    // two island components of the same kind will be hydrated separately
    yield Content(greet: 'Dash');
  }
}
