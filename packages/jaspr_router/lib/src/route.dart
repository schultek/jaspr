import 'package:jaspr/jaspr.dart';

import 'path_utils.dart';
import 'typedefs.dart';

abstract class RouteBase {
  const RouteBase._({
    this.routes = const <RouteBase>[],
  });

  final List<RouteBase> routes;
}

class Route extends RouteBase {
  Route({
    required this.path,
    this.name,
    this.title,
    this.builder,
    this.redirect,
    super.routes = const <RouteBase>[],
  })  : assert(path.isNotEmpty, 'Route path cannot be empty'),
        assert(name == null || name.isNotEmpty, 'Route name cannot be empty'),
        assert(builder != null || redirect != null, 'builder or redirect must be provided'),
        super._() {
    // cache the path regexp and parameters
    _pathRE = patternToRegExp(path, pathParams);
  }

  factory Route.lazy({
    required String path,
    String? name,
    String? title,
    RouterComponentBuilder? builder,
    RouterRedirect? redirect,
    required AsyncCallback load,
    List<RouteBase> routes,
  }) = LazyRoute;

  final String? name;

  final String path;

  final String? title;

  final RouterComponentBuilder? builder;

  final RouterRedirect? redirect;

  //@internal
  final List<String> pathParams = <String>[];

  RegExp get pathRegex => _pathRE;

  late final RegExp _pathRE;
}

class LazyRoute extends Route with LazyRouteMixin {
  LazyRoute({
    required super.path,
    super.name,
    super.title,
    super.builder,
    super.redirect,
    required this.load,
    super.routes = const <RouteBase>[],
  });

  @override
  final AsyncCallback load;
}

class ShellRoute extends RouteBase {
  /// Constructs a [ShellRoute].
  ShellRoute({
    required this.builder,
    super.routes,
  })  : assert(routes.isNotEmpty),
        super._();

  factory ShellRoute.lazy({
    required ShellRouteBuilder builder,
    required AsyncCallback load,
    List<RouteBase> routes,
  }) = LazyShellRoute;

  final ShellRouteBuilder builder;
}

class LazyShellRoute extends ShellRoute with LazyRouteMixin {
  LazyShellRoute({
    required super.builder,
    required this.load,
    super.routes,
  });

  @override
  final AsyncCallback load;
}

mixin LazyRouteMixin {
  AsyncCallback get load;
}
