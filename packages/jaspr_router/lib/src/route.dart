import 'package:jaspr/jaspr.dart';

import 'path_utils.dart';
import 'typedefs.dart';

abstract class RouteBase {
  const RouteBase._({
    this.routes = const <RouteBase>[],
  });

  /// The list of child routes associated with this route.
  final List<RouteBase> routes;
}

/// A route that is rendered when the provided [path] matches the current URL.
///
/// A route's path can include path parameters by using the `:` symbol followed by a unique name, for example `:userId`.
/// The value of the parameter can then be accessed through the `RouteState` object passed to the `builder` function.
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
        assert(builder != null || redirect != null, 'Route builder or redirect must be provided'),
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

  /// The URL path of this route.
  ///
  /// The path also support path parameters. For a path: `/page/:pageId`, it matches all URLs start with `/page/...`, e.g. `/page/123`, `/page/456` etc.
  /// The parameter values are stored in the `RouteState` that is passed to `builder`.
  final String path;

  /// The name of this route.
  ///
  /// Can be used to navigate to a route without knowing its URL path, by using the `Router.pushNamed()` and its related API.
  final String? name;

  /// The page title for this route.
  ///
  /// This is rendered to the `<title>` element when this route is rendered and override any top-level title set by e.g. the [Document] component.
  final String? title;

  /// The builder of this route.
  final RouterComponentBuilder? builder;

  /// An optional redirect function for this route.
  ///
  /// In the case that you like to make a redirection decision for a specific route (or sub-route), consider using
  /// this parameter over the global redirect function of the [Router].
  final RouterRedirect? redirect;

  // @internal
  final List<String> pathParams = <String>[];

  RegExp get pathRegex => _pathRE;

  late final RegExp _pathRE;
}

/// A route that is rendered lazily and deferred until the [load] future completes.
///
/// [LazyRoute] are supposed to be used with **deferred imports** and provided the `prefix.loadLibrary` future call.
/// This enables splitting up the javascript bundle into separate `.js` files for each route and allows for a faster page load.
class LazyRoute extends Route with LazyRouteBase {
  LazyRoute({
    required super.path,
    super.name,
    super.title,
    super.builder,
    super.redirect,
    required AsyncCallback load,
    super.routes = const <RouteBase>[],
  }) {
    this.load = load;
  }
}

/// A route that displays a UI shell around the matching child route.
class ShellRoute extends RouteBase {
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

  /// The builder for a shell route.
  ///
  ///  Similar to [Route.builder], but with an additional child parameter.
  ///  This child parameter is the component rendering the matching sub-route.
  ///  Typically, a shell route builds its shell around this component.
  final ShellRouteBuilder builder;
}

/// A [ShellRoute] that is lazily loaded like a [LazyRoute].
class LazyShellRoute extends ShellRoute with LazyRouteBase {
  LazyShellRoute({
    required super.builder,
    required AsyncCallback load,
    super.routes,
  }) {
    this.load = load;
  }
}

mixin LazyRouteBase on RouteBase {
  /// Called when the route is matched and defers the rendering until completed.
  late final AsyncCallback load;
}
