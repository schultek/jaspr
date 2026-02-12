import 'dart:io';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:test/test.dart';

void main() {
  group('TaxonomyLoader', () {
    group('withTaxonomyData()', () {
      test('creates data with taxonomy key when no user data', () {
        final result = TaxonomyLoader.withTaxonomyData(
          null,
          taxonomy: 'tags',
        );

        expect(
          result,
          equals({
            'page': {
              TaxonomyUtils.taxonomyKey: 'tags',
            },
          }),
        );
        // _term key is omitted entirely (not set to null)
        // when no term is provided, via null-aware ?term syntax.
        expect((result['page'] as Map).containsKey(TaxonomyUtils.termKey), isFalse);
      });

      test('creates data with taxonomy and term keys', () {
        final result = TaxonomyLoader.withTaxonomyData(
          null,
          taxonomy: 'tags',
          term: 'dart',
        );

        expect(
          result,
          equals({
            'page': {
              TaxonomyUtils.taxonomyKey: 'tags',
              TaxonomyUtils.termKey: 'dart',
            },
          }),
        );
      });

      test('preserves user data at the top level', () {
        final result = TaxonomyLoader.withTaxonomyData(
          {
            'site': {'name': 'My Site'},
          },
          taxonomy: 'tags',
          term: 'dart',
        );

        expect(result['site'], equals({'name': 'My Site'}));
        final pageData = result['page'] as Map<String, Object?>;
        expect(pageData[TaxonomyUtils.taxonomyKey], equals('tags'));
        expect(pageData[TaxonomyUtils.termKey], equals('dart'));
      });

      test('merges user page data with taxonomy metadata', () {
        final result = TaxonomyLoader.withTaxonomyData(
          {
            'page': {'title': 'Posts tagged: dart'},
          },
          taxonomy: 'tags',
          term: 'dart',
        );

        expect(
          result['page'],
          equals({
            'title': 'Posts tagged: dart',
            TaxonomyUtils.taxonomyKey: 'tags',
            TaxonomyUtils.termKey: 'dart',
          }),
        );
      });

      test('taxonomy metadata takes precedence over user page data', () {
        final result = TaxonomyLoader.withTaxonomyData(
          {
            'page': {
              TaxonomyUtils.taxonomyKey: 'overridden',
              TaxonomyUtils.termKey: 'overridden',
              'title': 'My Page',
            },
          },
          taxonomy: 'tags',
          term: 'dart',
        );

        expect(
          result['page'],
          equals({
            'title': 'My Page',
            TaxonomyUtils.taxonomyKey: 'tags',
            TaxonomyUtils.termKey: 'dart',
          }),
        );
      });
    });

    group('extractTaxonomyTerms()', () {
      late Directory tempDir;

      setUp(() {
        tempDir = Directory.systemTemp.createTempSync('taxonomy_test_');
      });

      tearDown(() {
        tempDir.deleteSync(recursive: true);
      });

      test('extracts terms from markdown files', () {
        File('${tempDir.path}/post1.md').writeAsStringSync('''
---
title: Post 1
tags: [dart, flutter]
---
Content here.
''');
        File('${tempDir.path}/post2.md').writeAsStringSync('''
---
title: Post 2
tags: [dart, jaspr]
---
More content.
''');

        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final terms = loader.extractTaxonomyTerms(
          directory: tempDir.path,
          taxonomy: 'tags',
        );

        expect(terms, unorderedEquals({'dart', 'flutter', 'jaspr'}));
      });

      test('normalizes terms to lowercase with dashes', () {
        File('${tempDir.path}/post.md').writeAsStringSync('''
---
tags: [My Tag, Hello World]
---
''');

        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final terms = loader.extractTaxonomyTerms(
          directory: tempDir.path,
          taxonomy: 'tags',
        );

        expect(terms, unorderedEquals({'my-tag', 'hello-world'}));
      });

      test('returns empty set for non-existent directory', () {
        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: '${tempDir.path}/nonexistent',
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final terms = loader.extractTaxonomyTerms(
          directory: '${tempDir.path}/nonexistent',
          taxonomy: 'tags',
        );

        expect(terms, isEmpty);
      });

      test('returns empty set when no files have the taxonomy field', () {
        File('${tempDir.path}/post.md').writeAsStringSync('''
---
title: No Tags
---
''');

        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final terms = loader.extractTaxonomyTerms(
          directory: tempDir.path,
          taxonomy: 'tags',
        );

        expect(terms, isEmpty);
      });

      test('ignores files without frontmatter', () {
        File('${tempDir.path}/plain.md').writeAsStringSync('Just content.');

        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final terms = loader.extractTaxonomyTerms(
          directory: tempDir.path,
          taxonomy: 'tags',
        );

        expect(terms, isEmpty);
      });

      test('scans subdirectories recursively', () {
        Directory('${tempDir.path}/sub').createSync();
        File('${tempDir.path}/sub/post.md').writeAsStringSync('''
---
tags: [nested]
---
''');

        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final terms = loader.extractTaxonomyTerms(
          directory: tempDir.path,
          taxonomy: 'tags',
        );

        expect(terms, equals({'nested'}));
      });

      test('deduplicates terms across files', () {
        File('${tempDir.path}/a.md').writeAsStringSync('''
---
tags: [dart]
---
''');
        File('${tempDir.path}/b.md').writeAsStringSync('''
---
tags: [dart]
---
''');

        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final terms = loader.extractTaxonomyTerms(
          directory: tempDir.path,
          taxonomy: 'tags',
        );

        expect(terms, equals({'dart'}));
      });

      test('extracts terms from HTML files', () {
        File('${tempDir.path}/page.html').writeAsStringSync('''
---
tags: [html-tag]
---
<p>Content</p>
''');

        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final terms = loader.extractTaxonomyTerms(
          directory: tempDir.path,
          taxonomy: 'tags',
        );

        expect(terms, contains('html-tag'));
      });

      test('respects custom supportedExtensions', () {
        File('${tempDir.path}/post.md').writeAsStringSync('''
---
tags: [from-md]
---
''');
        File('${tempDir.path}/page.html').writeAsStringSync('''
---
tags: [from-html]
---
''');

        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
          supportedExtensions: ['.md'],
        );

        final terms = loader.extractTaxonomyTerms(
          directory: tempDir.path,
          taxonomy: 'tags',
        );

        expect(terms, contains('from-md'));
        expect(terms, isNot(contains('from-html')));
      });

      test('ignores non-list taxonomy field values', () {
        File('${tempDir.path}/post.md').writeAsStringSync('''
---
tags: just-a-string
---
''');

        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final terms = loader.extractTaxonomyTerms(
          directory: tempDir.path,
          taxonomy: 'tags',
        );

        expect(terms, isEmpty);
      });
    });

    group('createMemoryPages()', () {
      late Directory tempDir;

      setUp(() {
        tempDir = Directory.systemTemp.createTempSync('taxonomy_pages_test_');
        File('${tempDir.path}/post.md').writeAsStringSync('''
---
tags: [dart, flutter]
---
''');
      });

      tearDown(() {
        tempDir.deleteSync(recursive: true);
      });

      test('creates a page for each term', () {
        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = loader.createMemoryPages();

        expect(pages, hasLength(2));
        expect(pages.map((p) => p.path), unorderedEquals(['tags/dart.html', 'tags/flutter.html']));
      });

      test('creates taxonomy index page when taxonomyPageBuilder is provided', () {
        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
          taxonomyPageBuilder: (_, _) => Component.text(''),
        );

        final pages = loader.createMemoryPages();

        // 1 index + 2 terms
        expect(pages, hasLength(3));
        expect(pages[0].path, equals('tags/index.html'));
      });

      test('does not create index page when taxonomyPageBuilder is null', () {
        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = loader.createMemoryPages();

        expect(pages.any((p) => p.path.contains('index')), isFalse);
      });

      test('uses custom taxonomySlug for index page path', () {
        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          taxonomySlug: 'labels',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
          taxonomyPageBuilder: (_, _) => Component.text(''),
        );

        final pages = loader.createMemoryPages();

        expect(pages[0].path, equals('labels/index.html'));
      });

      test('uses custom termSlug for term page paths', () {
        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          termSlug: 'label',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = loader.createMemoryPages();

        for (final page in pages) {
          expect(page.path, startsWith('label/'));
        }
      });

      test('injects taxonomy metadata into term page initialData', () {
        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = loader.createMemoryPages();
        final dartPage = pages.firstWhere((p) => p.path == 'tags/dart.html');

        expect(dartPage.initialData['page'], isA<Map<String, Object?>>());
        final pageData = dartPage.initialData['page'] as Map<String, Object?>;
        expect(pageData[TaxonomyUtils.taxonomyKey], equals('tags'));
        expect(pageData[TaxonomyUtils.termKey], equals('dart'));
      });

      test('injects taxonomy metadata into index page initialData', () {
        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
          taxonomyPageBuilder: (_, _) => Component.text(''),
        );

        final pages = loader.createMemoryPages();
        final indexPage = pages.firstWhere((p) => p.path == 'tags/index.html');

        expect(indexPage.initialData['page'], isA<Map<String, Object?>>());
        final pageData = indexPage.initialData['page'] as Map<String, Object?>;
        expect(pageData[TaxonomyUtils.taxonomyKey], equals('tags'));
        expect(pageData[TaxonomyUtils.termKey], isNull);
      });

      test('merges initialTermDataBuilder data with taxonomy metadata', () {
        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
          initialTermDataBuilder: (_, term) => {
            'page': {'title': 'Tag: $term'},
          },
        );

        final pages = loader.createMemoryPages();
        final dartPage = pages.firstWhere((p) => p.path == 'tags/dart.html');

        final pageData = dartPage.initialData['page'] as Map<String, Object?>;
        expect(pageData['title'], equals('Tag: dart'));
        expect(pageData[TaxonomyUtils.taxonomyKey], equals('tags'));
        expect(pageData[TaxonomyUtils.termKey], equals('dart'));
      });

      test('merges taxonomyInitialDataBuilder data with taxonomy metadata', () {
        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
          taxonomyPageBuilder: (_, _) => Component.text(''),
          taxonomyInitialDataBuilder: (taxonomy) => {
            'page': {'title': 'All $taxonomy'},
          },
        );

        final pages = loader.createMemoryPages();
        final indexPage = pages.firstWhere((p) => p.path == 'tags/index.html');

        final pageData = indexPage.initialData['page'] as Map<String, Object?>;
        expect(pageData['title'], equals('All tags'));
        expect(pageData[TaxonomyUtils.taxonomyKey], equals('tags'));
        // Index page has no term key.
        expect(pageData.containsKey(TaxonomyUtils.termKey), isFalse);
      });

      test('passes taxonomy and term to initialTermDataBuilder', () {
        final captured = <(String, String)>[];

        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: tempDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
          initialTermDataBuilder: (taxonomy, term) {
            captured.add((taxonomy, term));
            return {};
          },
        );

        loader.createMemoryPages();

        expect(captured, unorderedEquals([('tags', 'dart'), ('tags', 'flutter')]));
      });

      test('creates no pages when directory has no matching terms', () {
        final emptyDir = Directory.systemTemp.createTempSync('taxonomy_empty_test_');
        addTearDown(() => emptyDir.deleteSync(recursive: true));

        final loader = TaxonomyLoader(
          taxonomy: 'tags',
          directory: emptyDir.path,
          termPageBuilder: (_, _, _) => Component.text(''),
        );

        final pages = loader.createMemoryPages();

        expect(pages, isEmpty);
      });
    });
  });
}
