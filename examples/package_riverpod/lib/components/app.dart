import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../providers/count_provider.dart';
import 'counter.dart';

/// App component that displays a simple counter.
///
/// The [@client] annotation will render this component
/// on the client (additionally to being server rendered)
/// and make it interactive.
@client
class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return ProviderScope(
      sync: [
        initialCountProvider.syncWith('initial_count'),
      ],
      child: Counter(),
    );
  }
}
