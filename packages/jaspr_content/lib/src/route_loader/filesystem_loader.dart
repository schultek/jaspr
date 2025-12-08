import 'dart:async';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';

import '../page.dart';
import '../utils.dart';
import 'route_loader.dart';

/// A loader that loads routes from the filesystem.
///
/// Routes are constructed based on the recursive folder structure under the root [directory].
/// Index files (index.*) are treated as the page for the containing folder.
/// Files and folders starting with an underscore (_) are ignored.
class FilesystemLoader extends RouteLoaderBase {
  FilesystemLoader(
    this.directory, {
    this.keepSuffixPattern,
    super.debugPrint,
    @visibleForTesting this.fileSystem = const LocalFileSystem(),
    @visibleForTesting DirectoryWatcherFactory? watcherFactory,
  }) : watcherFactory = watcherFactory ?? _defaultWatcherFactory;

  /// The directory to load pages from.
  final String directory;

  /// A pattern to keep the file suffix for all matching pages.
  final Pattern? keepSuffixPattern;

  @visibleForTesting
  final FileSystem fileSystem;
  @visibleForTesting
  final DirectoryWatcherFactory watcherFactory;

  static DirectoryWatcher _defaultWatcherFactory(String path) => DirectoryWatcher(path);

  final Map<String, Set<PageSource>> dependentSources = {};

  StreamSubscription<WatchEvent>? _watcherSub;

  @override
  Future<List<RouteBase>> loadRoutes(ConfigResolver resolver, bool eager) async {
    if (kDebugMode) {
      _watcherSub ??= watcherFactory(directory).events.listen((event) {
        // It looks like event.path is relative on most platforms, but an
        // absolute path on Linux. Turn this into the expected relative path.
        final path = p.normalize(p.relative(event.path));
        if (event.type == ChangeType.MODIFY) {
          invalidateFile(path);
        } else if (event.type == ChangeType.REMOVE) {
          removeFile(path);
        } else if (event.type == ChangeType.ADD) {
          addFile(path);
        }
      });
    }
    return super.loadRoutes(resolver, eager);
  }

  @override
  void onReassemble() {
    _watcherSub?.cancel();
    _watcherSub = null;
  }

  @override
  Future<String> readPartial(String path, Page page) {
    return _getPartial(path, page).readAsString();
  }

  @override
  String readPartialSync(String path, Page page) {
    return _getPartial(path, page).readAsStringSync();
  }

  File _getPartial(String path, Page page) {
    final pageSource = getSourceForPage(page);
    if (pageSource != null) {
      (dependentSources[path] ??= {}).add(pageSource);
    }
    return fileSystem.file(path);
  }

  @override
  Future<List<PageSource>> loadPageSources() async {
    final root = fileSystem.directory(directory);
    if (!await root.exists()) {
      return [];
    }

    List<PageSource> loadFiles(Directory dir) {
      final List<PageSource> entities = [];
      for (final entry in dir.listSync()) {
        final path = entry.path.substring(root.path.length + 1);
        if (entry is File) {
          entities.add(
            FilePageSource(
              path,
              entry,
              this,
              keepSuffix: keepSuffixPattern?.matchAsPrefix(entry.path) != null,
              context: fileSystem.path,
            ),
          );
        } else if (entry is Directory) {
          entities.addAll(loadFiles(entry));
        }
      }
      return entities;
    }

    return loadFiles(root);
  }

  void addFile(String path) {
    addSource(
      FilePageSource(
        path.substring(directory.length + 1),
        fileSystem.file(path),
        this,
        keepSuffix: keepSuffixPattern?.matchAsPrefix(path) != null,
        context: fileSystem.path,
      ),
    );
  }

  void removeFile(String path) {
    final source = sources.whereType<FilePageSource>().where((source) => source.file.path == path).firstOrNull;
    if (source != null) {
      removeSource(source);
    }
  }

  void invalidateFile(String path, {bool rebuild = true}) {
    final source = sources.whereType<FilePageSource>().where((source) => source.file.path == path).firstOrNull;
    if (source != null) {
      invalidateSource(source, rebuild: rebuild);
    }
  }

  @override
  void invalidateSource(PageSource source, {bool rebuild = true}) {
    super.invalidateSource(source, rebuild: rebuild);
    final fullPath = fileSystem.path.join(directory, source.path);
    final dependencies = {...?dependentSources[fullPath]};
    dependentSources[fullPath]?.clear();
    for (final dependent in dependencies) {
      invalidateSource(dependent, rebuild: rebuild);
    }
  }

  @override
  void invalidateAll() {
    super.invalidateAll();
    dependentSources.clear();
  }
}

class FilePageSource extends PageSource {
  FilePageSource(super.path, this.file, super.loader, {super.keepSuffix, super.context});

  final File file;

  @override
  Future<Page> buildPage() async {
    final content = await file.readAsString();

    return Page(path: path, url: url, content: content, config: config, loader: loader);
  }
}
