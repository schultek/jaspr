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
  RouteBuilder({required this.configuration, required this.errorBuilder});

  /// Error widget builder for the router delegate.
  final RouterComponentBuilder? errorBuilder;

  /// The route configuration for the app.
  final RouteConfiguration configuration;

  /// Builds the top-level Navigator for the given [RouteMatchList].
  Component build(RouterState router) {
    if (router.matchList.isEmpty) {
      // The build method can be called before async redirect finishes. Build an
      // empty text until then.
      return Component.text('');
    }

    return InheritedRouter(router: router, child: _buildRoute(router.matchList, router.routeLoaders));
  }

  Component _buildRoute(RouteMatchList matchList, Map<Object, RouteLoader> loaders) {
    try {
      return _buildRecursive(matchList, 0, loaders);
    } on _RouteBuilderError catch (e) {
      return _buildErrorPage(e, matchList.uri);
    }
  }

  Component _buildRecursive(RouteMatchList matchList, int startIndex, Map<Object, RouteLoader> loaders) {
    final RouteMatch match = matchList.matches[startIndex];

    if (match.error != null) {
      throw _RouteBuilderError('Match error found during build phase', exception: match.error);
    }

    final RouteBase route = match.route;
    final RouteState state = buildState(matchList, match);
    if (route is Route) {
      if (matchList.matches.length > startIndex + 1) {
        return _buildRecursive(matchList, startIndex + 1, loaders);
      }

      return _callRouteBuilder(state, route, loaders);
    } else if (route is ShellRoute) {
      final child = _buildRecursive(matchList, startIndex + 1, loaders);

      return _callShellRouteBuilder(state, route, loaders, child: child);
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
  Component _callRouteBuilder(RouteState state, Route route, Map<Object, RouteLoader> loaders) {
    final RouterComponentBuilder? builder = route.builder;

    if (builder == null) {
      throw _RouteBuilderError('No routeBuilder provided to Route: $route');
    }

    Component child = Builder(builder: (c) => builder(c, state));

    if (route is LazyRoute) {
      final l = loaders[state.subloc] ??= RouteLoader.from(route.load());

      if (l.isPending) {
        final c = child;
        child = FutureBuilder(
          future: l.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Component.text('');
            }
            if (snapshot.hasError) {
              return _buildErrorPage(_RouteBuilderError('Failed to load lazy route'), Uri.parse(state.location));
            }
            return c;
          },
        );
      }
    }

    return InheritedRouteState(state: state, child: child);
  }

  /// Calls the user-provided route builder from the [RouteMatch]'s [RouteBase].
  Component _callShellRouteBuilder(
    RouteState state,
    ShellRoute route,
    Map<Object, RouteLoader> loaders, {
    required Component child,
  }) {
    final ShellRouteBuilder builder = route.builder;

    Component routeChild = Builder(builder: (c) => builder(c, state, child));

    if (route is LazyShellRoute) {
      final l = loaders[state.subloc] ??= RouteLoader.from(route.load());
      if (l.isPending) {
        final c = routeChild;
        routeChild = FutureBuilder(
          future: l.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Component.text('');
            }
            if (snapshot.hasError) {
              return _buildErrorPage(_RouteBuilderError('Failed to load lazy shell route'), Uri.parse(state.location));
            }
            return c;
          },
        );
      }
    }

    return InheritedRouteState(state: state, child: routeChild);
  }

  /// Builds a an error page.
  Component _buildErrorPage(_RouteBuilderError error, Uri uri) {
    final RouteState state = RouteState(
      location: uri.toString(),
      subloc: uri.path,
      name: null,
      queryParams: uri.queryParameters,
      queryParametersAll: uri.queryParametersAll,
      error: Exception(error),
    );

    if (errorBuilder != null) {
      return Builder(builder: (context) => errorBuilder!(context, state));
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
  //ignore: unused_element, unused_element_parameter
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
