import 'dart:async';

import 'package:file/memory.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:watcher/watcher.dart';

import '../utils.dart';

class MockDirectoryWatcher extends Mock implements DirectoryWatcher {}

class MockPage extends Mock implements Page {}

void main() {
  late MemoryFileSystem fileSystem;

  setUp(() {
    fileSystem = MemoryFileSystem();
  });

  group('FilesystemLoader', () {
    group('loadPageSources()', () {
      test('loads basic file structure', () async {
        // Arrange
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('index.md').createSync();
        pagesDir.childFile('about.html').createSync();

        final loader = FilesystemLoader('pages', fileSystem: fileSystem);

        // Act
        final sources = await loader.loadPageSources();

        // Assert
        expect(sources, hasLength(2));
        expect(
            sources,
            equals([
              pageSource('index.md', '/', private: false),
              pageSource('about.html', '/about', private: false),
            ]));
      });

      test('loads nested file structure', () async {
        // Arrange
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('index.md').createSync();
        fileSystem.directory('pages/blog').createSync();
        fileSystem.file('pages/blog/post-1.md').createSync();

        final loader = FilesystemLoader('pages', fileSystem: fileSystem);

        // Act
        final sources = await loader.loadPageSources();

        // Assert
        expect(sources, hasLength(2));
        expect(
            sources,
            equals([
              pageSource('index.md', '/', private: false),
              pageSource('blog/post-1.md', '/blog/post-1', private: false),
            ]));
      });

      test('loads nested file structure on windows', () async {
        final MemoryFileSystem fs = MemoryFileSystem(style: FileSystemStyle.windows);
        // Arrange
        final pagesDir = fs.directory('pages')..createSync();
        pagesDir.childFile('index.md').createSync();
        fs.directory(r'pages\blog').createSync();
        fs.file(r'pages\blog\post-1.md').createSync();

        final loader = FilesystemLoader('pages', fileSystem: fs);

        // Act
        final sources = await loader.loadPageSources();

        // Assert
        expect(sources, hasLength(2));
        expect(
            sources,
            equals([
              pageSource('index.md', '/', private: false),
              pageSource(r'blog\post-1.md', '/blog/post-1', private: false),
            ]));
      });

      test('marks files and directories starting with an underscore as private', () async {
        // Arrange
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('index.md').createSync();
        pagesDir.childFile('_config.yaml').createSync();
        fileSystem.directory('pages/_includes').createSync();
        fileSystem.file('pages/_includes/header.html').createSync();

        final loader = FilesystemLoader('pages', fileSystem: fileSystem);

        // Act
        final sources = await loader.loadPageSources();

        // Assert
        expect(sources, hasLength(3));
        expect(
            sources,
            equals([
              pageSource('index.md', '/', private: false),
              pageSource('_config.yaml', '/_config', private: true),
              pageSource('_includes/header.html', '/_includes/header', private: true),
            ]));
      });

      test('keeps suffix for matching patterns', () async {
        // Arrange
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('sitemap.xml').createSync();
        pagesDir.childFile('feed.rss').createSync();

        final loader = FilesystemLoader(
          'pages',
          fileSystem: fileSystem,
          keepSuffixPattern: RegExp(r'.*\.xml$'),
        );

        // Act
        final sources = await loader.loadPageSources();

        // Assert
        expect(sources, hasLength(2));
        expect(
            sources,
            equals([
              pageSource('sitemap.xml', '/sitemap.xml', private: false),
              pageSource('feed.rss', '/feed', private: false),
            ]));
      });
    });

    group('File Watching', () {
      late MockDirectoryWatcher mockWatcher;
      late StreamController<WatchEvent> eventController;
      late FilesystemLoader loader;

      setUp(() {
        mockWatcher = MockDirectoryWatcher();
        eventController = StreamController<WatchEvent>.broadcast();
        when(() => mockWatcher.events).thenAnswer((_) => eventController.stream);

        fileSystem.directory('pages').createSync();
        loader = FilesystemLoader(
          'pages',
          fileSystem: fileSystem,
          watcherFactory: (_) => mockWatcher,
        );
      });

      test('adds new source on file add event', () async {
        // Arrange
        await loader.loadRoutes((_) => PageConfig(), false);
        expect(loader.sources, isEmpty);

        // Act
        final filePath = fileSystem.path.join('pages', 'about.md');
        fileSystem.file(filePath).createSync();

        eventController.add(WatchEvent(ChangeType.ADD, filePath));
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(loader.sources, hasLength(1));
        expect(loader.sources.first.url, equals('/about'));
      });

      test('removes source on file remove event', () async {
        // Arrange
        final filePath = fileSystem.path.join('pages', 'about.md');
        fileSystem.file(filePath).createSync();

        await loader.loadRoutes((_) => PageConfig(), false);
        expect(loader.sources, hasLength(1));

        // Act
        eventController.add(WatchEvent(ChangeType.REMOVE, filePath));
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(loader.sources, isEmpty);
      });
    });

    group('Partials and Dependencies', () {
      test('invalidates dependent page when partial changes', () async {
        // Arrange
        final mockWatcher = MockDirectoryWatcher();
        final eventController = StreamController<WatchEvent>.broadcast();
        when(() => mockWatcher.events).thenAnswer((_) => eventController.stream);

        final pagesDir = fileSystem.directory('pages')..createSync();
        final loader = FilesystemLoader(
          'pages',
          fileSystem: fileSystem,
          watcherFactory: (_) => mockWatcher,
        );

        final partialPath = fileSystem.path.join('pages', '_includes', 'header.html');
        fileSystem.file(partialPath)
          ..createSync(recursive: true)
          ..writeAsStringSync('Old Header');
        pagesDir.childFile('index.md')
          ..createSync()
          ..writeAsStringSync('Page Content');

        // Initial load to activate the watcher
        await loader.loadRoutes((_) => PageConfig(), false);

        // Build the page once to cache the result
        final pageSource = loader.sources.firstWhere((s) => s.path == 'index.md');
        await pageSource.load();
        expect(pageSource.page?.content, equals('Page Content'));

        // Establish dependency by reading the partial
        loader.readPartialSync(partialPath, pageSource.page!);

        // Act: Simulate a modify event on the partial
        eventController.add(WatchEvent(ChangeType.MODIFY, partialPath));
        await Future<void>.delayed(Duration.zero);

        // Assert: The page was invalidated
        expect(pageSource.page, isNull);
      });
    });
  });
}
