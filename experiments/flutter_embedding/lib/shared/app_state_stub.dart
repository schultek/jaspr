import 'package:riverpod/riverpod.dart';

import 'app_state.dart' as a;

/// A static state implementation for the server.
///
/// Will never change.
class AppState {
  final int count = 0;
  final String screen = 'counter';
}

class AppStateNotifierImpl extends Notifier<a.AppState> implements a.AppStateNotifier {

  @override
  a.AppState build() => a.AppState();

  void increment() {}
  void changeDemoScreenTo(a.DemoScreen screen) {}
}
