import 'package:js/js.dart';

import '../interop/state.dart';

enum DemoScreen { counter, textField, custom }

@JS()
@anonymous
class AppState {
  external factory AppState({int count, String screen});

  external int count;
  external String screen;
}

class AppStateNotifier extends InteropStateNotifier<AppState> {
  AppStateNotifier() : super(AppState(count: 0, screen: DemoScreen.counter.name));

  int get count => state.count;
  DemoScreen get currentScreen => DemoScreen.values.byName(state.screen);

  void increment() {
    state = AppState(count: state.count + 1, screen: state.screen);
  }

  void changeDemoScreenTo(DemoScreen screen) {
    state = AppState(count: state.count, screen: screen.name);
  }
}