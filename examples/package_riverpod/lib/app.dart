import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

part 'app.g.dart';

/// App component that displays a simple counter.
///
/// The [@client] annotation will render this component
/// on the client (additionally to being server rendered)
/// and make it interactive.
@client
class App extends StatelessComponent with _$App {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ProviderScope(child: Counter());
  }
}

/// A provider that preloads its value on the server, and syncs with the client.
///
/// The create function of a SyncProvider is only executed on the server, and
/// never on the client. Instead the synced value is returned.
final initialCountProvider = SyncProvider<int>((ref) async {
  // get the initial count from the request uri
  var countParam = ref.binding.currentUri.queryParameters['count'];
  return int.tryParse(countParam ?? '') ?? 0;
}, id: 'initial_count');

/// A provider that holds the current count.
///
/// It uses the synced initial count value as its initial value.
final counterProvider = StateProvider<int>((ref) {
  return ref.watch(initialCountProvider).valueOrNull ?? 0;
});

class Counter extends StatelessComponent with SyncProviderDependencies {
  /// Specify which SyncProviders to preload before executing build().
  ///
  /// This makes sure that the value of the specified providers is directly
  /// available when build() is called, even if its an asynchronous value.
  @override
  Iterable<SyncProvider> get preloadDependencies => [initialCountProvider];

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Button(
      label: 'Click Me',
      onPressed: () {
        context.read(counterProvider.notifier).state++;
      },
    );

    yield DomComponent(
      tag: 'span',
      child: Text('Counter: ${context.watch(counterProvider)}'),
    );
  }
}

/// Simple button component
class Button extends StatelessComponent {
  Button({required this.label, required this.onPressed});

  final String label;
  final void Function() onPressed;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      events: {'click': (e) => onPressed()},
      child: Text(label),
    );
  }
}
