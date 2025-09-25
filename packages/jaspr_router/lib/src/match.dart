// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'matching.dart';
import 'path_utils.dart';
import 'route.dart';

///  An instance of a Route plus information about the current location.
class RouteMatch {
  /// Constructor for [RouteMatch].
  RouteMatch({required this.route, required this.subloc, required this.extra, required this.error});

  // ignore: public_member_api_docs
  static RouteMatch? match({
    required RouteBase route,
    required String restLoc, // e.g. person/p1
    required String parentSubloc, // e.g. /family/f2
    required Map<String, String> pathParameters,
    required Object? extra,
  }) {
    if (route is ShellRoute) {
      return RouteMatch(route: route, subloc: restLoc, extra: extra, error: null);
    } else if (route is Route) {
      assert(!route.path.contains('//'));

      final RegExpMatch? match = matchPatternAsPrefix(route, restLoc);
      if (match == null) {
        return null;
      }

      final Map<String, String> encodedParams = extractPathParams(route, match);
      for (final MapEntry<String, String> param in encodedParams.entries) {
        pathParameters[param.key] = Uri.decodeComponent(param.value);
      }
      final String pathLoc = patternToPath(route.path, encodedParams);
      final String subloc = concatenatePaths(parentSubloc, pathLoc);
      return RouteMatch(route: route, subloc: subloc, extra: extra, error: null);
    }
    throw MatcherError('Unexpected route type: $route', restLoc);
  }

  /// The matched route.
  final RouteBase route;

  /// The matched location.
  final String subloc; // e.g. /family/f2

  /// An extra object to pass along with the navigation.
  final Object? extra;

  /// An exception if there was an error during matching.
  final Exception? error;
}
