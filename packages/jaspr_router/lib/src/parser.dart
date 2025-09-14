// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:developer';

import 'package:jaspr/jaspr.dart';

import 'configuration.dart';
import 'match.dart';
import 'matching.dart';
import 'path_utils.dart';
import 'redirection.dart';

/// Converts between incoming URLs and a [RouteMatchList] using [RouteMatcher].
/// Also performs redirection using [RouteRedirector].
class RouteInformationParser {
  /// Creates a [RouteInformationParser].
  RouteInformationParser({required this.configuration}) : matcher = RouteMatcher(configuration), redirector = redirect;

  /// The route configuration for the app.
  final RouteConfiguration configuration;

  /// The route matcher.
  final RouteMatcher matcher;

  /// The route redirector.
  final RouteRedirector redirector;

  /// Called by the [Router].
  Future<RouteMatchList> parseRouteInformation(String location, BuildContext context, {Object? extra}) {
    late final RouteMatchList initialMatches;
    try {
      initialMatches = matcher.findMatch(location, extra: extra);
    } on MatcherError {
      log('No initial matches: $location');

      // If there is a matching error for the initial location, we should
      // still try to process the top-level redirects.
      initialMatches = RouteMatchList(<RouteMatch>[], Uri.parse(canonicalUri(location)), const <String, String>{});
    }
    Future<RouteMatchList> processRedirectorResult(RouteMatchList matches) {
      if (matches.isEmpty) {
        return SynchronousFuture(
          errorScreen(Uri.parse(location), MatcherError('no routes for location', location).toString()),
        );
      }
      return SynchronousFuture(matches);
    }

    final FutureOr<RouteMatchList> redirectorResult = redirector(
      context,
      initialMatches,
      configuration,
      matcher,
      extra: extra,
    );
    if (redirectorResult is RouteMatchList) {
      return processRedirectorResult(redirectorResult);
    }
    return redirectorResult.then(processRedirectorResult);
  }
}
