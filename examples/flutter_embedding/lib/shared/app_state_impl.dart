import 'package:js/js.dart';

import '../interop/state.dart';
import 'app_state.dart';

/// This is the state object that will be shared between the two dart
/// scripts through js.
///
/// The [@JS() @Anonymous] combination is the only case that worked during
/// my testing. The new [@JSExport] annotation did not work. This is due
/// to the fact that any dart class that is compiled for multiple programs
/// (ie. jaspr and flutter), will have unique type identities in each of the programs.
/// Therefore sharing (assigning, comparing, etc.) a normal dart class across
/// the two programs won't work, as the runtime thinks they are two separate types.
@JS()
@anonymous
class AppState {
  external factory AppState({int count, String screen});

  external int count;
  external String screen;
}

/// See the [InteropNotifier] (where the magic happens).
class AppStateNotifierImpl extends InteropNotifier<AppState> implements AppStateNotifier {
  @override
  AppState buildState() {
    return AppState(count: 0, screen: DemoScreen.counter.name);
  }

  void increment() {
    state = AppState(count: state.count + 1, screen: state.screen);
  }

  void changeDemoScreenTo(DemoScreen screen) {
    state = AppState(count: state.count, screen: screen.name);
  }
}
