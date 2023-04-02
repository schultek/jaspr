import 'history_stub.dart' if (dart.library.html) 'history_browser.dart';

/// Interface for history management
/// Will be implemented separately on browser and server
abstract class HistoryManager {
  static HistoryManager instance = HistoryManagerImpl();

  /// Initialize the history manager and setup any listeners to history changes
  void init(void Function(Uri) onChange);

  /// Push a new state to the history
  void push(Uri uri, {String? title});

  /// Replace the current history state
  void replace(Uri uri, {String? title});

  /// Go back in the history
  void back();
}
