import 'package:riverpod/riverpod.dart';

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);

class AppState {
  AppState({this.count = 0, this.screen = 'counter'});

  final int count;
  final String screen;
}

enum DemoScreen { counter, textField, custom }

extension AppStateScreen on AppState {
  DemoScreen get currentScreen => DemoScreen.values.byName(screen);
}

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return AppState(count: 0, screen: DemoScreen.counter.name);
  }

  void increment() {
    state = AppState(count: state.count + 1, screen: state.screen);
  }

  void changeDemoScreenTo(DemoScreen screen) {
    state = AppState(count: state.count, screen: screen.name);
  }
}
