import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/src/aggregated_route.dart' show InheritedAggregatedContext;
import 'package:jaspr_test/jaspr_test.dart';

import '../utils.dart';

Page _makePage({
  String path = 'test.md',
  String url = '/test',
  Map<String, Object?> initialData = const {},
}) {
  return Page(
    path: path,
    url: url,
    content: '',
    initialData: initialData,
    config: PageConfig(),
    loader: MockRouteLoader(),
  );
}

void main() {
  group('TaxonomyUtils', () {
    group('normalize()', () {
      test('lowercases the value', () {
        expect(TaxonomyUtils.normalize('Dart'), equals('dart'));
        expect(TaxonomyUtils.normalize('FLUTTER'), equals('flutter'));
      });

      test('replaces spaces with dashes', () {
        expect(TaxonomyUtils.normalize('my tag'), equals('my-tag'));
        expect(TaxonomyUtils.normalize('hello world foo'), equals('hello-world-foo'));
      });

      test('lowercases and replaces spaces', () {
        expect(TaxonomyUtils.normalize('My Tag'), equals('my-tag'));
        expect(TaxonomyUtils.normalize('Hello World'), equals('hello-world'));
      });

      test('returns already-normalized values unchanged', () {
        expect(TaxonomyUtils.normalize('dart'), equals('dart'));
        expect(TaxonomyUtils.normalize('my-tag'), equals('my-tag'));
      });

      test('handles empty string', () {
        expect(TaxonomyUtils.normalize(''), equals(''));
      });
    });
  });

  group('InheritedAggregatedContext routeInfos', () {
    late List<AggregatedRouteInfo> routeInfos;

    setUp(() {
      routeInfos = [
        const TaxonomyTermRouteInfo(taxonomy: 'tags', term: 'dart', url: '/tags/dart'),
        const TaxonomyTermRouteInfo(taxonomy: 'tags', term: 'flutter', url: '/tags/flutter'),
        const TaxonomyRouteInfo(taxonomy: 'tags', url: '/tags'),
        const TaxonomyTermRouteInfo(taxonomy: 'categories', term: 'tutorials', url: '/categories/tutorials'),
      ];
    });

    test('whereType filters to TaxonomyRouteInfo (including terms)', () {
      final refs = routeInfos.whereType<TaxonomyRouteInfo>().toList();
      expect(refs, hasLength(4));
    });

    test('whereType can be filtered by taxonomy', () {
      final refs = routeInfos.whereType<TaxonomyRouteInfo>().where((r) => r.taxonomy == 'tags').toList();
      expect(refs, hasLength(3));
    });

    test('whereType<TaxonomyTermRouteInfo> returns only term refs', () {
      final refs = routeInfos.whereType<TaxonomyTermRouteInfo>().where((r) => r.taxonomy == 'tags').toList();
      expect(refs, hasLength(2));
      expect(refs.map((r) => r.url), unorderedEquals(['/tags/dart', '/tags/flutter']));
    });
  });

  group('TaxonomyContext', () {
    late List<Page> allPages;
    late Page currentPage;
    late List<TaxonomyRouteInfo> refs;

    setUp(() {
      allPages = [
        _makePage(path: 'posts/hello.md', url: '/posts/hello', initialData: {
          'page': {
            'title': 'Hello',
            'tags': ['Dart', 'Flutter'],
          },
        }),
        _makePage(path: 'posts/world.md', url: '/posts/world', initialData: {
          'page': {
            'title': 'World',
            'tags': ['Dart', 'Jaspr'],
          },
        }),
        _makePage(path: 'about.md', url: '/about', initialData: {
          'page': {'title': 'About'},
        }),
      ];
      currentPage = allPages.first;
      refs = [
        const TaxonomyTermRouteInfo(taxonomy: 'tags', term: 'dart', url: '/tags/dart'),
        const TaxonomyTermRouteInfo(taxonomy: 'tags', term: 'flutter', url: '/tags/flutter'),
        const TaxonomyRouteInfo(taxonomy: 'tags', url: '/tags'),
        const TaxonomyTermRouteInfo(taxonomy: 'categories', term: 'tutorials', url: '/categories/tutorials'),
      ];
    });

    group('taxonomyTermRefs()', () {
      testComponents('returns only term refs for the given taxonomy', (tester) async {
        late List<TaxonomyTermRouteInfo> result;
        tester.pumpComponent(
          InheritedAggregatedContext(
            contentPages: allPages,
            routeInfos: refs,
            child: Page.wrap(currentPage, allPages, Builder(builder: (context) {
              result = context.taxonomyTermRefs('tags');
              return Component.text('');
            })),
          ),
        );

        expect(result, hasLength(2));
        expect(result.map((r) => r.url), unorderedEquals(['/tags/dart', '/tags/flutter']));
      }, isClient: false);

      testComponents('returns empty list when no context is present', (tester) async {
        late List<TaxonomyTermRouteInfo> result;
        tester.pumpComponent(
          Page.wrap(currentPage, allPages, Builder(builder: (context) {
            result = context.taxonomyTermRefs('tags');
            return Component.text('');
          })),
        );

        expect(result, isEmpty);
      }, isClient: false);

      testComponents('returns empty list for non-existent taxonomy', (tester) async {
        late List<TaxonomyTermRouteInfo> result;
        tester.pumpComponent(
          InheritedAggregatedContext(
            contentPages: allPages,
            routeInfos: refs,
            child: Page.wrap(currentPage, allPages, Builder(builder: (context) {
              result = context.taxonomyTermRefs('nonexistent');
              return Component.text('');
            })),
          ),
        );

        expect(result, isEmpty);
      }, isClient: false);
    });

    group('taxonomyTermRef()', () {
      testComponents('returns the matching term ref', (tester) async {
        late TaxonomyRouteInfo? result;
        tester.pumpComponent(
          InheritedAggregatedContext(
            contentPages: allPages,
            routeInfos: refs,
            child: Page.wrap(currentPage, allPages, Builder(builder: (context) {
              result = context.taxonomyTermRef('tags', 'dart');
              return Component.text('');
            })),
          ),
        );

        expect(result, isNotNull);
        expect(result!.url, equals('/tags/dart'));
      }, isClient: false);

      testComponents('normalizes the term for matching', (tester) async {
        late TaxonomyRouteInfo? result;
        tester.pumpComponent(
          InheritedAggregatedContext(
            contentPages: allPages,
            routeInfos: refs,
            child: Page.wrap(currentPage, allPages, Builder(builder: (context) {
              result = context.taxonomyTermRef('tags', 'Dart');
              return Component.text('');
            })),
          ),
        );

        expect(result, isNotNull);
        expect(result!.url, equals('/tags/dart'));
      }, isClient: false);

      testComponents('returns null for non-existent term', (tester) async {
        late TaxonomyRouteInfo? result;
        tester.pumpComponent(
          InheritedAggregatedContext(
            contentPages: allPages,
            routeInfos: refs,
            child: Page.wrap(currentPage, allPages, Builder(builder: (context) {
              result = context.taxonomyTermRef('tags', 'nonexistent');
              return Component.text('');
            })),
          ),
        );

        expect(result, isNull);
      }, isClient: false);
    });

    group('taxonomyIndexRef()', () {
      testComponents('returns the index ref', (tester) async {
        late TaxonomyRouteInfo? result;
        tester.pumpComponent(
          InheritedAggregatedContext(
            contentPages: allPages,
            routeInfos: refs,
            child: Page.wrap(currentPage, allPages, Builder(builder: (context) {
              result = context.taxonomyIndexRef('tags');
              return Component.text('');
            })),
          ),
        );

        expect(result, isNotNull);
        expect(result!.url, equals('/tags'));
      }, isClient: false);

      testComponents('returns null when no index ref exists', (tester) async {
        late TaxonomyRouteInfo? result;
        tester.pumpComponent(
          InheritedAggregatedContext(
            contentPages: allPages,
            routeInfos: refs,
            child: Page.wrap(currentPage, allPages, Builder(builder: (context) {
              result = context.taxonomyIndexRef('categories');
              return Component.text('');
            })),
          ),
        );

        expect(result, isNull);
      }, isClient: false);
    });

    group('pagesForTerm()', () {
      testComponents('returns content pages with the given term', (tester) async {
        late List<Page> result;
        tester.pumpComponent(
          Page.wrap(currentPage, allPages, Builder(builder: (context) {
            result = context.pagesForTerm('tags', 'dart');
            return Component.text('');
          })),
        );

        expect(result, hasLength(2));
        expect(result.map((p) => p.url), unorderedEquals(['/posts/hello', '/posts/world']));
      }, isClient: false);

      testComponents('normalizes the term for matching', (tester) async {
        late List<Page> result;
        tester.pumpComponent(
          Page.wrap(currentPage, allPages, Builder(builder: (context) {
            result = context.pagesForTerm('tags', 'Dart');
            return Component.text('');
          })),
        );

        expect(result, hasLength(2));
      }, isClient: false);

      testComponents('returns only pages with the specific term', (tester) async {
        late List<Page> result;
        tester.pumpComponent(
          Page.wrap(currentPage, allPages, Builder(builder: (context) {
            result = context.pagesForTerm('tags', 'flutter');
            return Component.text('');
          })),
        );

        expect(result, hasLength(1));
        expect(result.first.url, equals('/posts/hello'));
      }, isClient: false);

      testComponents('returns empty list for non-existent term', (tester) async {
        late List<Page> result;
        tester.pumpComponent(
          Page.wrap(currentPage, allPages, Builder(builder: (context) {
            result = context.pagesForTerm('tags', 'nonexistent');
            return Component.text('');
          })),
        );

        expect(result, isEmpty);
      }, isClient: false);

      testComponents('ignores pages where taxonomy field is not a list', (tester) async {
        final pagesWithStringTag = [
          ...allPages,
          _makePage(path: 'posts/string-tag.md', url: '/posts/string-tag', initialData: {
            'page': {'title': 'String Tag', 'tags': 'dart'},
          }),
        ];

        late List<Page> result;
        tester.pumpComponent(
          Page.wrap(currentPage, pagesWithStringTag, Builder(builder: (context) {
            result = context.pagesForTerm('tags', 'dart');
            return Component.text('');
          })),
        );

        // Only the 2 original content pages with list tags, not the string one.
        expect(result, hasLength(2));
        expect(result.any((p) => p.url == '/posts/string-tag'), isFalse);
      }, isClient: false);
    });

    group('taxonomyTermRefsWithCount()', () {
      testComponents('returns term refs as keys with content page counts', (tester) async {
        late Map<TaxonomyRouteInfo, int> result;
        tester.pumpComponent(
          InheritedAggregatedContext(
            contentPages: allPages,
            routeInfos: refs,
            child: Page.wrap(currentPage, allPages, Builder(builder: (context) {
              result = context.taxonomyTermRefsWithCount('tags');
              return Component.text('');
            })),
          ),
        );

        expect(result, hasLength(2));
        final byUrl = {for (final e in result.entries) e.key.url: e.value};
        expect(byUrl, equals({'/tags/dart': 2, '/tags/flutter': 1}));
      }, isClient: false);

      testComponents('returns 0 count for term with no matching content pages', (tester) async {
        final extendedRefs = [
          ...refs,
          const TaxonomyTermRouteInfo(taxonomy: 'tags', term: 'rust', url: '/tags/rust'),
        ];

        late Map<TaxonomyRouteInfo, int> result;
        tester.pumpComponent(
          InheritedAggregatedContext(
            contentPages: allPages,
            routeInfos: extendedRefs,
            child: Page.wrap(currentPage, allPages, Builder(builder: (context) {
              result = context.taxonomyTermRefsWithCount('tags');
              return Component.text('');
            })),
          ),
        );

        final rustEntry = result.entries.firstWhere((e) => e.key.url == '/tags/rust');
        expect(rustEntry.value, equals(0));
      }, isClient: false);
    });

    group('context.pages in aggregated routes', () {
      testComponents('returns contentPages via InheritedAggregatedContext', (tester) async {
        late List<Page> result;
        tester.pumpComponent(
          InheritedAggregatedContext(
            contentPages: allPages,
            routeInfos: refs,
            child: Builder(builder: (context) {
              result = context.pages;
              return Component.text('');
            }),
          ),
        );

        expect(result, equals(allPages));
      }, isClient: false);
    });
  });
}
