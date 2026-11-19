import 'dart:async';

import 'package:jaspr/jaspr.dart';

/// Tracks the loading of a lazy route, such as a `LazyRoute` or `LazyShellRoute`.
///
/// This is internal to the router and not exported,
/// so that its name doesn't clash with `RouteLoader` from `jaspr_content`.
final class LazyRouteLoader {
  /// Starts tracking the [future] returned by the `load` callback of a lazy route.
  LazyRouteLoader.from(this.future) : isPending = true {
    future.whenComplete(() {
      isPending = false;
    });
  }

  /// The future that completes once the route is loaded.
  final Future<void> future;

  /// Whether the route is still loading.
  bool isPending;

  /// Waits for the [loaders] that are still pending,
  /// or completes synchronously if none are.
  static Future<void> wait(Iterable<LazyRouteLoader> loaders) {
    final pendingLoaders = loaders.where((l) => l.isPending).toList(growable: false);
    if (pendingLoaders.isNotEmpty) {
      return [for (final loader in pendingLoaders) loader.future].wait;
    } else {
      return SynchronousFuture(null);
    }
  }
}
