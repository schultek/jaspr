import 'dart:async';
import 'dart:io';

import 'package:file/memory.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:watcher/watcher.dart';

import '../utils.dart';

void main() {
  group('FilesystemLoader', () {
    late MockDirectoryWatcher mockWatcher;
    late StreamController<WatchEvent> eventController;

    setUp(() {
      mockWatcher = MockDirectoryWatcher();
      eventController = StreamController<WatchEvent>.broadcast();
      addTearDown(eventController.close);
      when(() => mockWatcher.events).thenAnswer((_) => eventController.stream);
    });

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

      test('loads README files when no ignore pattern is set', () async {
        final fileSystem = MemoryFileSystem();
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('index.md').createSync();
        pagesDir.childFile('README.md').createSync();

        final loader = FilesystemLoader('pages', fileSystem: fileSystem);

        final sources = await loader.loadPageSources();

        expect(
          sources,
          unorderedEquals([
            pageSource('index.md', '/', private: false),
            pageSource('README.md', '/README', private: false),
          ]),
        );
      });

      test('skips files that match the ignore pattern at any depth', () async {
        final fileSystem = MemoryFileSystem();
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('index.md').createSync();
        pagesDir.childFile('README.md').createSync();
        fileSystem.directory('pages/blog').createSync();
        fileSystem.file('pages/blog/post-1.md').createSync();
        fileSystem.file('pages/blog/README.md').createSync();
        fileSystem.directory('pages/blog/2026').createSync();
        fileSystem.file('pages/blog/2026/recap.md').createSync();
        fileSystem.file('pages/blog/2026/README.md').createSync();

        final loader = FilesystemLoader(
          'pages',
          fileSystem: fileSystem,
          ignorePattern: RegExp(r'(.*/)?README\.md$'),
        );

        final sources = await loader.loadPageSources();

        expect(
          sources,
          unorderedEquals([
            pageSource('index.md', '/', private: false),
            pageSource('blog/post-1.md', '/blog/post-1', private: false),
            pageSource('blog/2026/recap.md', '/blog/2026/recap', private: false),
          ]),
        );
      });

      test('matches the ignore pattern from the start of the path only', () async {
        final fileSystem = MemoryFileSystem();
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('README.md').createSync();
        fileSystem.directory('pages/blog/drafts').createSync(recursive: true);
        fileSystem.file('pages/blog/README.md').createSync();
        fileSystem.file('pages/blog/drafts/wip.md').createSync();
        fileSystem.directory('pages/notes').createSync();
        fileSystem.file('pages/notes/a.md').createSync();

        // The last alternative matches only the first part of notes/a.md.
        final loader = FilesystemLoader(
          'pages',
          fileSystem: fileSystem,
          ignorePattern: RegExp(r'README\.md$|drafts/.*|notes/'),
        );

        final sources = await loader.loadPageSources();

        expect(
          sources,
          unorderedEquals([
            pageSource('blog/README.md', '/blog/README', private: false),
            pageSource('blog/drafts/wip.md', '/blog/drafts/wip', private: false),
          ]),
        );
      });

      test('skips every file below an ignored directory', () async {
        final fileSystem = MemoryFileSystem();
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('index.md').createSync();
        fileSystem.directory('pages/drafts/old').createSync(recursive: true);
        fileSystem.file('pages/drafts/wip.md').createSync();
        fileSystem.file('pages/drafts/old/idea.md').createSync();

        final loader = FilesystemLoader(
          'pages',
          fileSystem: fileSystem,
          ignorePattern: RegExp(r'drafts/.*'),
        );

        final sources = await loader.loadPageSources();

        expect(sources, equals([pageSource('index.md', '/', private: false)]));
      });

      test('matches the ignore pattern against forward slash paths on windows', () async {
        final fileSystem = MemoryFileSystem(style: FileSystemStyle.windows);
        final pagesDir = fileSystem.directory('pages')..createSync();
        pagesDir.childFile('index.md').createSync();
        fileSystem.directory(r'pages\blog').createSync();
        fileSystem.file(r'pages\blog\post-1.md').createSync();
        fileSystem.file(r'pages\blog\README.md').createSync();

        final loader = FilesystemLoader(
          'pages',
          fileSystem: fileSystem,
          ignorePattern: RegExp(r'blog/README\.md$'),
        );

        final sources = await loader.loadPageSources();

        expect(
          sources,
          unorderedEquals([
            pageSource('index.md', '/', private: false),
            pageSource('blog/post-1.md', '/blog/post-1', private: false),
          ]),
        );
      });
    });

    group('File Watching', () {
      late FilesystemLoader loader;

      test('does not add a source for an ignored file on file add event', () async {
        // Arrange
        final fileSystem = MemoryFileSystem();
        fileSystem.directory('pages').createSync();
        loader = FilesystemLoader(
          'pages',
          fileSystem: fileSystem,
          ignorePattern: RegExp(r'(.*/)?README\.md$|drafts/'),
          watcherFactory: (_) => mockWatcher,
        );
        await loader.loadRoutes((_) => PageConfig(), false);

        // Act
        fileSystem.file('pages/README.md').createSync();
        eventController.add(WatchEvent(ChangeType.ADD, 'pages/README.md'));
        fileSystem.file('pages/blog/README.md').createSync(recursive: true);
        eventController.add(WatchEvent(ChangeType.ADD, 'pages/blog/README.md'));
        fileSystem.file('pages/drafts/wip.md').createSync(recursive: true);
        eventController.add(WatchEvent(ChangeType.ADD, 'pages/drafts/wip.md'));
        fileSystem.file('pages/about.md').createSync();
        eventController.add(WatchEvent(ChangeType.ADD, 'pages/about.md'));
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(loader.sources.map((source) => source.url), equals(['/about']));
      });

      test('does not add a source for an ignored file on file add event on windows', () async {
        // Arrange
        final fileSystem = MemoryFileSystem(style: FileSystemStyle.windows);
        fileSystem.directory('pages').createSync();
        loader = FilesystemLoader(
          'pages',
          fileSystem: fileSystem,
          ignorePattern: RegExp(r'(.*/)?README\.md$|drafts/'),
          watcherFactory: (_) => mockWatcher,
        );
        await loader.loadRoutes((_) => PageConfig(), false);

        // Act
        fileSystem.file(r'pages\README.md').createSync();
        eventController.add(WatchEvent(ChangeType.ADD, r'pages\README.md'));
        fileSystem.file(r'pages\blog\README.md').createSync(recursive: true);
        eventController.add(WatchEvent(ChangeType.ADD, r'pages\blog\README.md'));
        fileSystem.file(r'pages\drafts\wip.md').createSync(recursive: true);
        eventController.add(WatchEvent(ChangeType.ADD, r'pages\drafts\wip.md'));
        fileSystem.file(r'pages\about.md').createSync();
        eventController.add(WatchEvent(ChangeType.ADD, r'pages\about.md'));
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(loader.sources.map((source) => source.url), equals(['/about']));
      });

      for (final windows in [false, true]) {
        for (final directory in windows ? ['pages', r'.\pages', r'C:\pages'] : ['pages', './pages', '/pages']) {
          final suffix = 'when the directory is given as $directory${windows ? ' on windows' : ''}';

          // The watcher reports absolute paths on some platforms.
          test('finds the source of a changed file $suffix', () async {
            // Arrange
            final fileSystem = MemoryFileSystem(style: windows ? FileSystemStyle.windows : FileSystemStyle.posix);
            final filePath = fileSystem.path.join('pages', 'about.md');
            fileSystem.file(filePath)
              ..createSync(recursive: true)
              ..writeAsStringSync('Page content');
            loader = FilesystemLoader(directory, fileSystem: fileSystem, watcherFactory: (_) => mockWatcher);

            await loader.loadRoutes((_) => PageConfig(), false);
            final source = loader.sources.single;
            await source.load();

            // Act and assert: A modify event invalidates the page.
            eventController.add(WatchEvent(ChangeType.MODIFY, filePath));
            await Future<void>.delayed(Duration.zero);
            expect(source.page, isNull);

            // Act and assert: A remove event reported by absolute path removes the source.
            eventController.add(WatchEvent(ChangeType.REMOVE, fileSystem.path.absolute(filePath)));
            await Future<void>.delayed(Duration.zero);
            expect(loader.sources, isEmpty);
          });

          test('finds the source of an added file $suffix', () async {
            // Arrange
            final fileSystem = MemoryFileSystem(style: windows ? FileSystemStyle.windows : FileSystemStyle.posix);
            fileSystem.directory('pages').createSync();
            loader = FilesystemLoader(directory, fileSystem: fileSystem, watcherFactory: (_) => mockWatcher);
            await loader.loadRoutes((_) => PageConfig(), false);
            expect(loader.sources, isEmpty);

            // Act and assert: An add event adds the source.
            final filePath = fileSystem.path.join('pages', 'about.md');
            fileSystem.file(filePath)
              ..createSync()
              ..writeAsStringSync('Page content');
            eventController.add(WatchEvent(ChangeType.ADD, filePath));
            await Future<void>.delayed(Duration.zero);
            final source = loader.sources.single;
            expect(source.url, equals('/about'));
            await source.load();

            // Act and assert: A modify event reported by absolute path invalidates the page.
            eventController.add(WatchEvent(ChangeType.MODIFY, fileSystem.path.absolute(filePath)));
            await Future<void>.delayed(Duration.zero);
            expect(source.page, isNull);

            // Act and assert: A remove event removes the source.
            eventController.add(WatchEvent(ChangeType.REMOVE, filePath));
            await Future<void>.delayed(Duration.zero);
            expect(loader.sources, isEmpty);
          });
        }
      }

      test('discards the page of a removed source without rebuilding it', () async {
        // Arrange: Load the page eagerly, so that a rebuild would happen right away.
        final fileSystem = MemoryFileSystem();
        fileSystem.file('pages/index.md')
          ..createSync(recursive: true)
          ..writeAsStringSync('Page content');
        loader = FilesystemLoader('pages', fileSystem: fileSystem, watcherFactory: (_) => mockWatcher);
        await loader.loadRoutes((_) => PageConfig(), true);
        final source = loader.sources.single;
        expect(source.page, isNotNull);

        // Act: Report the file as removed. It still exists, so a rebuild would succeed.
        eventController.add(WatchEvent(ChangeType.REMOVE, 'pages/index.md'));
        await Future<void>.delayed(Duration.zero);

        // Assert: The source is removed, and its page is discarded without being rebuilt.
        expect(loader.sources, isEmpty);
        expect(source.page, isNull);
      });

      test('surfaces the error of a failed eager rebuild when the page is requested', () async {
        // Arrange
        final fileSystem = MemoryFileSystem();
        fileSystem.file('pages/index.md')
          ..createSync(recursive: true)
          ..writeAsStringSync('---\ntitle: Valid\n---\nPage content');
        loader = FilesystemLoader('pages', fileSystem: fileSystem, watcherFactory: (_) => mockWatcher);
        await loader.loadRoutes((_) => PageConfig(), true);

        // Act: Save invalid front matter, so the eager rebuild fails.
        fileSystem.file('pages/index.md').writeAsStringSync('---\ntitle: [unclosed\n---\nPage content');
        eventController.add(WatchEvent(ChangeType.MODIFY, 'pages/index.md'));
        await Future<void>.delayed(Duration.zero);

        // Assert: The error isn't uncaught, which would fail this test,
        // but surfaces when the page is loaded.
        await expectLater(loader.sources.single.load(), throwsException);
      });
    });

    group('urlPrefix', () {
      test('prefixes the URLs of loaded and added pages', () async {
        // Arrange: Mount the pages under /docs/v1, and keep the suffix of blog posts.
        final fileSystem = MemoryFileSystem();
        fileSystem.file('pages/index.md').createSync(recursive: true);
        final loader = FilesystemLoader(
          'pages',
          keepSuffixPattern: RegExp('blog/'),
          urlPrefix: '/docs/v1',
          fileSystem: fileSystem,
          watcherFactory: (_) => mockWatcher,
        );

        // Act and assert: The root index page gets the prefix as its URL.
        await loader.loadRoutes((_) => PageConfig(), false);
        expect(loader.sources, equals([pageSource('index.md', '/docs/v1')]));

        // Act and assert: An added page gets a prefixed URL, but its path doesn't change,
        // so keepSuffixPattern matches it without the prefix.
        fileSystem.file('pages/blog/post.md').createSync(recursive: true);
        eventController.add(WatchEvent(ChangeType.ADD, 'pages/blog/post.md'));
        await Future<void>.delayed(Duration.zero);
        expect(
          loader.sources,
          equals([pageSource('index.md', '/docs/v1'), pageSource('blog/post.md', '/docs/v1/blog/post.md')]),
        );
      });

      test('mounts directories with the same page paths under different prefixes', () async {
        // Arrange: Two versions with the same pages, each with its own asset manager.
        final fileSystem = MemoryFileSystem();
        for (final version in ['v1', 'v2']) {
          fileSystem.file('docs/$version/guide/intro.md')
            ..createSync(recursive: true)
            ..writeAsStringSync('---\ncover: cover.png\n---\nIntro');
        }
        final v1 = FilesystemLoader(
          'docs/v1',
          urlPrefix: '/docs',
          fileSystem: fileSystem,
          watcherFactory: (_) => mockWatcher,
        );
        final v2 = FilesystemLoader(
          'docs/v2',
          urlPrefix: '/docs/v2',
          fileSystem: fileSystem,
          watcherFactory: (_) => mockWatcher,
        );
        final config = PageConfig(
          dataLoaders: [
            for (final (loader, version) in [(v1, 'v1'), (v2, 'v2')])
              AssetManager(
                directory: 'docs/$version',
                outputPrefix: 'assets/$version',
                dataProperties: {'page.cover'},
                filterPages: (page) => page.loader == loader,
              ).dataLoader,
          ],
        );

        // Act and assert: The pages share a path, but not a URL.
        await v1.loadRoutes((_) => config, false);
        await v2.loadRoutes((_) => config, false);
        expect(v1.sources, equals([pageSource('guide/intro.md', '/docs/guide/intro')]));
        expect(v2.sources, equals([pageSource('guide/intro.md', '/docs/v2/guide/intro')]));

        // Act and assert: Each page resolves its assets with the asset manager of its loader.
        final v1Intro = v1.sources.single;
        final v2Intro = v2.sources.single;
        await v1Intro.load();
        await v2Intro.load();
        expect(v1Intro.page!.data.page, containsPair('cover', '/assets/v1/guide/cover.png'));
        expect(v2Intro.page!.data.page, containsPair('cover', '/assets/v2/guide/cover.png'));
      });
    });

    group('Partials and Dependencies', () {
      for (final eager in [false, true]) {
        test(
          'invalidates the pages that read a page as a partial when it is marked for rebuild '
          '(${eager ? 'eager' : 'lazy'})',
          () async {
            // Arrange: Load the pages, and let the index page read the header page as a partial.
            final fileSystem = MemoryFileSystem();
            final pagesDir = fileSystem.directory('pages')..createSync();
            pagesDir.childFile('header.md').writeAsStringSync('Header');
            pagesDir.childFile('index.md').createSync();
            pagesDir.childFile('other.md').createSync();
            final loader = FilesystemLoader('pages', fileSystem: fileSystem, watcherFactory: (_) => mockWatcher);
            await loader.loadRoutes((_) => PageConfig(), eager);
            final header = loader.sources.singleWhere((source) => source.path == 'header.md');
            final index = loader.sources.singleWhere((source) => source.path == 'index.md');
            final other = loader.sources.singleWhere((source) => source.path == 'other.md');
            await header.load();
            final cachedIndex = await index.load();
            final cachedOther = await other.load();
            loader.readPartialSync(fileSystem.path.join('pages', 'header.md'), index.page!);

            // Act: Mark the header page for rebuild, such as after its data changed.
            header.page!.markNeedsRebuild();

            // Assert: The index page is rebuilt, but the other page isn't.
            expect(await index.load(), isNot(same(cachedIndex)));
            expect(await other.load(), same(cachedOther));
          },
        );
      }

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

      test('invalidates dependent page when an ignored partial is added', () async {
        // Arrange the file system layout and content.
        final fileSystem = MemoryFileSystem();
        final pagesDir = fileSystem.directory('pages')..createSync();
        final loader = FilesystemLoader(
          'pages',
          ignorePattern: RegExp(r'(.*/)?README\.md$'),
          fileSystem: fileSystem,
          watcherFactory: (_) => mockWatcher,
        );
        pagesDir.childFile('index.md')
          ..createSync()
          ..writeAsStringSync('Page content');

        // Initial load to activate the watcher.
        await loader.loadRoutes((_) => PageConfig(), false);
        final pageSource = loader.sources.single;
        await pageSource.load();

        // The page reads the partial while it is missing.
        expect(
          () => loader.readPartialSync('pages/README.md', pageSource.page!),
          throwsA(isA<FileSystemException>()),
        );

        // Act: Create the partial and simulate its add event.
        fileSystem.file('pages/README.md')
          ..createSync()
          ..writeAsStringSync('Readme');
        eventController.add(WatchEvent(ChangeType.ADD, 'pages/README.md'));
        await Future<void>.delayed(Duration.zero);

        // Assert: The page is invalidated, and the partial is not a page source.
        expect(pageSource.page, isNull);
        expect(loader.sources, hasLength(1));

        // The rebuilt page can read the partial.
        await pageSource.load();
        expect(loader.readPartialSync('pages/README.md', pageSource.page!), equals('Readme'));
      });

      test('invalidates dependent page when an ignored partial is added on windows', () async {
        // Arrange the file system layout and content.
        final fileSystem = MemoryFileSystem(style: FileSystemStyle.windows);
        final pagesDir = fileSystem.directory('pages')..createSync();
        final loader = FilesystemLoader(
          'pages',
          ignorePattern: RegExp(r'(.*/)?README\.md$'),
          fileSystem: fileSystem,
          watcherFactory: (_) => mockWatcher,
        );
        pagesDir.childFile('index.md')
          ..createSync()
          ..writeAsStringSync('Page content');

        // Initial load to activate the watcher.
        await loader.loadRoutes((_) => PageConfig(), false);
        final pageSource = loader.sources.single;
        await pageSource.load();

        // The page reads the partial while it is missing.
        expect(
          () => loader.readPartialSync(r'pages\README.md', pageSource.page!),
          throwsA(isA<FileSystemException>()),
        );

        // Act: Create the partial and simulate its add event.
        fileSystem.file(r'pages\README.md')
          ..createSync()
          ..writeAsStringSync('Readme');
        eventController.add(WatchEvent(ChangeType.ADD, r'pages\README.md'));
        await Future<void>.delayed(Duration.zero);

        // Assert: The page is invalidated, and the partial is not a page source.
        expect(pageSource.page, isNull);
        expect(loader.sources, hasLength(1));

        // The rebuilt page can read the partial.
        await pageSource.load();
        expect(loader.readPartialSync(r'pages\README.md', pageSource.page!), equals('Readme'));
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

      for (final windows in [false, true]) {
        for (final filtered in [false, true]) {
          // A partial can be read by an absolute path, such as with an absolute Liquid includesPath.
          for (final absolute in [false, true]) {
            test(
              'invalidates dependent page when ${filtered ? 'an excluded' : 'an ignored'} partial '
              '${absolute ? 'read by absolute path ' : ''}changes${windows ? ' on windows' : ''}',
              () async {
                // Arrange the file system layout and content.
                final fileSystem = MemoryFileSystem(style: windows ? FileSystemStyle.windows : FileSystemStyle.posix);
                final pagesDir = fileSystem.directory('pages')..createSync();
                final loader = FilesystemLoader(
                  'pages',
                  filterExtensions: filtered ? {'.md'} : const {},
                  ignorePattern: filtered ? null : RegExp(r'(.*/)?README\.md$'),
                  fileSystem: fileSystem,
                  watcherFactory: (_) => mockWatcher,
                );

                final partialPath = fileSystem.path.join('pages', filtered ? 'header.html' : 'README.md');
                fileSystem.file(partialPath)
                  ..createSync()
                  ..writeAsStringSync('Old');
                pagesDir.childFile('index.md')
                  ..createSync()
                  ..writeAsStringSync('Page content');

                // Initial load to activate the watcher.
                await loader.loadRoutes((_) => PageConfig(), false);
                final pageSource = loader.sources.single;
                await pageSource.load();

                // Establish dependency by reading the partial.
                final readPath = absolute ? fileSystem.path.absolute(partialPath) : partialPath;
                expect(loader.readPartialSync(readPath, pageSource.page!), equals('Old'));

                // Act: Simulate a modify event on the partial, reported by relative path.
                eventController.add(WatchEvent(ChangeType.MODIFY, partialPath));
                await Future<void>.delayed(Duration.zero);

                // Assert: The page was invalidated.
                expect(pageSource.page, isNull);
              },
            );
          }
        }
      }

      test('keeps a page that did not read a changed partial that is not a page source', () async {
        // Arrange the file system layout and content.
        final fileSystem = MemoryFileSystem();
        final pagesDir = fileSystem.directory('pages')..createSync();
        final loader = FilesystemLoader(
          'pages',
          ignorePattern: RegExp(r'(.*/)?README\.md$'),
          fileSystem: fileSystem,
          watcherFactory: (_) => mockWatcher,
        );
        fileSystem.file('pages/README.md')
          ..createSync()
          ..writeAsStringSync('Old');
        pagesDir.childFile('index.md')
          ..createSync()
          ..writeAsStringSync('Page content');

        // Initial load to activate the watcher. The page never reads the partial.
        await loader.loadRoutes((_) => PageConfig(), false);
        final pageSource = loader.sources.single;
        await pageSource.load();

        // Act: Simulate a modify event on the partial.
        eventController.add(WatchEvent(ChangeType.MODIFY, 'pages/README.md'));
        await Future<void>.delayed(Duration.zero);

        // Assert: The page was not invalidated.
        expect(pageSource.page, isNotNull);
      });

      test('keeps a page that did not read a changed partial that is not a page source on windows', () async {
        // Arrange the file system layout and content.
        final fileSystem = MemoryFileSystem(style: FileSystemStyle.windows);
        final pagesDir = fileSystem.directory('pages')..createSync();
        final loader = FilesystemLoader(
          'pages',
          ignorePattern: RegExp(r'(.*/)?README\.md$'),
          fileSystem: fileSystem,
          watcherFactory: (_) => mockWatcher,
        );
        fileSystem.file(r'pages\README.md')
          ..createSync()
          ..writeAsStringSync('Old');
        pagesDir.childFile('index.md')
          ..createSync()
          ..writeAsStringSync('Page content');

        // Initial load to activate the watcher. The page never reads the partial.
        await loader.loadRoutes((_) => PageConfig(), false);
        final pageSource = loader.sources.single;
        await pageSource.load();

        // Act: Simulate a modify event on the partial.
        eventController.add(WatchEvent(ChangeType.MODIFY, r'pages\README.md'));
        await Future<void>.delayed(Duration.zero);

        // Assert: The page was not invalidated.
        expect(pageSource.page, isNotNull);
      });

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
