import 'dart:html' hide Element;

import 'history.dart';

/// Browser implementation of HistoryManager
/// Accesses the window.history api
class HistoryManagerImpl implements HistoryManager {
  @override
  void init(void Function(String url) onChange) {
    window.onPopState.listen((event) {
      onChange(window.location.href.substring(window.location.origin.length));
    });
  }

  @override
  void push(String url, {String? title, Object? data}) {
    window.history.pushState(data, title ?? url, url);
  }

  @override
  void replace(String url, {String? title, Object? data}) {
    window.history.replaceState(data, title ?? url, url);
  }

  @override
  void back() {
    window.history.back();
  }
}
