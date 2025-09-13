import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../providers/count_provider.dart';
import 'button.dart';

class Counter extends StatelessComponent with SyncProviderDependencies {
  /// Specify which SyncProviders to preload before executing build().
  ///
  /// This makes sure that the value of the specified providers is directly
  /// available when build() is called, even if its an asynchronous value.
  @override
  Iterable<SyncProvider> get preloadDependencies => [initialCountProvider];

  @override
  Component build(BuildContext context) {
    return fragment([
      Button(
        label: 'Click Me',
        onPressed: () {
          context.read(countProvider.notifier).state++;
        },
      ),
      span([text('Counter: ${context.watch(countProvider)}')]),
    ]);
  }
}
