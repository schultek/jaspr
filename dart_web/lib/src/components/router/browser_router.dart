import 'dart:html' hide Element;

import '../../../dart_web.dart';

/// Browser implementation of HistoryManager
/// Accesses the window.history api
class HistoryManagerImpl implements HistoryManager {
  @override
  void init(void Function(String) onChange) {
    window.onPopState.listen((event) {
      onChange(window.location.pathname!);
    });
  }

  @override
  void push(String path, {String? title}) {
    window.history.pushState(null, title ?? path, path);
  }

  @override
  void replace(String path, {String? title}) {
    window.history.replaceState(null, title ?? path, path);
  }

  @override
  void back() {
    window.history.back();
  }
}
