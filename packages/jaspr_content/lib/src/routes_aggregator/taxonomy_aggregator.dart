import 'dart:async';

import 'package:jaspr/jaspr.dart';

import '../page.dart';
import '../route_loader/memory_loader.dart';
import '../route_loader/route_loader.dart';
import '../taxonomy.dart';
import 'routes_aggregator.dart';

/// Builder for an individual term page.
///
/// Receives the [BuildContext],
/// the [taxonomy] name (e.g., `'tags'`),
/// and the normalized [term] string (e.g., `'dart'`).
typedef TaxonomyTermPageBuilder = Component Function(BuildContext context, String taxonomy, String term);

/// Provides initial data for each term page.
///
/// Receives the [taxonomy] name and the normalized [term] string.
/// The returned map is merged into the page's initial data
/// under the `'page'` namespace.
typedef TaxonomyTermInitialDataBuilder = Map<String, dynamic> Function(String taxonomy, String term);

/// Builder for the taxonomy index page.
///
/// Receives the [BuildContext] and the [taxonomy] name.
typedef TaxonomyPageBuilder = Component Function(BuildContext context, String taxonomy);

/// Provides initial data for the taxonomy index page.
///
/// Receives the [taxonomy] name.
typedef TaxonomyInitialDataBuilder = Map<String, dynamic> Function(String taxonomy);

class TaxonomyAggregator extends RoutesAggregator {
  /// The frontmatter key to extract terms from
  /// (e.g., `'tags'`, `'categories'`).
  final String taxonomy;

  /// The URL slug for the taxonomy index page.
  ///
  /// Defaults to [taxonomy].
  /// For example, with `taxonomy: 'tags'` and `taxonomySlug: 'labels'`,
  /// the index page is generated at `/labels/` instead of `/tags/`.
  final String? taxonomySlug;

  /// Builder for the taxonomy index page listing all terms.
  final TaxonomyPageBuilder? taxonomyPageBuilder;

  /// Provides initial data for the taxonomy index page.
  final TaxonomyInitialDataBuilder? taxonomyInitialDataBuilder;

  /// The URL slug for individual term pages.
  ///
  /// Defaults to [taxonomy].
  /// For example, with `taxonomy: 'tags'` and `termSlug: 'tag'`,
  /// term pages are generated at `/tag/dart` instead of `/tags/dart`.
  final String? termSlug;

  /// Builder for individual term pages.
  final TaxonomyTermPageBuilder termPageBuilder;

  /// Provides initial data for each term page.
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
  Future<List<PageSource>> loadPageSources() async {
    final previouslyLoadedPages = List<Page>.unmodifiable(RouteLoader.pages);

    return [
      for (final page in createMemoryPages(pages: previouslyLoadedPages))
        MemoryPageSource(page, page.path, this, keepSuffix: page.keepSuffix),
    ];
  }

  /// Generates [MemoryPage]s for each taxonomy term
  /// and optionally an index page for the taxonomy.
  ///
  /// Each generated page has taxonomy metadata injected
  /// into its initial data under the `'page'` namespace
  /// using [TaxonomyUtils.taxonomyKey] and [TaxonomyUtils.termKey].
  /// This metadata is used by [TaxonomyContext]
  /// to identify and filter taxonomy pages.
  @visibleForTesting
  List<MemoryPage> createMemoryPages({required List<Page> pages}) {
    final allTerms = extractTaxonomyTerms(pages: pages, taxonomy: taxonomy);

    return [
      // Taxonomy index page (e.g., /tags/index.html)
      if (taxonomyPageBuilder != null)
        MemoryPage.builder(
          path: TaxonomyUtils.normalize('${taxonomySlug ?? taxonomy}/index.html'),
          initialData: withTaxonomyData(taxonomyInitialDataBuilder?.call(taxonomy), taxonomy: taxonomy),
          builder: (page) => taxonomyPageBuilder!(page, taxonomy),
        ),

      // Individual term pages (e.g., /tags/dart.html)
      for (final term in allTerms)
        MemoryPage.builder(
          path: TaxonomyUtils.normalize('${termSlug ?? taxonomy}/$term.html'),
          initialData: withTaxonomyData(initialTermDataBuilder?.call(taxonomy, term), taxonomy: taxonomy, term: term),
          builder: (page) => termPageBuilder(page, taxonomy, term),
        ),
    ];
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

      // Skip pages that don't match supported extensions
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

  /// Merges taxonomy metadata into the given [data],
  /// ensuring the taxonomy keys are always present
  /// under the `'page'` namespace.
  ///
  /// This performs a shallow merge of the user-provided `'page'` data
  /// with the taxonomy metadata,
  /// with the metadata keys taking precedence.
  @visibleForTesting
  static Map<String, Object?> withTaxonomyData(Map<String, dynamic>? data, {required String taxonomy, String? term}) {
    return <String, Object?>{
      ...?data,
      'page': <String, Object?>{
        if (data?['page'] case final Map<String, dynamic> existing) ...existing,
        TaxonomyUtils.taxonomyKey: taxonomy,
        TaxonomyUtils.termKey: ?term,
      },
    };
  }
}
