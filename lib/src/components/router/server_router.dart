import 'router.dart';

class HistoryManagerImpl extends HistoryManager {
  HistoryManagerImpl() : super.base();

  @override
  void push(String path) {
    throw 'Routing unavailable on server';
  }

  @override
  void back() {
    throw 'Routing unavailable on server';
  }
}
