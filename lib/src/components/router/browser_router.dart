import 'dart:convert';
import 'dart:html' hide Element;

import '../../../dart_web.dart';

class HistoryManagerImpl extends HistoryManager {
  HistoryManagerImpl() : super.base();

  @override
  void init(void Function(String) onChange) {
    window.onPopState.listen((event) {
      onChange(window.location.pathname!);
    });
  }

  @override
  void push(String path) {
    window.history.pushState(null, path, path);
  }

  @override
  void back() {
    window.history.back();
  }

  @override
  Future<void>? preload(Route nextRoute) {
    AppBinding.instance!.isLoadingState = true;
    return window
        .fetch(nextRoute.path, {
          'headers': {'dart-web-mode': 'data-only'}
        })
        .then((result) => result.text())
        .then((data) {
          var map = jsonDecode(data) as Map<String, dynamic>;
          AppBinding.instance!.notifyState(map);
        });
  }
}
