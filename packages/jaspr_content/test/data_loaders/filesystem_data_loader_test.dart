import 'dart:async';

import 'package:file/memory.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:watcher/watcher.dart';

import '../utils.dart';

void main() {
  late MemoryFileSystem fileSystem;
  late MockRouteLoader mockLoader;
  late MockDirectoryWatcher mockWatcher;
  late StreamController<WatchEvent> eventController;

  setUp(() {
    fileSystem = MemoryFileSystem();
    mockLoader = MockRouteLoader();

    mockWatcher = MockDirectoryWatcher();
    eventController = StreamController<WatchEvent>.broadcast();
    when(() => mockWatcher.events).thenAnswer((_) => eventController.stream);

    FilesystemDataLoader.reset();
  });

  group('FilesystemDataLoader', () {
    test('loads data from json and yaml files', () async {
      // Arrange
      final dataDir = fileSystem.directory('_data')..createSync();
      dataDir.childFile('site.json').writeAsStringSync('{"name": "My Site"}');
      dataDir.childFile('user.yaml').writeAsStringSync('name: Test User');

      final loader = FilesystemDataLoader(
        '_data',
        fileSystem: fileSystem,
        watcherFactory: (_) => mockWatcher,
      );
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: '',
        config: PageConfig(dataLoaders: [loader]),
        loader: mockLoader,
      );

      // Act
      await page.loadData();

      // Assert
      expect(
          page.data,
          equals({
            'site': {'name': 'My Site'},
            'user': {'name': 'Test User'},
            'page': <String, Object?>{},
          }));
    });

    test('loads data from nested directories', () async {
      // Arrange
      final navDir = fileSystem.directory('_data/nav')..createSync(recursive: true);
      navDir.childFile('main.json').writeAsStringSync('{"items": []}');

      final loader = FilesystemDataLoader(
        '_data',
        fileSystem: fileSystem,
        watcherFactory: (_) => mockWatcher,
      );
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: '',
        config: PageConfig(dataLoaders: [loader]),
        loader: mockLoader,
      );

      // Act
      await page.loadData();

      // Assert
      expect(
          page.data,
          equals({
            'nav': {
              'main': {'items': <Object?>[]}
            },
            'page': <String, Object?>{},
          }));
    });

    test('does nothing if data directory does not exist', () async {
      // Arrange
      final loader = FilesystemDataLoader('_data', fileSystem: fileSystem);
      final page = Page(
        path: 'test.md',
        url: '/test',
        content: '',
        initialData: {'a': 1},
        config: PageConfig(dataLoaders: [loader]),
        loader: mockLoader,
      );

      // Act
      await page.loadData();

      // Assert
      expect(page.data, equals({'a': 1}));
    });

    group('File Watching', () {
      test('calls markNeedsRebuild on registered pages when a file changes', () async {
        // Arrange
        fileSystem.directory('_data').createSync();
        final loader = FilesystemDataLoader(
          '_data',
          fileSystem: fileSystem,
          watcherFactory: (_) => mockWatcher,
        );

        final page1 = MockPage();
        when(() => page1.data).thenReturn({'page': <String, Object?>{}} as PageDataMap);
        when(() => page1.config).thenReturn(PageConfig(dataLoaders: [loader]));
        when(() => page1.markNeedsRebuild()).thenReturn(null);

        final page2 = MockPage();
        when(() => page2.data).thenReturn({'page': <String, Object?>{}} as PageDataMap);
        when(() => page2.config).thenReturn(PageConfig(dataLoaders: [loader]));
        when(() => page2.markNeedsRebuild()).thenReturn(null);

        // Act
        await loader.loadData(page1);
        await loader.loadData(page2);

        eventController.add(WatchEvent(ChangeType.MODIFY, '_data/site.json'));
        await Future<void>.delayed(Duration.zero); // Allow stream to propagate

        // Assert
        verify(() => page1.markNeedsRebuild()).called(1);
        verify(() => page2.markNeedsRebuild()).called(1);
      });

      test('reloads data after a file change', () async {
        // Arrange
        final dataDir = fileSystem.directory('_data')..createSync();
        final siteFile = dataDir.childFile('site.json')..writeAsStringSync('{"version": 1}');

        final loader = FilesystemDataLoader(
          '_data',
          fileSystem: fileSystem,
          watcherFactory: (_) => mockWatcher,
        );

        final page1 = Page(
          path: '',
          url: '',
          content: '',
          config: PageConfig(dataLoaders: [loader]),
          loader: mockLoader,
        );
        await page1.loadData();
        expect(page1.data['site'], equals({'version': 1}));

        // Act
        eventController.add(WatchEvent(ChangeType.MODIFY, '_data/site.json'));
        await Future<void>.delayed(Duration.zero);

        siteFile.writeAsStringSync('{"version": 2}');
        final page2 = Page(
          path: '',
          url: '',
          content: '',
          config: PageConfig(dataLoaders: [loader]),
          loader: mockLoader,
        );
        await page2.loadData();

        // Assert
        expect(page2.data['site'], equals({'version': 2}));
      });
    });
  });
}
