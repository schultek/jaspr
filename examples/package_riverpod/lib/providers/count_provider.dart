import 'dart:math';

import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_riverpod/legacy.dart';

/// A provider that loads the initial count value asynchronously.
final initialCountProvider = FutureProvider<int>((ref) async {
  return Random().nextInt(100);
});

/// A provider that holds the current count.
///
/// It uses the synced initial count value as its initial value.
final countProvider = StateProvider<int>((ref) {
  return ref.watch(initialCountProvider).value ?? 0;
});
