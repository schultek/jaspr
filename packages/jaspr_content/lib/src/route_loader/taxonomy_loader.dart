import 'dart:io';

import 'package:fbh_front_matter/fbh_front_matter.dart' as fm;
import 'package:jaspr/jaspr.dart';

import '../taxonomy.dart';
import 'memory_loader.dart';
import 'route_loader.dart';

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

/// A route loader that generates taxonomy pages
/// from content frontmatter.
///
/// A taxonomy is a classification system for content.
/// For example, a blog might use "tags" or "categories" as taxonomies.
/// Each unique value within a taxonomy is called a "term"
/// (e.g., "dart", "flutter" are terms of the "tags" taxonomy).
///
/// This loader scans content files in the given [directory]
/// for a frontmatter field matching [taxonomy],
/// extracts all unique terms, and generates:
/// - A page for each term (using [termPageBuilder]).
/// - Optionally, an index page for the taxonomy
///   (using [taxonomyPageBuilder]).
///
/// Terms are normalized to lowercase with spaces replaced by dashes
/// (e.g., "My Tag" becomes "my-tag").
///
/// Use the [TaxonomyContext] extension on `BuildContext`
/// to query taxonomy data from within component builders.
///
/// ```dart
/// // Given content/post.md with frontmatter:
/// // ---
/// // title: My Post
/// // tags: [Dart, Flutter]
/// // ---
///
/// TaxonomyLoader(
///   taxonomy: 'tags',
///   directory: 'content',
///   // Builds a page for each term (e.g., /tags/dart).
///   termPageBuilder: (context, taxonomy, term) {
///     final posts = context.pagesForTerm(taxonomy, term);
///     return ul([for (final post in posts) li([text(post.url)])]);
///   },
///   // Builds an index page listing all terms (e.g., /tags/).
///   taxonomyPageBuilder: (context, taxonomy) {
///     final terms = context.taxonomyTermPagesWithCount(taxonomy);
///     return ul([
///       for (final MapEntry(:key, :value) in terms.entries)
///         li([a(href: key.url, [text('${key.taxonomyTerm} ($value)')])])
///     ]);
///   },
/// )
/// ```
class TaxonomyLoader extends RouteLoaderBase {
  /// The directory to scan for content files with frontmatter.
  ///
  /// Defaults to `'content'`.
  final String directory;

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

  TaxonomyLoader({
    required this.taxonomy,
    required this.termPageBuilder,
    this.directory = 'content',
    this.taxonomySlug,
    this.taxonomyPageBuilder,
    this.taxonomyInitialDataBuilder,
    this.termSlug,
    this.initialTermDataBuilder,
    this.supportedExtensions = _defaultSupportedExtensions,
  });

  @override
  Future<List<PageSource>> loadPageSources() async {
    return [
      for (final page in createMemoryPages())
        MemoryPageSource(
          page,
          page.path,
          this,
          keepSuffix: page.keepSuffix,
        ),
    ];
  }

  /// Extracts all unique taxonomy terms from content files in [directory].
  ///
  /// Recursively scans for files matching [supportedExtensions],
  /// parses their frontmatter,
  /// and collects all values from the [taxonomy] field.
  /// Returns a set of normalized term strings.
  @visibleForTesting
  Set<String> extractTaxonomyTerms({required String directory, required String taxonomy}) {
    final taxonomyTerms = <String>{};
    final dir = Directory(directory);

    if (!dir.existsSync()) return taxonomyTerms;

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && supportedExtensions.any((ext) => entity.path.endsWith(ext))) {
        final content = entity.readAsStringSync();
        try {
          final document = fm.parse(content);
          final data = document.data;
          if (data[taxonomy] is List) {
            for (final term in data[taxonomy] as List) {
              taxonomyTerms.add(TaxonomyUtils.normalize(term.toString()));
            }
          }
        } catch (_) {
          // Ignore parsing errors
        }
      }
    }

    return taxonomyTerms;
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
  List<MemoryPage> createMemoryPages() {
    final allTerms = extractTaxonomyTerms(directory: directory, taxonomy: taxonomy);

    return [
      // Taxonomy index page (e.g., /tags/index.html)
      if (taxonomyPageBuilder != null)
        MemoryPage.builder(
          path: TaxonomyUtils.normalize('${taxonomySlug ?? taxonomy}/index.html'),
          initialData: withTaxonomyData(
            taxonomyInitialDataBuilder?.call(taxonomy),
            taxonomy: taxonomy,
          ),
          builder: (page) => taxonomyPageBuilder!(page, taxonomy),
        ),

      // Individual term pages (e.g., /tags/dart.html)
      for (final term in allTerms)
        MemoryPage.builder(
          path: TaxonomyUtils.normalize('${termSlug ?? taxonomy}/$term.html'),
          initialData: withTaxonomyData(
            initialTermDataBuilder?.call(taxonomy, term),
            taxonomy: taxonomy,
            term: term,
          ),
          builder: (page) => termPageBuilder(page, taxonomy, term),
        ),
    ];
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
