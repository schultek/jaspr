import 'package:riverpod/riverpod.dart';

final effectsProvider = StateProvider((ref) => <String>{});
final rotationProvider = StateProvider((ref) => 0.0);