import 'history_stub.dart' if (dart.library.html) 'history_browser.dart';

/// Interface for history management
/// Will be implemented separately on browser and server
abstract class HistoryManager {
  static HistoryManager instance = HistoryManagerImpl();

  /// Initialize the history manager and setup any listeners to history changes
  void init(String location, void Function(String url) onChange);

  /// Push a new state to the history
  void push(String url, {String? title, Object? data});

  /// Replace the current history state
  void replace(String url, {String? title, Object? data});

  /// Go back in the history
  void back();
}
