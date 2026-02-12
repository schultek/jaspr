import 'package:jaspr/server.dart';

import 'page.dart';

/// Context extensions to access taxonomy data
/// in a component's build method.
///
/// These extensions require eager loading to be enabled,
/// as they depend on [PageContext.pages] being fully populated.
///
/// ```dart
/// // Get all tag term pages.
/// final tagPages = context.taxonomyTermPages('tags');
///
/// // Get a specific term page.
/// final dartPage = context.taxonomyTermPage('tags', 'dart');
///
/// // Get blog posts tagged "dart".
/// final dartPosts = context.pagesForTerm('tags', 'dart');
///
/// // Build a tag cloud with counts.
/// final tagCloud = context.taxonomyTermPagesWithCount('tags');
/// for (final MapEntry(:key, :value) in tagCloud.entries) {
///   print('${key.taxonomyTerm}: $value posts');
/// }
/// ```
extension TaxonomyContext on BuildContext {
  /// Returns all term pages for the given [taxonomy].
  ///
  /// Each returned page is a term page
  /// created by a [TaxonomyLoader].
  /// The taxonomy index page is excluded.
  List<Page> taxonomyTermPages(String taxonomy) {
    if (kIsWeb) {
      throw UnsupportedError(
        'context.taxonomyTermPages() is not supported on the client and only allowed to be called on the server.\n'
        'Wrap the call with a !kIsWeb check or move it out of any client component.',
      );
    }

    return pages.where((p) {
      final pageData = p.data.page;
      return pageData[TaxonomyUtils.taxonomyKey] == taxonomy && pageData[TaxonomyUtils.termKey] != null;
    }).toList();
  }

  /// Returns the term page for the given [taxonomy] and [term],
  /// or `null` if no such page exists.
  ///
  /// The [term] is normalized before matching,
  /// so both `'Dart'` and `'dart'` will find the same page.
  Page? taxonomyTermPage(String taxonomy, String term) {
    if (kIsWeb) {
      throw UnsupportedError(
        'context.taxonomyTermPage() is not supported on the client and only allowed to be called on the server.\n'
        'Wrap the call with a !kIsWeb check or move it out of any client component.',
      );
    }

    final normalizedTerm = TaxonomyUtils.normalize(term);

    for (final p in pages) {
      final pageData = p.data.page;
      if (pageData[TaxonomyUtils.taxonomyKey] == taxonomy && pageData[TaxonomyUtils.termKey] == normalizedTerm) {
        return p;
      }
    }
    return null;
  }

  /// Returns all content pages that have the given [term]
  /// in their frontmatter [taxonomy] field.
  ///
  /// Scans all pages for a list field matching [taxonomy]
  /// that contains [term] (normalized before matching).
  /// Taxonomy pages themselves are excluded from the results.
  ///
  /// For example, with frontmatter `tags: [Dart, Flutter]`,
  /// calling `pagesForTerm('tags', 'dart')` would match this page.
  List<Page> pagesForTerm(String taxonomy, String term) {
    if (kIsWeb) {
      throw UnsupportedError(
        'context.pagesForTerm() is not supported on the client and only allowed to be called on the server.\n'
        'Wrap the call with a !kIsWeb check or move it out of any client component.',
      );
    }

    final normalizedTerm = TaxonomyUtils.normalize(term);

    return pages.where((p) {
      // Skip taxonomy pages themselves.
      if (p.data.page[TaxonomyUtils.taxonomyKey] != null) return false;
      final terms = p.data.page[taxonomy];
      if (terms is List) {
        return terms.any((t) => TaxonomyUtils.normalize(t.toString()) == normalizedTerm);
      }
      return false;
    }).toList();
  }

  /// Returns a map of term pages to their content page counts
  /// for the given [taxonomy].
  ///
  /// Each key is a term [Page] created by a [TaxonomyLoader],
  /// and each value is the number of content pages
  /// that have that term in their frontmatter.
  ///
  /// Only terms that have a corresponding term page are included.
  /// Use the [TaxonomyPage] extension to access
  /// the term name from each page key.
  ///
  /// ```dart
  /// final tagCloud = context.taxonomyTermPagesWithCount('tags');
  /// for (final MapEntry(:key, :value) in tagCloud.entries) {
  ///   // key is the term Page (e.g., /tags/dart)
  ///   // key.taxonomyTerm is the term name (e.g., 'dart')
  ///   // key.url is the term page URL (e.g., '/tags/dart')
  ///   // value is the count of content pages with that term
  /// }
  /// ```
  Map<Page, int> taxonomyTermPagesWithCount(String taxonomy) {
    if (kIsWeb) {
      throw UnsupportedError(
        'context.taxonomyTermPagesWithCount() is not supported on the client and only allowed to be called on the server.\n'
        'Wrap the call with a !kIsWeb check or move it out of any client component.',
      );
    }

    final termPages = taxonomyTermPages(taxonomy);

    // Count content pages for each term.
    final counts = <String, int>{};
    for (final p in pages) {
      // Skip taxonomy pages themselves.
      if (p.data.page[TaxonomyUtils.taxonomyKey] != null) continue;
      final terms = p.data.page[taxonomy];
      if (terms is List) {
        for (final t in terms) {
          final normalized = TaxonomyUtils.normalize(t.toString());
          counts[normalized] = (counts[normalized] ?? 0) + 1;
        }
      }
    }

    return {
      for (final termPage in termPages) termPage: counts[termPage.data.page[TaxonomyUtils.termKey] as String] ?? 0,
    };
  }
}

/// Extension to access taxonomy metadata
/// from a [Page] created by a [TaxonomyLoader].
///
/// Returns `null` for pages that are not taxonomy pages.
///
/// ```dart
/// final termPages = context.taxonomyTermPages('tags');
/// for (final page in termPages) {
///   print('${page.taxonomy}: ${page.taxonomyTerm}');
///   // Output: tags: dart, tags: flutter, ...
/// }
/// ```
extension TaxonomyPage on Page {
  /// Returns the taxonomy name for this page,
  /// or `null` if this is not a taxonomy page.
  String? get taxonomy => data.page[TaxonomyUtils.taxonomyKey] as String?;

  /// Returns the term name for this page,
  /// or `null` if this is not a term page.
  String? get taxonomyTerm => data.page[TaxonomyUtils.termKey] as String?;
}

/// Utility constants and functions for taxonomy metadata.
///
/// Used internally by [TaxonomyLoader] to inject metadata
/// and by [TaxonomyContext] to read it.
///
/// Terms are normalized to lowercase with spaces replaced by dashes
/// (e.g., `'My Tag'` becomes `'my-tag'`).
abstract class TaxonomyUtils {
  /// Key used to store the taxonomy name in page data.
  static const taxonomyKey = '_taxonomy';

  /// Key used to store the term name in page data.
  static const termKey = '_term';

  /// Normalizes a taxonomy term value to lowercase with dashes.
  static String normalize(String value) {
    return value.toLowerCase().replaceAll(' ', '-');
  }
}
