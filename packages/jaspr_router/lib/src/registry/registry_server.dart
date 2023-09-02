import 'package:jaspr/server.dart';

import '../route.dart';
import 'registry.dart';

class RouteRegistryImpl implements RouteRegistry {
  @override
  void registerRoutes(List<RouteBase> routes) {
    Set<String> paths = {};

    void registerRoute(RouteBase route, String path) {
      if (route is ShellRoute) {
        for (var route in route.routes) {
          registerRoute(route, path);
        }
      } else if (route is Route) {
        var p = path + (path.endsWith('/') || route.path.startsWith('/') ? '' : '/') + route.path;
        assert(route.pathParams.isEmpty,
            'Routes with path parameters are not supported when using static-site generation.');
        paths.add(p);
        for (var route in route.routes) {
          registerRoute(route, p);
        }
      }
    }

    for (var route in routes) {
      registerRoute(route, '');
    }

    for (var path in paths) {
      ServerApp.requestRouteGeneration(path);
    }
  }
}
