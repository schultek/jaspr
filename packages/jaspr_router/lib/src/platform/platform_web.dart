import 'dart:html';

import '../route.dart';
import 'platform.dart';

class PlatformRouterImpl implements PlatformRouter {
  @override
  final HistoryManager history = HistoryManagerImpl();

  @override
  final RouteRegistry registry = RouteRegistryImpl();
}

/// Browser implementation of HistoryManager
/// Accesses the window.history api
class HistoryManagerImpl implements HistoryManager {
  @override
  void init(String locationn, void Function(String url) onChange) {
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

class RouteRegistryImpl implements RouteRegistry {
  @override
  void registerRoutes(List<RouteBase> routes) {}
}
