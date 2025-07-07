import 'package:jaspr_content/jaspr_content.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  late MockRouteLoader mockLoader;

  setUp(() {
    mockLoader = MockRouteLoader();
  });

  group('MemoryDataLoader', () {
    test('loads data into a page with no initial data', () async {
      // Arrange
      final loader = MemoryDataLoader({'a': 1, 'b': 2});
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: '',
        config: PageConfig(
          dataLoaders: [loader],
        ),
        loader: mockLoader,
      );

      // Act
      await page.loadData();

      // Assert
      expect(page.data, equals({'a': 1, 'b': 2, 'page': <String, Object?>{}}));
    });

    test('merges with existing data', () async {
      // Arrange
      final loader = MemoryDataLoader({
        'b': 20,
        'c': 3,
      });
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: '',
        initialData: {'a': 1, 'b': 2},
        config: PageConfig(
          dataLoaders: [loader],
        ),
        loader: mockLoader,
      );

      // Act
      await page.loadData();

      // Assert
      expect(page.data, equals({'a': 1, 'b': 20, 'c': 3, 'page': <String, Object?>{}}));
    });

    test('initial data takes precedence over loader data', () async {
      // Arrange
      final loader = MemoryDataLoader({
        'title': 'Global Title',
        'page': {
          'title': 'Loader Title', // This should be overridden
          'author': 'Loader Author', // This should be kept
        }
      });

      final page = Page(
        path: 'test.md',
        url: '/test',
        content: '',
        initialData: {
          'page': {'title': 'Initial Title'}
        },
        config: PageConfig(
          dataLoaders: [loader],
        ),
        loader: mockLoader,
      );

      // Act
      await page.loadData();

      // Assert
      expect(
          page.data,
          equals({
            'title': 'Global Title',
            'page': {
              'title': 'Initial Title', // Preserved from initialData
              'author': 'Loader Author', // Merged from loader
            }
          }));
    });

    test('frontmatter data takes precedence over loader data', () async {
      // Arrange
      final loader = MemoryDataLoader({
        'page': {
          'title': 'Loader Title',
          'author': 'Loader Author',
        }
      });

      final page = Page(
        path: 'test.md',
        url: '/test',
        content: '---\n'
            'title: Frontmatter Title\n'
            '---\n'
            '# Hello World',
        config: PageConfig(
          dataLoaders: [loader],
        ),
        loader: mockLoader,
      );

      // Act
      page.parseFrontmatter();
      await page.loadData();

      // Assert
      expect(
          page.data,
          equals({
            'page': {
              'title': 'Frontmatter Title',
              'author': 'Loader Author',
            }
          }));
    });

    test('does not change data if loader data is empty', () async {
      // Arrange
      final loader = MemoryDataLoader({});
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: '',
        initialData: {'a': 1},
        config: PageConfig(
          dataLoaders: [loader],
        ),
        loader: mockLoader,
      );

      // Act
      await page.loadData();

      // Assert
      expect(page.data, equals({'a': 1, 'page': <String, Object?>{}}));
    });
  });
}
