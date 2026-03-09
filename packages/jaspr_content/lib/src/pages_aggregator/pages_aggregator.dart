/// Defines the interface for content aggregators.
///
/// Aggregators are called after all pages are loaded. They can analyze all pages
/// (including their frontmatter) and produce additional routes.
library;

import 'package:jaspr_router/jaspr_router.dart' hide RouteLoader;

import '../aggregated_route.dart';
import '../page.dart';

/// Base class for pages aggregators.
///
/// Aggregators analyze loaded pages and produce additional [Route]s.
/// They run after all route loaders have loaded their pages.
///
/// Implement [aggregatePages] to return routes based on the loaded pages.
/// The [routeInfos] list is shared across all aggregators — append your
/// produced [AggregatedRouteInfo]s to it so route builders can capture
/// the fully-populated list via closure.
///
/// [ContentApp] passes the same [routeInfos] list to all aggregators
/// and finishes populating it before any route builder is invoked.
abstract class PagesAggregator {
  /// Produces routes based on the given [pages].
  ///
  /// Called by [ContentApp] after all pages are loaded.
  /// The [pages] list is a read-only view of all loaded pages
  /// from all route loaders.
  ///
  /// Append any produced [AggregatedRouteInfo]s to [routeInfos].
  /// The same list is passed to every aggregator and is fully populated
  /// before any route builder closure is invoked.
  Future<List<Route>> aggregatePages(List<Page> pages, List<AggregatedRouteInfo> routeInfos);
}
