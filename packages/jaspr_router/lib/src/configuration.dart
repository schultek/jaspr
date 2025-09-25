import 'dart:developer';

import 'package:jaspr/jaspr.dart';

import 'misc/errors.dart';
import 'path_utils.dart';
import 'route.dart';
import 'typedefs.dart';

export 'state.dart';

/// The route configuration for GoRouter configured by the app.
class RouteConfiguration {
  /// Constructs a [RouteConfiguration].
  RouteConfiguration({required this.routes, required this.redirectLimit, required this.topRedirect})
    : assert(_debugCheckPath(routes, true)),
      assert(_debugVerifyNoDuplicatePathParameter(routes, <String, Route>{})) {
    _cacheNameToPath('', routes);
  }

  static bool _debugCheckPath(List<RouteBase> routes, bool isTopLevel) {
    for (final RouteBase route in routes) {
      late bool subRouteIsTopLevel;
      if (route is Route) {
        if (isTopLevel) {
          assert(route.path.startsWith('/'), 'top-level path must start with "/": $route');
        } else {
          assert(
            !route.path.startsWith('/') && !route.path.endsWith('/'),
            'sub-route path may not start or end with /: $route',
          );
        }
        subRouteIsTopLevel = false;
      } else if (route is ShellRoute) {
        subRouteIsTopLevel = isTopLevel;
      }
      _debugCheckPath(route.routes, subRouteIsTopLevel);
    }
    return true;
  }

  static bool _debugVerifyNoDuplicatePathParameter(List<RouteBase> routes, Map<String, Route> usedPathParams) {
    for (final RouteBase route in routes) {
      if (route is! Route) {
        continue;
      }
      for (final String pathParam in route.pathParams) {
        if (usedPathParams.containsKey(pathParam)) {
          final bool sameRoute = usedPathParams[pathParam] == route;
          throw RouterError(
            "duplicate path parameter, '$pathParam' found in ${sameRoute ? '$route' : '${usedPathParams[pathParam]}, and $route'}",
          );
        }
        usedPathParams[pathParam] = route;
      }
      _debugVerifyNoDuplicatePathParameter(route.routes, usedPathParams);
      route.pathParams.forEach(usedPathParams.remove);
    }
    return true;
  }

  /// The list of top level routes used by [GoRouterDelegate].
  final List<RouteBase> routes;

  /// The limit for the number of consecutive redirects.
  final int redirectLimit;

  /// Top level page redirect.
  final RouterRedirect topRedirect;

  final Map<String, String> _nameToPath = <String, String>{};

  /// Looks up the url location by a [GoRoute]'s name.
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
  }) {
    assert(() {
      log(
        'getting location for name: '
        '"$name"'
        '${params.isEmpty ? '' : ', params: $params'}'
        '${queryParams.isEmpty ? '' : ', queryParams: $queryParams'}',
      );
      return true;
    }());
    final String keyName = name.toLowerCase();
    assert(_nameToPath.containsKey(keyName), 'unknown route name: $name');
    final String path = _nameToPath[keyName]!;
    assert(() {
      // Check that all required params are present
      final List<String> paramNames = <String>[];
      patternToRegExp(path, paramNames);
      for (final String paramName in paramNames) {
        assert(params.containsKey(paramName), 'missing param "$paramName" for $path');
      }

      // Check that there are no extra params
      for (final String key in params.keys) {
        assert(paramNames.contains(key), 'unknown param "$key" for $path');
      }
      return true;
    }());
    final Map<String, String> encodedParams = <String, String>{
      for (final MapEntry<String, String> param in params.entries) param.key: Uri.encodeComponent(param.value),
    };
    final String location = patternToPath(path, encodedParams);
    return Uri(path: location, queryParameters: queryParams.isEmpty ? null : queryParams).toString();
  }

  @override
  String toString() {
    return 'RouterConfiguration: $routes';
  }

  /// Returns the full path of [routes].
  ///
  /// Each path is indented based depth of the hierarchy, and its `name`
  /// is also appended if not null
  @visibleForTesting
  String debugKnownRoutes() {
    final StringBuffer sb = StringBuffer();
    sb.writeln('Full paths for routes:');
    _debugFullPathsFor(routes, '', 0, sb);

    if (_nameToPath.isNotEmpty) {
      sb.writeln('known full paths for route names:');
      for (final MapEntry<String, String> e in _nameToPath.entries) {
        sb.writeln('  ${e.key} => ${e.value}');
      }
    }

    return sb.toString();
  }

  void _debugFullPathsFor(List<RouteBase> routes, String parentFullpath, int depth, StringBuffer sb) {
    for (final RouteBase route in routes) {
      if (route is Route) {
        final String fullpath = concatenatePaths(parentFullpath, route.path);
        sb.writeln('  => ${''.padLeft(depth * 2)}$fullpath');
        _debugFullPathsFor(route.routes, fullpath, depth + 1, sb);
      } else if (route is ShellRoute) {
        _debugFullPathsFor(route.routes, parentFullpath, depth, sb);
      }
    }
  }

  void _cacheNameToPath(String parentFullPath, List<RouteBase> childRoutes) {
    for (final RouteBase route in childRoutes) {
      if (route is Route) {
        final String fullPath = concatenatePaths(parentFullPath, route.path);

        if (route.name != null) {
          final String name = route.name!.toLowerCase();
          assert(
            !_nameToPath.containsKey(name),
            'duplication fullpaths for name '
            '"$name":${_nameToPath[name]}, $fullPath',
          );
          _nameToPath[name] = fullPath;
        }

        if (route.routes.isNotEmpty) {
          _cacheNameToPath(fullPath, route.routes);
        }
      } else if (route is ShellRoute) {
        if (route.routes.isNotEmpty) {
          _cacheNameToPath(parentFullPath, route.routes);
        }
      }
    }
  }
}
