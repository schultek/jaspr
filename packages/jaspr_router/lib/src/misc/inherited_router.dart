import 'package:jaspr/jaspr.dart';

import '../router.dart';
import '../state.dart';

/// Router implementation of InheritedComponent.
///
/// Used for to find the current Router in the widget tree. This is useful
/// when routing from anywhere in your app.
class InheritedRouter extends InheritedComponent {
  /// Default constructor for the inherited go router.
  const InheritedRouter({required super.child, required this.router, super.key});

  /// The [RouterState] that is made available to the widget tree.
  final RouterState router;

  @override
  bool updateShouldNotify(covariant InheritedRouter oldComponent) {
    return true;
  }
}

/// RouteState implementation of InheritedComponent.
///
/// Used for to find the current RouteState in the widget tree. This is useful
/// when checking the current route from anywhere in your app.
class InheritedRouteState extends InheritedComponent {
  /// Default constructor for the inherited go router.
  const InheritedRouteState({required super.child, required this.state, super.key});

  /// The [RouteState] that is made available to the widget tree.
  final RouteState state;

  @override
  bool updateShouldNotify(covariant InheritedRouteState oldComponent) {
    return state != oldComponent.state;
  }
}
