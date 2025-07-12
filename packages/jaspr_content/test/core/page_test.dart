import 'package:jaspr_content/jaspr_content.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  late MockRouteLoader mockLoader;

  setUp(() {
    mockLoader = MockRouteLoader();
  });

  group('Page.parseFrontmatter()', () {
    test('correctly parses document with frontmatter', () {
      // Arrange
      final rawContent = '''
---
title: My Test Page
author: Test User
---
# Hello World
''';
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: rawContent,
        config: PageConfig(enableFrontmatter: true),
        loader: mockLoader,
      );

      // Act
      page.parseFrontmatter();

      // Assert
      expect(
          page.data,
          equals({
            'page': {'title': 'My Test Page', 'author': 'Test User'}
          }));
      expect(page.content.trim(), equals('# Hello World'));
    });

    test('does nothing when enableFrontmatter is false', () {
      // Arrange
      final rawContent = '---\ntitle: My Test Page\n---\n# Hello';
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: rawContent,
        config: PageConfig(enableFrontmatter: false),
        loader: mockLoader,
      );

      // Act
      page.parseFrontmatter();

      // Assert
      expect(page.data, isEmpty);
      expect(page.content, equals(rawContent));
    });

    test('handles document with no frontmatter', () {
      // Arrange
      final rawContent = '# Hello World\nThis is the content.';
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: rawContent,
        config: PageConfig(enableFrontmatter: true),
        loader: mockLoader,
      );

      // Act
      page.parseFrontmatter();

      // Assert
      expect(page.data, {'page': <String, Object?>{}});
      expect(page.content, equals(rawContent));
    });
  });

  group('Page.apply()', () {
    test('merges new data with existing data by default', () {
      // Arrange
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: 'initial content',
        initialData: {
          'a': 1,
          'nested': {'x': 100, 'z': 300}
        },
        config: PageConfig(),
        loader: mockLoader,
      );
      final newData = {
        'b': 2,
        'nested': {'y': 200, 'z': 301}
      };

      // Act
      page.apply(data: newData);

      // Assert
      expect(
        page.data,
        equals({
          'a': 1,
          'b': 2,
          'nested': {'x': 100, 'y': 200, 'z': 301}
        }),
      );
      expect(page.content, 'initial content');
    });

    test('replaces data when mergeData is false', () {
      // Arrange
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: 'initial content',
        initialData: {'a': 1},
        config: PageConfig(),
        loader: mockLoader,
      );
      final newData = {'b': 2};

      // Act
      page.apply(data: newData, mergeData: false);

      // Assert
      expect(page.data, equals({'b': 2}));
      expect(page.content, 'initial content');
    });

    test('updates content only', () {
      // Arrange
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: 'initial content',
        initialData: {'a': 1},
        config: PageConfig(),
        loader: mockLoader,
      );

      // Act
      page.apply(content: 'new content');

      // Assert
      expect(page.data, equals({'a': 1}));
      expect(page.content, 'new content');
    });

    test('updates both content and data', () {
      // Arrange
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: 'initial content',
        initialData: {'a': 1},
        config: PageConfig(),
        loader: mockLoader,
      );

      // Act
      page.apply(content: 'new content', data: {'b': 2});

      // Assert
      expect(page.data, equals({'a': 1, 'b': 2}));
      expect(page.content, 'new content');
    });
  });
}
