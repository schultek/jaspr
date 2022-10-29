import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'button.dart';

/// A provider that preloads its value on the server, and syncs with the client.
///
/// The create function of a SyncProvider is only executed on the server, and
/// never on the client. Instead the synced value is returned.
final initialCountProvider = SyncProvider<int>((ref) async {
  await Future.delayed(Duration(seconds: 1));
  return 200;
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
        context.read(counterProvider.state).state++;
      },
    );

    yield DomComponent(
      tag: 'span',
      child: Text('Counter: ${context.watch(counterProvider)}'),
    );
  }
}
