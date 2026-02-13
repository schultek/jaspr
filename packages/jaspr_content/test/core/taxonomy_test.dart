// import 'package:jaspr/server.dart';
// import 'package:jaspr_content/jaspr_content.dart';
// import 'package:jaspr_test/jaspr_test.dart';

// import '../utils.dart';

// Page _makePage({
//   String path = 'test.md',
//   String url = '/test',
//   Map<String, Object?> initialData = const {},
// }) {
//   return Page(
//     path: path,
//     url: url,
//     content: '',
//     initialData: initialData,
//     config: PageConfig(),
//     loader: MockRouteLoader(),
//   );
// }

// void main() {
//   group('TaxonomyUtils', () {
//     group('normalize()', () {
//       test('lowercases the value', () {
//         expect(TaxonomyUtils.normalize('Dart'), equals('dart'));
//         expect(TaxonomyUtils.normalize('FLUTTER'), equals('flutter'));
//       });

//       test('replaces spaces with dashes', () {
//         expect(TaxonomyUtils.normalize('my tag'), equals('my-tag'));
//         expect(TaxonomyUtils.normalize('hello world foo'), equals('hello-world-foo'));
//       });

//       test('lowercases and replaces spaces', () {
//         expect(TaxonomyUtils.normalize('My Tag'), equals('my-tag'));
//         expect(TaxonomyUtils.normalize('Hello World'), equals('hello-world'));
//       });

//       test('returns already-normalized values unchanged', () {
//         expect(TaxonomyUtils.normalize('dart'), equals('dart'));
//         expect(TaxonomyUtils.normalize('my-tag'), equals('my-tag'));
//       });

//       test('handles empty string', () {
//         expect(TaxonomyUtils.normalize(''), equals(''));
//       });
//     });

//     test('taxonomyKey is _taxonomy', () {
//       expect(TaxonomyUtils.taxonomyKey, equals('_taxonomy'));
//     });

//     test('termKey is _term', () {
//       expect(TaxonomyUtils.termKey, equals('_term'));
//     });
//   });

//   group('TaxonomyPage', () {
//     test('returns taxonomy and term from taxonomy page', () {
//       final page = _makePage(
//         initialData: TaxonomyLoader.withTaxonomyData(null, taxonomy: 'tags', term: 'dart'),
//       );

//       expect(page.taxonomy, equals('tags'));
//       expect(page.taxonomyTerm, equals('dart'));
//     });

//     test('returns taxonomy and null term from index page', () {
//       final page = _makePage(
//         initialData: TaxonomyLoader.withTaxonomyData(null, taxonomy: 'tags'),
//       );

//       expect(page.taxonomy, equals('tags'));
//       expect(page.taxonomyTerm, isNull);
//     });

//     test('returns null for non-taxonomy page', () {
//       final page = _makePage(
//         initialData: {
//           'page': {'title': 'Hello'},
//         },
//       );

//       expect(page.taxonomy, isNull);
//       expect(page.taxonomyTerm, isNull);
//     });
//   });

//   group('TaxonomyContext', () {
//     late List<Page> allPages;
//     late Page currentPage;

//     setUp(() {
//       allPages = [
//         // Taxonomy term pages (created by TaxonomyLoader).
//         _makePage(
//           path: 'tags/dart.html',
//           url: '/tags/dart',
//           initialData: TaxonomyLoader.withTaxonomyData(null, taxonomy: 'tags', term: 'dart'),
//         ),
//         _makePage(
//           path: 'tags/flutter.html',
//           url: '/tags/flutter',
//           initialData: TaxonomyLoader.withTaxonomyData(null, taxonomy: 'tags', term: 'flutter'),
//         ),
//         // Taxonomy index page (no term).
//         _makePage(
//           path: 'tags/index.html',
//           url: '/tags',
//           initialData: TaxonomyLoader.withTaxonomyData(null, taxonomy: 'tags'),
//         ),
//         // A different taxonomy.
//         _makePage(
//           path: 'categories/tutorials.html',
//           url: '/categories/tutorials',
//           initialData: TaxonomyLoader.withTaxonomyData(null, taxonomy: 'categories', term: 'tutorials'),
//         ),
//         // Content pages with frontmatter tags.
//         _makePage(
//           path: 'posts/hello.md',
//           url: '/posts/hello',
//           initialData: {
//             'page': {
//               'title': 'Hello',
//               'tags': ['Dart', 'Flutter'],
//             },
//           },
//         ),
//         _makePage(
//           path: 'posts/world.md',
//           url: '/posts/world',
//           initialData: {
//             'page': {
//               'title': 'World',
//               'tags': ['Dart', 'Jaspr'],
//             },
//           },
//         ),
//         // Content page without tags.
//         _makePage(
//           path: 'about.md',
//           url: '/about',
//           initialData: {
//             'page': {'title': 'About'},
//           },
//         ),
//       ];
//       currentPage = allPages.first;
//     });

//     group('taxonomyTermPages()', () {
//       testComponents('returns only term pages for the given taxonomy', (tester) async {
//         late List<Page> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPages('tags');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, hasLength(2));
//         expect(result.map((p) => p.url), unorderedEquals(['/tags/dart', '/tags/flutter']));
//       }, isClient: false);

//       testComponents('excludes taxonomy index page (no term)', (tester) async {
//         late List<Page> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPages('tags');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result.any((p) => p.url == '/tags'), isFalse);
//       }, isClient: false);

//       testComponents('does not return pages from other taxonomies', (tester) async {
//         late List<Page> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPages('tags');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result.any((p) => p.url == '/categories/tutorials'), isFalse);
//       }, isClient: false);

//       testComponents('returns pages for a different taxonomy', (tester) async {
//         late List<Page> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPages('categories');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, hasLength(1));
//         expect(result.first.url, equals('/categories/tutorials'));
//       }, isClient: false);

//       testComponents('returns empty list for non-existent taxonomy', (tester) async {
//         late List<Page> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPages('nonexistent');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, isEmpty);
//       }, isClient: false);
//     });

//     group('taxonomyTermPage()', () {
//       testComponents('returns the term page for a given taxonomy and term', (tester) async {
//         late Page? result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPage('tags', 'dart');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, isNotNull);
//         expect(result!.url, equals('/tags/dart'));
//       }, isClient: false);

//       testComponents('normalizes the term for matching', (tester) async {
//         late Page? result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPage('tags', 'Dart');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, isNotNull);
//         expect(result!.url, equals('/tags/dart'));
//       }, isClient: false);

//       testComponents('returns null for non-existent term', (tester) async {
//         late Page? result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPage('tags', 'nonexistent');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, isNull);
//       }, isClient: false);

//       testComponents('returns null for non-existent taxonomy', (tester) async {
//         late Page? result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPage('nonexistent', 'dart');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, isNull);
//       }, isClient: false);
//     });

//     group('pagesForTerm()', () {
//       testComponents('returns content pages with the given term', (tester) async {
//         late List<Page> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.pagesForTerm('tags', 'dart');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, hasLength(2));
//         expect(result.map((p) => p.url), unorderedEquals(['/posts/hello', '/posts/world']));
//       }, isClient: false);

//       testComponents('normalizes the term for matching', (tester) async {
//         late List<Page> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.pagesForTerm('tags', 'Dart');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, hasLength(2));
//       }, isClient: false);

//       testComponents('excludes taxonomy pages themselves', (tester) async {
//         late List<Page> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.pagesForTerm('tags', 'dart');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result.any((p) => p.url.startsWith('/tags')), isFalse);
//       }, isClient: false);

//       testComponents('returns only pages with the specific term', (tester) async {
//         late List<Page> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.pagesForTerm('tags', 'flutter');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, hasLength(1));
//         expect(result.first.url, equals('/posts/hello'));
//       }, isClient: false);

//       testComponents('returns empty list for non-existent term', (tester) async {
//         late List<Page> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.pagesForTerm('tags', 'nonexistent');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, isEmpty);
//       }, isClient: false);

//       testComponents('returns empty list for pages without the taxonomy field', (tester) async {
//         late List<Page> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.pagesForTerm('categories', 'dart');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, isEmpty);
//       }, isClient: false);

//       testComponents('ignores pages where taxonomy field is not a list', (tester) async {
//         final pagesWithStringTag = [
//           ...allPages,
//           _makePage(
//             path: 'posts/string-tag.md',
//             url: '/posts/string-tag',
//             initialData: {
//               'page': {'title': 'String Tag', 'tags': 'dart'},
//             },
//           ),
//         ];

//         late List<Page> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             pagesWithStringTag,
//             Builder(
//               builder: (context) {
//                 result = context.pagesForTerm('tags', 'dart');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         // Only the 2 original content pages with list tags, not the string one.
//         expect(result, hasLength(2));
//         expect(result.any((p) => p.url == '/posts/string-tag'), isFalse);
//       }, isClient: false);
//     });

//     group('taxonomyTermPagesWithCount()', () {
//       testComponents('returns term pages as keys with content page counts', (tester) async {
//         late Map<Page, int> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPagesWithCount('tags');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, hasLength(2));
//         final byUrl = {for (final e in result.entries) e.key.url: e.value};
//         expect(
//           byUrl,
//           equals({
//             '/tags/dart': 2,
//             '/tags/flutter': 1,
//           }),
//         );
//       }, isClient: false);

//       testComponents('only includes terms that have a term page', (tester) async {
//         late Map<Page, int> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPagesWithCount('tags');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         // 'jaspr' appears in content but has no term page, so it's excluded.
//         final termNames = result.keys.map((p) => p.taxonomyTerm);
//         expect(termNames, isNot(contains('jaspr')));
//       }, isClient: false);

//       testComponents('returns 0 count for term with no matching content pages', (tester) async {
//         final pagesWithOrphanTerm = [
//           ...allPages,
//           // Term page for 'rust' exists, but no content page has tags: [rust].
//           _makePage(
//             path: 'tags/rust.html',
//             url: '/tags/rust',
//             initialData: TaxonomyLoader.withTaxonomyData(null, taxonomy: 'tags', term: 'rust'),
//           ),
//         ];

//         late Map<Page, int> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             pagesWithOrphanTerm,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPagesWithCount('tags');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         final rustEntry = result.entries.firstWhere((e) => e.key.url == '/tags/rust');
//         expect(rustEntry.value, equals(0));
//       }, isClient: false);

//       testComponents('provides taxonomyTerm on result keys', (tester) async {
//         late Map<Page, int> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPagesWithCount('tags');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         final termNames = result.keys.map((p) => p.taxonomyTerm).toSet();
//         expect(termNames, unorderedEquals({'dart', 'flutter'}));
//       }, isClient: false);

//       testComponents('returns empty map for non-existent taxonomy', (tester) async {
//         late Map<Page, int> result;
//         tester.pumpComponent(
//           Page.wrap(
//             currentPage,
//             allPages,
//             Builder(
//               builder: (context) {
//                 result = context.taxonomyTermPagesWithCount('nonexistent');
//                 return Component.text('');
//               },
//             ),
//           ),
//         );

//         expect(result, isEmpty);
//       }, isClient: false);
//     });
//   });
// }
