import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:test/test.dart';

import '../utils.dart';

Page _makePageWithTags(List<String> tags, {String? path}) {
  return Page(
    path: path ?? 'posts/test.md',
    url: '/posts/test',
    content: '',
    initialData: {
      'page': {'tags': tags},
    },
    config: PageConfig(),
    loader: MockRouteLoader(),
  );
}

Page _makePage({String path = 'test.md', Map<String, Object?> initialData = const {}}) {
  return Page(
    path: path,
    url: '/test',
    content: '',
    initialData: initialData,
    config: PageConfig(),
    loader: MockRouteLoader(),
  );
}

void main() {
  group('TaxonomyAggregator', () {
    group('extractTaxonomyTerms()', () {
      test('extracts terms from loaded pages', () {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = [
          _makePage(initialData: {
            'page': {'tags': ['dart', 'flutter']},
          }),
          _makePage(path: 'test2.md', initialData: {
            'page': {'tags': ['dart', 'jaspr']},
          }),
        ];

        final terms = aggregator.extractTaxonomyTerms(pages: pages, taxonomy: 'tags');
        expect(terms, unorderedEquals({'dart', 'flutter', 'jaspr'}));
      });

      test('normalizes terms to lowercase with dashes', () {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = [
          _makePage(initialData: {
            'page': {'tags': ['My Tag', 'Hello World']},
          }),
        ];

        final terms = aggregator.extractTaxonomyTerms(pages: pages, taxonomy: 'tags');
        expect(terms, unorderedEquals({'my-tag', 'hello-world'}));
      });

      test('returns empty set when no pages have the taxonomy field', () {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = [
          _makePage(initialData: {'page': {'title': 'No Tags'}}),
        ];

        final terms = aggregator.extractTaxonomyTerms(pages: pages, taxonomy: 'tags');
        expect(terms, isEmpty);
      });

      test('deduplicates terms across pages', () {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = [
          _makePage(initialData: {'page': {'tags': ['dart']}}),
          _makePage(path: 'test2.md', initialData: {'page': {'tags': ['dart']}}),
        ];

        final terms = aggregator.extractTaxonomyTerms(pages: pages, taxonomy: 'tags');
        expect(terms, equals({'dart'}));
      });

      test('ignores non-list taxonomy field values', () {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = [
          _makePage(initialData: {'page': {'tags': 'just-a-string'}}),
        ];

        final terms = aggregator.extractTaxonomyTerms(pages: pages, taxonomy: 'tags');
        expect(terms, isEmpty);
      });

      test('respects custom supportedExtensions', () {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termPageBuilder: (_, _, _) => Component.text(''),
          supportedExtensions: ['.md'],
        );

        final pages = [
          _makePage(path: 'test.md', initialData: {'page': {'tags': ['from-md']}}),
          _makePage(path: 'test.html', initialData: {'page': {'tags': ['from-html']}}),
        ];

        final terms = aggregator.extractTaxonomyTerms(pages: pages, taxonomy: 'tags');
        expect(terms, contains('from-md'));
        expect(terms, isNot(contains('from-html')));
      });
    });

    group('aggregatePages()', () {
      test('returns a Route for each term', () async {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = [_makePageWithTags(['dart', 'flutter'])];
        final routes = await aggregator.aggregatePages(pages, []);

        expect(routes, hasLength(2));
        expect(routes.map((r) => r.path), unorderedEquals(['/tags/dart', '/tags/flutter']));
      });

      test('creates taxonomy index route when taxonomyPageBuilder is provided', () async {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termPageBuilder: (_, _, _) => Component.text(''),
          taxonomyPageBuilder: (_, _) => Component.text(''),
        );

        final pages = [_makePageWithTags(['dart'])];
        final routes = await aggregator.aggregatePages(pages, []);

        // 1 index + 1 term
        expect(routes, hasLength(2));
        expect(routes.any((r) => r.path == '/tags'), isTrue);
      });

      test('does not create index route when taxonomyPageBuilder is null', () async {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = [_makePageWithTags(['dart'])];
        final routes = await aggregator.aggregatePages(pages, []);

        expect(routes.any((r) => r.path == '/tags'), isFalse);
      });

      test('uses custom taxonomySlug for index route path', () async {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          taxonomySlug: 'labels',
          termPageBuilder: (_, _, _) => Component.text(''),
          taxonomyPageBuilder: (_, _) => Component.text(''),
        );

        final pages = [_makePageWithTags(['dart'])];
        final routes = await aggregator.aggregatePages(pages, []);

        expect(routes.any((r) => r.path == '/labels'), isTrue);
        expect(routes.any((r) => r.path == '/tags'), isFalse);
      });

      test('uses custom termSlug for term route paths', () async {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termSlug: 'label',
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = [_makePageWithTags(['dart'])];
        final routes = await aggregator.aggregatePages(pages, []);

        expect(routes.any((r) => r.path == '/label/dart'), isTrue);
        expect(routes.any((r) => r.path.startsWith('/tags')), isFalse);
      });

      test('creates no routes when no terms are found', () async {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final routes = await aggregator.aggregatePages([], []);
        expect(routes, isEmpty);
      });

      test('populates routeInfos after aggregatePages', () async {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = [_makePageWithTags(['dart', 'flutter'])];
        final routeInfos = <AggregatedRouteInfo>[];
        await aggregator.aggregatePages(pages, routeInfos);

        final infos = routeInfos.cast<TaxonomyTermRouteInfo>();
        expect(infos, hasLength(2));
        expect(infos.map((r) => r.term), unorderedEquals(['dart', 'flutter']));
      });

      test('includes custom data in routeInfos', () async {
        final aggregator = TaxonomyAggregator(
          taxonomy: 'tags',
          termPageBuilder: (_, _, _) => Component.text(''),
          initialTermDataBuilder: (_, term) => {'title': 'Tag: $term'},
        );

        final pages = [_makePageWithTags(['dart'])];
        final routeInfos = <AggregatedRouteInfo>[];
        await aggregator.aggregatePages(pages, routeInfos);

        final info = routeInfos.cast<TaxonomyTermRouteInfo>().firstWhere((r) => r.term == 'dart');
        expect(info.data['title'], equals('Tag: dart'));
      });
    });
  });
}
