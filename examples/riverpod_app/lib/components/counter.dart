import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'button.dart';

/// A provider that preloads its value on the server, and syncs with the client.
///
/// The create function of a SyncProvider is only executed on the server, and
/// never on the client. Instead the synced value is returned.
final initialCountFutureProvider = SyncProvider<int>((ref) async {
  await Future.delayed(Duration(seconds: 1));
  return 200;
}, id: 'initial_count');

final initialCountProvider = Provider((ref) {
  var v = ref.watch(initialCountFutureProvider);
  print("READ FUTURE: $v");
  return v.when(
    data: (v) => v,
    error: (e, st) => Error.throwWithStackTrace(e, st),
    loading: () {
      print("LOADING, deferring build");
      throw DeferAsyncBuildException(ref.read(initialCountFutureProvider.future));
    },
  );
});

/// A provider that holds the current count.
///
/// It uses the synced initial count value as its initial value.
final counterProvider = StateProvider<int>((ref) {
  return ref.watch(initialCountProvider);
});

class Counter extends StatelessComponent {
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
