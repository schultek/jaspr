import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'counter.dart';

/// App component that displays a simple counter.
///
/// The [@client] annotation will render this component
/// on the client (additionally to being server rendered)
/// and make it interactive.
@client
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ProviderScope(child: Counter());
  }
}
