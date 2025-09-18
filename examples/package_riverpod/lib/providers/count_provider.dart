import 'dart:math';

import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_riverpod/legacy.dart';

/// A provider that preloads its value on the server, and syncs with the client.
///
/// The create function of a SyncProvider is only executed on the server, and
/// never on the client. Instead the synced value is returned.
final initialCountProvider = FutureProvider<int>((ref) async {
  return Random().nextInt(100);
});

/// A provider that holds the current count.
///
/// It uses the synced initial count value as its initial value.
final countProvider = StateProvider<int>((ref) {
  return ref.watch(initialCountProvider).value ?? 0;
});
