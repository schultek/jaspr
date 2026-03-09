/// @docImport 'content_app.dart';
/// @docImport 'pages_aggregator/pages_aggregator.dart';
library;

import 'package:jaspr/jaspr.dart';
import 'package:meta/meta.dart';

import 'page.dart';

/// Base class for route information produced by a [PagesAggregator].
///
/// Aggregators produce [AggregatedRouteInfo] objects alongside [Route]s during
/// [PagesAggregator.aggregatePages]. These are made available via [BuildContext]
/// through [InheritedAggregatedContext] injected by [ContentApp].
abstract class AggregatedRouteInfo {
  const AggregatedRouteInfo({required this.url, this.data = const {}});

  /// The URL of the aggregated route, e.g. `/tags/dart`.
  final String url;

  /// Additional metadata for this route, available to builders via context.
  final Map<String, dynamic> data;
}

/// Inherited component injected by [ContentApp] into the whole component tree.
///
/// Provides global access to all content pages and all aggregated route infos.
/// Use the [TaxonomyContext] extensions on [BuildContext] to access taxonomy data.
@internal
class InheritedAggregatedContext extends InheritedComponent {
  const InheritedAggregatedContext({
    required this.contentPages,
    required this.routeInfos,
    required super.child,
  });

  /// All content pages loaded by route loaders.
  final List<Page> contentPages;

  /// All aggregated route infos produced by all aggregators.
  final List<AggregatedRouteInfo> routeInfos;

  static InheritedAggregatedContext? of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<InheritedAggregatedContext>();

  @override
  bool updateShouldNotify(InheritedAggregatedContext oldComponent) =>
      oldComponent.contentPages != contentPages || oldComponent.routeInfos != routeInfos;
}

/// Inherited component injected by [PagesAggregator] route builders.
///
/// Provides the current aggregated route's info within an individual route.
/// Access via [BuildContext.currentRouteInfo].
@internal
class InheritedAggregatedRoute extends InheritedComponent {
  const InheritedAggregatedRoute({
    required this.routeInfo,
    required super.child,
  });

  /// The route info for the current aggregated route.
  final AggregatedRouteInfo routeInfo;

  static InheritedAggregatedRoute? of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<InheritedAggregatedRoute>();

  @override
  bool updateShouldNotify(InheritedAggregatedRoute oldComponent) =>
      oldComponent.routeInfo != routeInfo;
}

/// Context extensions for accessing aggregated route data.
extension AggregatedRouteContext on BuildContext {
  /// Returns the [AggregatedRouteInfo] for the current aggregated route cast to [T], or null.
  ///
  /// Available inside route builders created by [PagesAggregator]s.
  ///
  /// ```dart
  /// final termRef = context.currentRouteInfo<TaxonomyTermRouteInfo>();
  /// ```
  T? currentRouteInfo<T extends AggregatedRouteInfo>() {
    final info = InheritedAggregatedRoute.of(this)?.routeInfo;
    return info is T ? info : null;
  }
}
