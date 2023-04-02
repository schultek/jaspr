import 'history.dart';

/// Server implementation of HistoryManager
/// This will just throw on each method, since routing is not supported on the server
class HistoryManagerImpl implements HistoryManager {
  @override
  void push(Uri uri, {String? title}) {
    throw UnimplementedError('Routing unavailable on the server');
  }

  @override
  void replace(Uri uri, {String? title}) {
    throw UnimplementedError('Routing unavailable on the server');
  }

  @override
  void back() {
    throw UnimplementedError('Routing unavailable on the server');
  }

  @override
  void init(void Function(Uri) onChange) {
    // No-op
  }
}
