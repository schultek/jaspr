import 'dart:html' hide Element;

import 'history.dart';

/// Browser implementation of HistoryManager
/// Accesses the window.history api
class HistoryManagerImpl implements HistoryManager {
  @override
  void init(void Function(Uri) onChange) {
    window.onPopState.listen((event) {
      onChange(Uri.parse(window.location.href));
    });
  }

  @override
  void push(Uri uri, {String? title}) {
    window.history.pushState(null, title ?? uri.path, uri.toString());
  }

  @override
  void replace(Uri uri, {String? title}) {
    window.history.replaceState(null, title ?? uri.path, uri.toString());
  }

  @override
  void back() {
    window.history.back();
  }
}
