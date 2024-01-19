import 'package:jaspr_riverpod/jaspr_riverpod.dart';

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
final countProvider = StateProvider<int>((ref) {
  return ref.watch(initialCountProvider).valueOrNull ?? 0;
});
