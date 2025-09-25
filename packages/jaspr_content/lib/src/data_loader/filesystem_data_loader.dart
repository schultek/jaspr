import 'dart:async';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:jaspr/server.dart';
import 'package:watcher/watcher.dart';

import '../page.dart';
import '../utils.dart';
import 'data_loader.dart';

/// A data loader that loads data from the filesystem.
class FilesystemDataLoader implements DataLoader {
  factory FilesystemDataLoader(
    String directory, {
    @visibleForTesting FileSystem fileSystem = const LocalFileSystem(),
    @visibleForTesting DirectoryWatcherFactory? watcherFactory,
  }) {
    return _instance[directory] ??= FilesystemDataLoader._(
      directory,
      fileSystem,
      watcherFactory ?? _defaultWatcherFactory,
    );
  }

  static DirectoryWatcher _defaultWatcherFactory(String path) => DirectoryWatcher(path);

  static final Map<String, FilesystemDataLoader> _instance = {};

  @visibleForTesting
  static void reset() {
    for (var loader in _instance.values) {
      loader._watcherSub?.cancel();
      loader._reassembleSub?.cancel();
    }
    _instance.clear();
  }

  FilesystemDataLoader._(this.directory, this.fileSystem, this.watcherFactory);

  final String directory;
  @visibleForTesting
  final FileSystem fileSystem;
  @visibleForTesting
  final DirectoryWatcherFactory watcherFactory;

  StreamSubscription<WatchEvent>? _watcherSub;
  StreamSubscription<void>? _reassembleSub;
  Future<Map<String, Object?>>? _data;

  final Set<Page> _pages = {};

  @override
  Future<void> loadData(Page page) async {
    if (!await fileSystem.directory(directory).exists()) {
      return;
    }

    if (kDebugMode) {
      _watcherSub ??= watcherFactory(directory).events.listen((event) {
        _data = null;
        for (var page in _pages) {
          page.markNeedsRebuild();
        }
        _pages.clear();
        _watcherSub?.cancel();
        _watcherSub = null;
      });

      _reassembleSub ??= ServerApp.onReassemble.listen((_) {
        _data = null;
        _pages.clear();
        _watcherSub?.cancel();
        _watcherSub = null;
        _reassembleSub?.cancel();
        _reassembleSub = null;
      });
    }

    _data ??= _loadData(fileSystem.directory(directory));
    _pages.add(page);

    var pageData = page.data.page;
    page.apply(data: await _data);
    page.apply(data: {'page': pageData});
  }

  Future<Map<String, Object?>> _loadData(Directory dir) async {
    final data = <String, Object?>{};
    if (await dir.exists()) {
      await for (var entity in dir.list()) {
        if (entity is File) {
          final name = entity.path.split(fileSystem.path.separator).last;
          final key = name.split('.').first;
          data[key] = DataLoader.parseData(name, await entity.readAsString());
        } else if (entity is Directory) {
          final key = entity.path.split(fileSystem.path.separator).last;
          data[key] = await _loadData(entity);
        }
      }
    }
    return data;
  }
}
