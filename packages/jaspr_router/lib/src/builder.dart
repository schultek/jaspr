// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:jaspr/jaspr.dart';

import 'configuration.dart';
import 'match.dart';
import 'matching.dart';
import 'misc/error_screen.dart';
import 'misc/inherited_router.dart';
import 'route.dart';
import 'router.dart';
import 'typedefs.dart';

/// Builds the top-level Navigator for GoRouter.
class RouteBuilder {
  /// [RouteBuilder] constructor.
  RouteBuilder({
    required this.configuration,
    required this.errorBuilder,
  });

  /// Error widget builder for the router delegate.
  final RouterComponentBuilder? errorBuilder;

  /// The route configuration for the app.
  final RouteConfiguration configuration;

  /// Builds the top-level Navigator for the given [RouteMatchList].
  Iterable<Component> build(
    BuildContext context,
    RouterState router,
  ) sync* {
    if (router.matchList.isEmpty) {
      // The build method can be called before async redirect finishes. Build a
      // empty box until then.
      return;
    }

    yield InheritedRouter(
      router: router,
      child: Builder.single(builder: (context) {
        return _buildRoute(context, router.matchList, router.routeLoaders);
      }),
    );
  }

  Component _buildRoute(BuildContext context, RouteMatchList matchList, Map<Object, Future> loaders) {
    try {
      return _buildRecursive(context, matchList, 0, loaders);
    } on _RouteBuilderError catch (e) {
      return _buildErrorPage(context, e, matchList.uri);
    }
  }

  Component _buildRecursive(
    BuildContext context,
    RouteMatchList matchList,
    int startIndex,
    Map<Object, Future> loaders,
  ) {
    final RouteMatch match = matchList.matches[startIndex];

    if (match.error != null) {
      throw _RouteBuilderError('Match error found during build phase', exception: match.error);
    }

    final RouteBase route = match.route;
    final RouteState state = buildState(matchList, match);
    if (route is Route) {
      if (matchList.matches.length > startIndex + 1) {
        return _buildRecursive(context, matchList, startIndex + 1, loaders);
      }

      return _callRouteBuilder(context, state, route, loaders);
    } else if (route is ShellRoute) {
      var child = _buildRecursive(context, matchList, startIndex + 1, loaders);

      return _callShellRouteBuilder(context, state, route, loaders, child: child);
    }

    throw _RouteBuilderException('Unsupported route type $route');
  }

  /// Helper method that builds a [GoRouterState] object for the given [match]
  /// and [params].
  @visibleForTesting
  RouteState buildState(RouteMatchList matchList, RouteMatch match) {
    final RouteBase route = match.route;
    String? name;
    String path = '';
    if (route is Route) {
      name = route.name;
      path = route.path;
    }
    return RouteState(
      location: matchList.uri.toString(),
      subloc: match.subloc,
      name: name,
      path: path,
      fullpath: matchList.fullpath,
      params: Map<String, String>.from(matchList.pathParameters),
      error: match.error,
      queryParams: matchList.uri.queryParameters,
      queryParametersAll: matchList.uri.queryParametersAll,
      extra: match.extra,
    );
  }

  /// Calls the user-provided route builder from the [RouteMatch]'s [RouteBase].
  Component _callRouteBuilder(BuildContext context, RouteState state, Route route, Map<Object, Future> loaders) {
    final RouterComponentBuilder? builder = route.builder;

    if (builder == null) {
      throw _RouteBuilderError('No routeBuilder provided to Route: $route');
    }

    Component child = Builder.single(builder: (c) => builder(c, state));

    if (route is LazyRoute) {
      var l = loaders[state.subloc] ??= route.load();
      var c = child;
      print("BUILD LAZY");
      child = FutureBuilder(
        future: l,
        builder: (context, snapshot) sync* {
          print("FUTURE LAZY ${snapshot.connectionState}");
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              yield _buildErrorPage(
                context,
                _RouteBuilderError('Failed to load lazy route'),
                Uri.parse(state.location),
              );
              return;
            }
            yield c;
          }
        },
      );
    }

    return InheritedRouteState(
      state: state,
      child: child,
    );
  }

  /// Calls the user-provided route builder from the [RouteMatch]'s [RouteBase].
  Component _callShellRouteBuilder(
      BuildContext context, RouteState state, ShellRoute route, Map<Object, Future> loaders,
      {required Component child}) {
    final ShellRouteBuilder builder = route.builder;

    Component routeChild = Builder.single(builder: (c) => builder(c, state, child));

    if (route is LazyShellRoute) {
      var l = loaders[state.subloc] ??= route.load();
      var c = routeChild;
      routeChild = FutureBuilder(
        future: l,
        builder: (context, snapshot) sync* {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              yield _buildErrorPage(
                context,
                _RouteBuilderError('Failed to load lazy shell route'),
                Uri.parse(state.location),
              );
              return;
            }
            yield c;
          }
        },
      );
    }

    return InheritedRouteState(
      state: state,
      child: routeChild,
    );
  }

  /// Builds a an error page.
  Component _buildErrorPage(
    BuildContext context,
    _RouteBuilderError error,
    Uri uri,
  ) {
    final RouteState state = RouteState(
      location: uri.toString(),
      subloc: uri.path,
      name: null,
      queryParams: uri.queryParameters,
      queryParametersAll: uri.queryParametersAll,
      error: Exception(error),
    );

    if (errorBuilder != null) {
      return errorBuilder!(context, state);
    } else {
      return ErrorScreen(state.error);
    }
  }
}

/// An error that occurred while building the app's UI based on the route
/// matches.
class _RouteBuilderError extends Error {
  /// Constructs a [_RouteBuilderError].
  _RouteBuilderError(this.message, {this.exception});

  /// The error message.
  final String message;

  /// The exception that occurred.
  final Exception? exception;

  @override
  String toString() {
    return '$message ${exception ?? ""}';
  }
}

/// An error that occurred while building the app's UI based on the route
/// matches.
class _RouteBuilderException implements Exception {
  /// Constructs a [_RouteBuilderException].
  //ignore: unused_element
  _RouteBuilderException(this.message, {this.exception});

  /// The error message.
  final String message;

  /// The exception that occurred.
  final Exception? exception;

  @override
  String toString() {
    return '$message ${exception ?? ""}';
  }
}
