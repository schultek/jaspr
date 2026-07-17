import 'dart:async';
import 'dart:io';

import 'package:file/memory.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:watcher/watcher.dart';

import '../utils.dart';

class MockDirectoryWatcher extends Mock implements DirectoryWatcher {}

class MockPage extends Mock implements Page {}

void main() {
  group('FilesystemLoader', () {
    group('loadPageSources()', () {
      test('loads basic file structure', () async {
        // Arrange
        final fileSystem = MemoryFileSystem();
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
          ]),
        );
      });

      test('loads files with dots in their name', () async {
        final fileSystem = MemoryFileSystem();
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('release-0.1.0.md').createSync();

        final loader = FilesystemLoader('pages', fileSystem: fileSystem);

        final sources = await loader.loadPageSources();

        expect(sources, hasLength(1));
        expect(
          sources,
          equals([pageSource('release-0.1.0.md', '/release-0.1.0', private: false)]),
        );
      });

      test('loads nested file structure', () async {
        // Arrange
        final fileSystem = MemoryFileSystem();
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
          ]),
        );
      });

      test('loads nested file structure on windows', () async {
        // Arrange
        final fileSystem = MemoryFileSystem(style: FileSystemStyle.windows);
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('index.md').createSync();
        fileSystem.directory(r'pages\blog').createSync();
        fileSystem.file(r'pages\blog\post-1.md').createSync();

        final loader = FilesystemLoader('pages', fileSystem: fileSystem);

        // Act
        final sources = await loader.loadPageSources();

        // Assert
        expect(sources, hasLength(2));
        expect(
          sources,
          equals([
            pageSource('index.md', '/', private: false),
            pageSource(r'blog/post-1.md', '/blog/post-1', private: false),
          ]),
        );
      });

      test('marks files and directories starting with an underscore as private', () async {
        // Arrange
        final fileSystem = MemoryFileSystem();
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
          ]),
        );
      });

      test('keeps suffix for matching patterns', () async {
        // Arrange
        final fileSystem = MemoryFileSystem();
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('sitemap.xml').createSync();
        pagesDir.childFile('feed.rss').createSync();

        final loader = FilesystemLoader('pages', fileSystem: fileSystem, keepSuffixPattern: RegExp(r'.*\.xml$'));

        // Act
        final sources = await loader.loadPageSources();

        // Assert
        expect(sources, hasLength(2));
        expect(
          sources,
          equals([
            pageSource('sitemap.xml', '/sitemap.xml', private: false),
            pageSource('feed.rss', '/feed', private: false),
          ]),
        );
      });

      test('skips files that do not match the filter extensions', () async {
        // Arrange
        final fileSystem = MemoryFileSystem();
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('index.md').createSync();
        pagesDir.childFile('about.yaml').createSync();

        final loader = FilesystemLoader(
          'pages',
          fileSystem: fileSystem,
          filterExtensions: {'.md'},
        );

        // Act
        final sources = await loader.loadPageSources();

        // Assert
        expect(sources, hasLength(1));
        expect(sources, equals([pageSource('index.md', '/', private: false)]));
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
      });

      test('adds new source on file add event', () async {
        // Arrange
        final fileSystem = MemoryFileSystem();
        fileSystem.directory('pages').createSync();
        loader = FilesystemLoader('pages', fileSystem: fileSystem, watcherFactory: (_) => mockWatcher);
        await loader.loadRoutes((_) => PageConfig(), false);
        expect(loader.sources, isEmpty);

        // Act
        fileSystem.file('pages/about.md').createSync();
        eventController.add(WatchEvent(ChangeType.ADD, 'pages/about.md'));
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(loader.sources, hasLength(1));
        expect(loader.sources.first.url, equals('/about'));
      });

      test('adds new source on file add event on windows', () async {
        // Arrange
        final fileSystem = MemoryFileSystem(style: FileSystemStyle.windows);
        fileSystem.directory('pages').createSync();
        loader = FilesystemLoader('pages', fileSystem: fileSystem, watcherFactory: (_) => mockWatcher);
        await loader.loadRoutes((_) => PageConfig(), false);
        expect(loader.sources, isEmpty);

        // Act
        fileSystem.file(r'pages\about.md').createSync();
        eventController.add(WatchEvent(ChangeType.ADD, r'pages\about.md'));
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(loader.sources, hasLength(1));
        expect(loader.sources.first.url, equals('/about'));
      });

      test('removes source on file remove event', () async {
        // Arrange
        final fileSystem = MemoryFileSystem();
        fileSystem.directory('pages').createSync();
        loader = FilesystemLoader('pages', fileSystem: fileSystem, watcherFactory: (_) => mockWatcher);
        fileSystem.file('pages/about.md').createSync();

        await loader.loadRoutes((_) => PageConfig(), false);
        expect(loader.sources, hasLength(1));

        // Act
        eventController.add(WatchEvent(ChangeType.REMOVE, 'pages/about.md'));
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(loader.sources, isEmpty);
      });

      test('removes source on file remove event on windows', () async {
        // Arrange
        final fileSystem = MemoryFileSystem(style: FileSystemStyle.windows);
        fileSystem.directory('pages').createSync();
        loader = FilesystemLoader('pages', fileSystem: fileSystem, watcherFactory: (_) => mockWatcher);
        fileSystem.file(r'pages\about.md').createSync();

        await loader.loadRoutes((_) => PageConfig(), false);
        expect(loader.sources, hasLength(1));

        // Act
        eventController.add(WatchEvent(ChangeType.REMOVE, r'pages\about.md'));
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(loader.sources, isEmpty);
      });
    });

    group('Partials and Dependencies', () {
      late MockDirectoryWatcher mockWatcher;
      late StreamController<WatchEvent> eventController;

      setUp(() {
        mockWatcher = MockDirectoryWatcher();
        eventController = StreamController<WatchEvent>.broadcast();
        addTearDown(eventController.close);
        when(() => mockWatcher.events).thenAnswer((_) => eventController.stream);
      });

      test('invalidates dependent page when partial changes', () async {
        // Arrange
        final fileSystem = MemoryFileSystem();
        final pagesDir = fileSystem.directory('pages')..createSync();
        final loader = FilesystemLoader('pages', fileSystem: fileSystem, watcherFactory: (_) => mockWatcher);

        final partialPath = 'pages/_includes/header.html';
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

      test('invalidates dependent page when partial changes on windows', () async {
        // Arrange
        final fileSystem = MemoryFileSystem(style: FileSystemStyle.windows);
        final pagesDir = fileSystem.directory('pages')..createSync();
        final loader = FilesystemLoader('pages', fileSystem: fileSystem, watcherFactory: (_) => mockWatcher);

        final partialPath = r'pages\_includes\header.html';
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

      test('invalidates dependent page when filtered partial is removed', () async {
        // Arrange the file system layout and content.
        final fileSystem = MemoryFileSystem();
        final pagesDir = fileSystem.directory('pages')..createSync();
        final loader = FilesystemLoader(
          'pages',
          filterExtensions: {'.md'},
          fileSystem: fileSystem,
          watcherFactory: (_) => mockWatcher,
        );

        final partialPath = 'pages/_includes/header.html';
        final partialFile = fileSystem.file(partialPath)
          ..createSync(recursive: true)
          ..writeAsStringSync('Header');
        pagesDir.childFile('index.md')
          ..createSync()
          ..writeAsStringSync('Page content');

        // Initial load to activate the watcher.
        await loader.loadRoutes((_) => PageConfig(), false);

        // Confirm that the partial was filtered out of the loader's page sources
        // even though it remains available to templates.
        expect(loader.sources.map((source) => source.file.path), isNot(contains(partialPath)));

        // Build the page once to cache the result.
        final pageSource = loader.sources.single;
        final cachedComponent = await pageSource.load();

        // Establish dependency by reading the filtered partial.
        loader.readPartialSync(partialPath, pageSource.page!);

        // Act: Delete the partial and simulate a remove event for it.
        partialFile.deleteSync();
        eventController.add(WatchEvent(ChangeType.REMOVE, partialPath));
        await Future<void>.delayed(Duration.zero);

        // Assert: The dependent page stays invalidated until requested.
        expect(pageSource.page, isNull);

        // The dependent page is rebuilt instead of serving the cached result.
        expect(await pageSource.load(), isNot(same(cachedComponent)));
      });

      for (final filtered in [false, true]) {
        test('invalidates dependent page when removed partial is restored '
            '(${filtered ? 'filtered' : 'unfiltered'})', () async {
          // Arrange the file system layout and content.
          final fileSystem = MemoryFileSystem();
          final pagesDir = fileSystem.directory('pages')..createSync();
          final loader = FilesystemLoader(
            'pages',
            filterExtensions: filtered ? {'.md'} : const {},
            fileSystem: fileSystem,
            watcherFactory: (_) => mockWatcher,
          );

          final partialPath = 'pages/_includes/header.html';
          final partialFile = fileSystem.file(partialPath)
            ..createSync(recursive: true)
            ..writeAsStringSync('Header');
          pagesDir.childFile('index.md')
            ..createSync()
            ..writeAsStringSync('Page content');

          // Initial load to activate the watcher.
          await loader.loadRoutes((_) => PageConfig(), false);

          final pageSource = loader.sources.firstWhere((s) => s.path == 'index.md');
          await pageSource.load();

          // Establish the original dependency, then remove the partial.
          loader.readPartialSync(partialPath, pageSource.page!);
          partialFile.deleteSync();
          eventController.add(WatchEvent(ChangeType.REMOVE, partialPath));
          await Future<void>.delayed(Duration.zero);

          // Simulate rebuilding and attempting to render while the partial is missing.
          final componentWithMissingPartial = await pageSource.load();
          expect(
            () => loader.readPartialSync(partialPath, pageSource.page!),
            throwsA(isA<FileSystemException>()),
          );

          // Act: Restore the partial and simulate its add event.
          partialFile
            ..createSync(recursive: true)
            ..writeAsStringSync('Restored header');
          eventController.add(WatchEvent(ChangeType.ADD, partialPath));
          await Future<void>.delayed(Duration.zero);

          // Assert: The failed page is invalidated and rebuilt.
          expect(pageSource.page, isNull);
          expect(await pageSource.load(), isNot(same(componentWithMissingPartial)));
        });
      }

      for (final eager in [false, true]) {
        test('invalidates dependent page when '
            'partial is removed (${eager ? 'eager' : 'lazy'})', () async {
          // Arrange the file system layout and content.
          final fileSystem = MemoryFileSystem();
          final pagesDir = fileSystem.directory('pages')..createSync();
          final loader = FilesystemLoader(
            'pages',
            fileSystem: fileSystem,
            watcherFactory: (_) => mockWatcher,
          );

          final partialPath = 'pages/_includes/header.html';
          final partialFile = fileSystem.file(partialPath)
            ..createSync(recursive: true)
            ..writeAsStringSync('Header');
          pagesDir.childFile('index.md')
            ..createSync()
            ..writeAsStringSync('Page content');

          // Initial load to activate the watcher.
          await loader.loadRoutes((_) => PageConfig(), eager);

          // Build the page once to cache the result.
          final pageSource = loader.sources.firstWhere((s) => s.path == 'index.md');
          final cachedComponent = await pageSource.load();

          // Establish dependency by reading the partial.
          loader.readPartialSync(partialPath, pageSource.page!);

          // Act: Delete the partial and simulate a remove event for it.
          partialFile.deleteSync();
          eventController.add(WatchEvent(ChangeType.REMOVE, partialPath));
          await Future<void>.delayed(Duration.zero);

          // Assert: The partial's source was removed.
          expect(loader.sources.any((source) => source.file.path == partialPath), isFalse);

          if (eager) {
            // In eager mode the dependent page is rebuilt immediately.
            expect(pageSource.page, isNotNull);
          } else {
            // In lazy mode the dependent page stays invalidated until requested.
            expect(pageSource.page, isNull);
          }

          // The dependent page is rebuilt instead of serving the cached result.
          expect(await pageSource.load(), isNot(same(cachedComponent)));
        });
      }
    });
  });
}
