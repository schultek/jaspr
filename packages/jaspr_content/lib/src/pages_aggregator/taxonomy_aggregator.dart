import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart' hide RouteLoader;

import '../aggregated_route.dart';
import '../page.dart';
import '../taxonomy.dart';
import 'pages_aggregator.dart';

/// Builder for an individual term route.
///
/// Receives the [BuildContext],
/// the [taxonomy] name (e.g., `'tags'`),
/// and the normalized [term] string (e.g., `'dart'`).
typedef TaxonomyTermPageBuilder = Component Function(BuildContext context, String taxonomy, String term);

/// Provides initial data for each term route.
///
/// Receives the [taxonomy] name and the normalized [term] string.
/// The returned map is available via [TaxonomyTermRouteInfo.data].
typedef TaxonomyTermInitialDataBuilder = Map<String, dynamic> Function(String taxonomy, String term);

/// Builder for the taxonomy index route.
///
/// Receives the [BuildContext] and the [taxonomy] name.
typedef TaxonomyPageBuilder = Component Function(BuildContext context, String taxonomy);

/// Provides initial data for the taxonomy index route.
///
/// Receives the [taxonomy] name.
/// The returned map is available via [TaxonomyRouteInfo.data].
typedef TaxonomyInitialDataBuilder = Map<String, dynamic> Function(String taxonomy);

/// A [PagesAggregator] that generates taxonomy and term routes from page frontmatter.
///
/// For each unique term found in loaded pages under the [taxonomy] frontmatter key,
/// a route is generated using [termPageBuilder].
/// Optionally, a taxonomy index route is generated using [taxonomyPageBuilder].
///
/// The generated routes and their metadata are accessible via [TaxonomyContext]
/// extensions on [BuildContext].
class TaxonomyAggregator extends PagesAggregator {
  /// The frontmatter key to extract terms from
  /// (e.g., `'tags'`, `'categories'`).
  final String taxonomy;

  /// The URL slug for the taxonomy index route.
  ///
  /// Defaults to [taxonomy].
  /// For example, with `taxonomy: 'tags'` and `taxonomySlug: 'labels'`,
  /// the index route is generated at `/labels` instead of `/tags`.
  final String? taxonomySlug;

  /// Builder for the taxonomy index route listing all terms.
  final TaxonomyPageBuilder? taxonomyPageBuilder;

  /// Provides initial data for the taxonomy index route.
  final TaxonomyInitialDataBuilder? taxonomyInitialDataBuilder;

  /// The URL slug for individual term routes.
  ///
  /// Defaults to [taxonomy].
  /// For example, with `taxonomy: 'tags'` and `termSlug: 'tag'`,
  /// term routes are generated at `/tag/dart` instead of `/tags/dart`.
  final String? termSlug;

  /// Builder for individual term routes.
  final TaxonomyTermPageBuilder termPageBuilder;

  /// Provides initial data for each term route.
  final TaxonomyTermInitialDataBuilder? initialTermDataBuilder;

  /// File extensions to scan for frontmatter.
  ///
  /// Defaults to `['.md', '.html']`.
  final List<String> supportedExtensions;
  static const List<String> _defaultSupportedExtensions = ['.md', '.html'];

  TaxonomyAggregator({
    required this.taxonomy,
    required this.termPageBuilder,
    this.taxonomySlug,
    this.taxonomyPageBuilder,
    this.taxonomyInitialDataBuilder,
    this.termSlug,
    this.initialTermDataBuilder,
    this.supportedExtensions = _defaultSupportedExtensions,
  });

  @override
  Future<List<Route>> aggregatePages(List<Page> pages, List<AggregatedRouteInfo> routeInfos) async {
    final allTerms = extractTaxonomyTerms(pages: pages, taxonomy: taxonomy);

    final routes = <Route>[];

    // Taxonomy index route (e.g., /tags)
    if (taxonomyPageBuilder != null) {
      final slug = TaxonomyUtils.normalize(taxonomySlug ?? taxonomy);
      final url = '/$slug';
      final data = taxonomyInitialDataBuilder?.call(taxonomy) ?? const {};
      final ref = TaxonomyRouteInfo(taxonomy: taxonomy, url: url, data: data);
      routeInfos.add(ref);
      routes.add(Route(
        path: url,
        builder: (context, _) => InheritedAggregatedRoute(
          routeInfo: ref,
          child: taxonomyPageBuilder!(context, taxonomy),
        ),
      ));
    }

    // Individual term routes (e.g., /tags/dart)
    for (final term in allTerms) {
      final slug = TaxonomyUtils.normalize(termSlug ?? taxonomy);
      final url = '/$slug/$term';
      final data = initialTermDataBuilder?.call(taxonomy, term) ?? const {};
      final ref = TaxonomyTermRouteInfo(taxonomy: taxonomy, term: term, url: url, data: data);
      routeInfos.add(ref);
      routes.add(Route(
        path: url,
        builder: (context, _) => InheritedAggregatedRoute(
          routeInfo: ref,
          child: termPageBuilder(context, taxonomy, term),
        ),
      ));
    }

    return routes;
  }

  /// Extracts all unique taxonomy terms from the provided [pages].
  ///
  /// Iterates through each page's data,
  /// and collects all values from the [taxonomy] field.
  /// Returns a set of normalized term strings.
  @visibleForTesting
  Set<String> extractTaxonomyTerms({required List<Page> pages, required String taxonomy}) {
    final terms = <String>{};

    for (final page in pages) {
      final pageSuffix = page.path.split('.').last;

      // Skip pages that don't match supported extensions.
      if (!supportedExtensions.contains('.$pageSuffix')) {
        continue;
      }

      final pageData = page.data.page;
      final taxonomyList = pageData[taxonomy];

      // If the taxonomy field is a list, extract terms.
      if (taxonomyList is List) {
        for (final term in taxonomyList) {
          terms.add(TaxonomyUtils.normalize(term.toString()));
        }
      }
    }

    return terms;
  }
}
