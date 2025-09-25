import 'package:jaspr/server.dart';

import '../route.dart';
import 'platform.dart';

class PlatformRouterImpl implements PlatformRouter {
  @override
  final HistoryManager history = HistoryManagerImpl();

  @override
  final RouteRegistry registry = RouteRegistryImpl();
}

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
  void init(BuildContext context, {void Function(Object? state, {String? url})? onChangeState}) {
    // No-op
  }
}

class RouteRegistryImpl implements RouteRegistry {
  @override
  Future<void> registerRoutes(List<RouteBase> routes) async {
    Map<String, RouteSettings?> paths = {};

    void registerRoute(RouteBase route, String path) {
      if (route is ShellRoute) {
        for (var route in route.routes) {
          registerRoute(route, path);
        }
      } else if (route is Route) {
        var p = path + (path.endsWith('/') || route.path.startsWith('/') ? '' : '/') + route.path;
        assert(
          route.pathParams.isEmpty,
          'Routes with path parameters are not supported when using static-site generation.',
        );
        paths[p] = route.settings;
        for (var route in route.routes) {
          registerRoute(route, p);
        }
      }
    }

    for (var route in routes) {
      registerRoute(route, '');
    }

    for (var path in paths.entries) {
      await ServerApp.requestRouteGeneration(
        path.key,
        lastMod: path.value?.lastMod?.toIso8601String(),
        changefreq: path.value?.changeFreq?.name,
        priority: path.value?.priority,
      );
    }
  }
}
