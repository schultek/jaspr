// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:jaspr/jaspr.dart';

import '../router.dart';

/// Dart extension to add navigation function to a BuildContext object, e.g.
/// context.push('/');
extension GoRouterHelper on BuildContext {
  /// Pushes a new route onto the history stack.
  ///
  /// The [extra] parameter can be used to provide additional data with navigation. It will go through serialization
  /// when it is stored in the browser and must be a primitive serializable value.
  ///
  /// See also:
  /// * [replace] which replaces the history entry with the new route.
  Future<void> push(String location, {Object? extra}) => Router.of(this).push(location, extra: extra);

  /// Pushes a named route onto the history stack.
  ///
  /// Optional parameters can be provided to the named route, like `params: {'userId': '123'}` as well as [queryParams].
  /// The [extra] parameter can be used to provide additional data with navigation. It will go through serialization
  /// when it is stored in the browser and must be a primitive serializable value.
  ///
  /// See also:
  /// * [replaceNamed] which replaces the history entry with the named route.
  Future<void> pushNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) => Router.of(this).pushNamed(name, params: params, queryParams: queryParams, extra: extra);

  /// Replaces the current history entry with a new route.
  ///
  /// The [extra] parameter can be used to provide additional data with navigation. It will go through serialization
  /// when it is stored in the browser and must be a primitive serializable value.
  ///
  /// See also:
  /// * [push] which pushes the route to the history stack.
  void replace(String location, {Object? extra}) => Router.of(this).replace(location, extra: extra);

  /// Replaces the current history entry with a named route.
  ///
  /// Optional parameters can be provided to the named route, like `params: {'userId': '123'}` as well as [queryParams].
  /// The [extra] parameter can be used to provide additional data with navigation. It will go through serialization
  /// when it is stored in the browser and must be a primitive serializable value.
  ///
  /// See also:
  /// * [pushNamed] which pushes a named route onto the history stack.
  void replaceNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) => Router.of(this).replaceNamed(name, params: params, queryParams: queryParams, extra: extra);

  /// Triggers the browsers back navigation.
  void back() => Router.of(this).back();

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  ///
  /// Optional parameters can be provided to the named route, like `params: {'userId': '123'}` as well as [queryParams].
  String namedLocation(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
  }) {
    return Router.of(this).namedLocation(name, params: params, queryParams: queryParams);
  }
}
