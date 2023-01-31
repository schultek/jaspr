enum DemoScreen { counter, textField, custom }

abstract class AppStateNotifier {
  external factory AppStateNotifier();

  int get count;
  DemoScreen get currentScreen;

  void increment();
  void changeDemoScreenTo(DemoScreen screen);

  void addListener(dynamic);
  void removeListener(dynamic);
}