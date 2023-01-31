/// This library is split up into an implementation part and a stubbing part.
/// The implementation is loaded on web and the stubbing on the server.
///
/// This is only due to platform-interop (web vs server) and not
/// js-interop. For the js-interop part check out [AppStateNotifierImpl].
library app_state;

import 'package:riverpod/riverpod.dart';

import 'app_state_impl.dart'
  if (dart.library.io) 'app_state_stub.dart';

export 'app_state_impl.dart'
  if (dart.library.io) 'app_state_stub.dart'
  show AppState;

enum DemoScreen { counter, textField, custom }

extension AppStateScreen on AppState {
  DemoScreen get currentScreen => DemoScreen.values.byName(screen);
}

abstract class AppStateNotifier implements Notifier<AppState> {
  factory AppStateNotifier() = AppStateNotifierImpl;

  void increment();
  void changeDemoScreenTo(DemoScreen screen);
}
