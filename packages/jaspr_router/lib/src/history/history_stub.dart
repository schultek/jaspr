import 'history.dart';

/// Server implementation of HistoryManager
/// This will just throw on each method, since routing is not supported on the server
class HistoryManagerImpl implements HistoryManager {
  @override
  void push(String url, {String? title, Object? data}) {
    throw UnimplementedError('Routing unavailable on the server');
  }

  @override
  void replace(String url, {String? title, Object? data}) {
    throw UnimplementedError('Routing unavailable on the server');
  }

  @override
  void back() {
    throw UnimplementedError('Routing unavailable on the server');
  }

  @override
  void init(void Function(String) onChange) {
    // No-op
  }
}
