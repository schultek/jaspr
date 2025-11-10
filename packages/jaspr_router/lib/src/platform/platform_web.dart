import 'dart:js_interop';

import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart';

import '../route.dart';
import 'platform.dart';

class PlatformRouterImpl implements PlatformRouter {
  @override
  final HistoryManager history = HistoryManagerImpl();

  @override
  final RouteRegistry registry = RouteRegistryImpl();

  @override
  void redirect(BuildContext context, String url) {
    assert(false, 'Redirects are only supported on the server.');
  }
}

/// Browser implementation of HistoryManager
/// Accesses the window.history api
class HistoryManagerImpl implements HistoryManager {
  @override
  void init(BuildContext context, {void Function(Object? state, {String? url})? onChangeState}) {
    if (onChangeState != null) {
      window.onPopState.listen((event) {
        onChangeState(window.history.state);
      });
    }
  }

  @override
  void push(String url, {String? title, Object? data}) {
    window.history.pushState(data.jsify(), title ?? url, url);
  }

  @override
  void replace(String url, {String? title, Object? data}) {
    window.history.replaceState(data.jsify(), title ?? url, url);
  }

  @override
  void back() {
    window.history.back();
  }
}

class RouteRegistryImpl implements RouteRegistry {
  @override
  Future<void> registerRoutes(List<RouteBase> routes) async {}
}
