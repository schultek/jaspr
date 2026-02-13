/// Defines the interface for content aggregators.
///
/// Aggregators are called after all pages are loaded. They can analyze all pages
/// (including their frontmatter) and produce additional pages/routes.
///
/// Aggregators are processed sequentially. Each aggregator's produced pages are
/// loaded before the next aggregator runs, so subsequent aggregators can see
/// pages produced by previous ones.
library;

import 'dart:async';

import '../page.dart';
import '../route_loader/memory_loader.dart';
import '../route_loader/route_loader.dart';

/// Base class for content aggregators.
///
/// Aggregators analyze loaded pages and produce additional pages/routes.
/// Implement [aggregate] to return pages that should be added to the site.
abstract class RoutesAggregator extends RouteLoaderBase {
  /// Called after all pages/routes are loaded (including those from previous aggregators).
  ///
  /// [pages] is the current list of all loaded pages (read-only view of RouteLoader._pages).
  /// Return a result containing [MemoryPage]s to be added and optionally a [ConfigResolver].
  @override
  Future<List<PageSource>> loadPageSources();
}
