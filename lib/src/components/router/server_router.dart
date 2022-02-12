import 'router.dart';

/// Server implementation of HistoryManager
/// This will just throw on each method, since routing is not supported on the server
class HistoryManagerImpl extends HistoryManager {
  HistoryManagerImpl() : super.base();

  @override
  void push(String path, {String? title}) {
    throw 'Routing unavailable on the server';
  }

  @override
  void replace(String path, {String? title}) {
    throw 'Routing unavailable on the server';
  }

  @override
  void back() {
    throw 'Routing unavailable on the server';
  }
}
