import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'counter.dart';
import 'counter2.dart';

/// App component that displays a simple counter.
///
/// The [@client] annotation will render this component
/// on the client (additionally to being server rendered)
/// and make it interactive.
@client
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Counter2();
    yield hr();
    yield Counter2();
    yield ProviderScope(child: Counter());
  }
}
