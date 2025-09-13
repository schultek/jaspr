// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:jaspr/jaspr.dart';

import 'configuration.dart';
import 'match.dart';
import 'path_utils.dart';
import 'route.dart';

/// Converts a location into a list of [RouteMatch] objects.
class RouteMatcher {
  /// [RouteMatcher] constructor.
  RouteMatcher(this.configuration);

  /// The route configuration.
  final RouteConfiguration configuration;

  /// Finds the routes that matched the given URL.
  RouteMatchList findMatch(String location, {Object? extra}) {
    final Uri uri = Uri.parse(canonicalUri(location));

    final Map<String, String> pathParameters = <String, String>{};
    final List<RouteMatch> matches = _getLocRouteMatches(uri, extra, pathParameters);
    return RouteMatchList(matches, uri, pathParameters);
  }

  List<RouteMatch> _getLocRouteMatches(Uri uri, Object? extra, Map<String, String> pathParameters) {
    final List<RouteMatch>? result = _getLocRouteRecursively(
      loc: uri.path,
      restLoc: uri.path,
      routes: configuration.routes,
      parentSubloc: '',
      pathParameters: pathParameters,
      extra: extra,
    );

    if (result == null) {
      throw MatcherError('no routes for location', uri.toString());
    }

    return result;
  }
}

/// The list of [RouteMatch] objects.
///
/// This corresponds to the GoRouter's history.
class RouteMatchList {
  /// RouteMatchList constructor.
  RouteMatchList(List<RouteMatch> matches, this.uri, this.pathParameters)
    : _matches = matches,
      fullpath = _generateFullPath(matches);

  /// Constructs an empty matches object.
  static RouteMatchList empty = RouteMatchList(<RouteMatch>[], Uri.parse(''), const <String, String>{});

  /// Generates the full path (ex: `'/family/:fid/person/:pid'`) of a list of
  /// [RouteMatch].
  ///
  /// This methods considers that [matches]'s elements verify the go route
  /// structure given to `Router`. For example, if the routes structure is
  ///
  /// ```dart
  /// Route(
  ///   path: '/a',
  ///   routes: [
  ///     Route(
  ///       path: 'b',
  ///       routes: [
  ///         Route(
  ///           path: 'c',
  ///         ),
  ///       ],
  ///     ),
  ///   ],
  /// ),
  /// ```
  ///
  /// The [matches] must be the in same order of how Routes are matched.
  ///
  /// ```dart
  /// [RouteMatchA(), RouteMatchB(), RouteMatchC()]
  /// ```
  static String _generateFullPath(Iterable<RouteMatch> matches) {
    final StringBuffer buffer = StringBuffer();
    bool addsSlash = false;
    for (final RouteMatch match in matches) {
      final RouteBase route = match.route;
      if (route is Route) {
        if (addsSlash) {
          buffer.write('/');
        }
        buffer.write(route.path);
        addsSlash = addsSlash || route.path != '/';
      }
    }
    return buffer.toString();
  }

  final List<RouteMatch> _matches;

  /// the full path pattern that matches the uri.
  ///
  /// For example:
  ///
  /// ```dart
  /// '/family/:fid/person/:pid'
  /// ```
  final String fullpath;

  /// Parameters for the matched route, URI-encoded.
  final Map<String, String> pathParameters;

  /// The uri of the current match.
  final Uri uri;

  /// Returns true if there are no matches.
  bool get isEmpty => _matches.isEmpty;

  /// Returns true if there are matches.
  bool get isNotEmpty => _matches.isNotEmpty;

  /// An optional object provided by the app during navigation.
  Object? get extra => _matches.isEmpty ? null : _matches.last.extra;

  /// The last matching route.
  RouteMatch get last => _matches.last;

  // Returns the title of the deepest matching route
  String? get title {
    return _matches.reversed.fold(null, (String? t, RouteMatch r) {
      return t ?? (r.route is Route ? (r.route as Route).title : null);
    });
  }

  /// The route matches.
  List<RouteMatch> get matches => _matches;

  /// Returns true if the current match intends to display an error screen.
  bool get isError => matches.length == 1 && matches.first.error != null;

  /// Returns the error that this match intends to display.
  Exception? get error => matches.first.error;

  @override
  String toString() {
    return '${objectRuntimeType(this, 'RouteMatchList')}($fullpath)';
  }
}

/// An error that occurred during matching.
class MatcherError extends Error {
  /// Constructs a [MatcherError].
  MatcherError(String message, this.location) : message = '$message: $location';

  /// The error message.
  final String message;

  /// The location that failed to match.
  final String location;

  @override
  String toString() {
    return message;
  }
}

/// Returns the list of `RouteMatch` corresponding to the given `loc`.
///
/// For example, for a given `loc` `/a/b/c/d`, this function will return the
/// list of [RouteBase] `[GoRouteA(), GoRouterB(), GoRouteC(), GoRouterD()]`.
///
/// - [loc] is the complete URL to match (without the query parameters). For
///   example, for the URL `/a/b?c=0`, [loc] will be `/a/b`.
/// - [restLoc] is the remaining part of the URL to match while [parentSubloc]
///   is the part of the URL that has already been matched. For examples, for
///   the URL `/a/b/c/d`, at some point, [restLoc] would be `/c/d` and
///   [parentSubloc] will be `/a/b`.
/// - [routes] are the possible [RouteBase] to match to [restLoc].
List<RouteMatch>? _getLocRouteRecursively({
  required String loc,
  required String restLoc,
  required String parentSubloc,
  required List<RouteBase> routes,
  required Map<String, String> pathParameters,
  required Object? extra,
}) {
  List<RouteMatch>? result;
  late Map<String, String> subPathParameters;
  // find the set of matches at this level of the tree
  for (final RouteBase route in routes) {
    subPathParameters = <String, String>{};

    final RouteMatch? match = RouteMatch.match(
      route: route,
      restLoc: restLoc,
      parentSubloc: parentSubloc,
      pathParameters: subPathParameters,
      extra: extra,
    );

    if (match == null) {
      continue;
    }

    if (match.route is Route && match.subloc.toLowerCase() == loc.toLowerCase()) {
      // If it is a complete match, then return the matched route
      // NOTE: need a lower case match because subloc is canonicalized to match
      // the path case whereas the location can be of any case and still match
      result = <RouteMatch>[match];
    } else if (route.routes.isEmpty) {
      // If it is partial match but no sub-routes, bail.
      continue;
    } else {
      // Otherwise, recurse
      final String childRestLoc;
      final String newParentSubLoc;
      if (match.route is ShellRoute) {
        childRestLoc = restLoc;
        newParentSubLoc = parentSubloc;
      } else {
        assert(loc.startsWith(match.subloc));
        assert(restLoc.isNotEmpty);

        childRestLoc = loc.substring(match.subloc.length + (match.subloc == '/' ? 0 : 1));
        newParentSubLoc = match.subloc;
      }

      final List<RouteMatch>? subRouteMatch = _getLocRouteRecursively(
        loc: loc,
        restLoc: childRestLoc,
        parentSubloc: newParentSubLoc,
        routes: route.routes,
        pathParameters: subPathParameters,
        extra: extra,
      );

      // If there's no sub-route matches, there is no match for this location
      if (subRouteMatch == null) {
        continue;
      }
      result = <RouteMatch>[match, ...subRouteMatch];
    }
    // Should only reach here if there is a match.
    break;
  }
  if (result != null) {
    pathParameters.addAll(subPathParameters);
  }
  return result;
}

/// The match used when there is an error during parsing.
RouteMatchList errorScreen(Uri uri, String errorMessage) {
  final Exception error = Exception(errorMessage);
  return RouteMatchList(
    <RouteMatch>[
      RouteMatch(
        subloc: uri.path,
        extra: null,
        error: error,
        route: Route(
          path: uri.toString(),
          builder: (BuildContext context, RouteState state) {
            throw UnimplementedError();
          },
        ),
      ),
    ],
    uri,
    const <String, String>{},
  );
}
