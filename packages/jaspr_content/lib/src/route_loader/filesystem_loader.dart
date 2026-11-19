import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
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
/// Files and folders starting with an underscore (`_`) or a dot (`.`) don't get routes,
/// but can still be read as partials.
///
/// In debug mode, the loader watches [directory] while serving,
/// so that pages are added, removed, and rebuilt as their files
/// and the partials they read change.
///
/// To choose which files become pages and what their URLs are,
/// use [filterExtensions], [ignorePattern], and [keepSuffixPattern].
/// To load pages from another kind of source, extend [RouteLoaderBase] instead.
final class FilesystemLoader extends RouteLoaderBase<FilePageSource> {
  /// Creates a loader for the pages under [directory].
  ///
  /// If [debugPrint] is `true`, the routes are printed each time they're built.
  /// The [fileSystem] and [watcherFactory] are only meant to be replaced in tests.
  FilesystemLoader(
    this.directory, {
    this.filterExtensions = const {},
    this.keepSuffixPattern,
    this.ignorePattern,
    super.debugPrint,
    @visibleForTesting this.fileSystem = const LocalFileSystem(),
    @visibleForTesting DirectoryWatcherFactory? watcherFactory,
  }) : watcherFactory = watcherFactory ?? _defaultWatcherFactory;

  /// The directory to load pages from,
  /// either absolute or relative to the current working directory.
  final String directory;

  /// The extensions of the files to load as pages, including the leading dot, such as `'.md'`.
  ///
  /// If not empty, files under [directory] with other extensions are skipped,
  /// but can still be read as partials.
  final Set<String> filterExtensions;

  /// A pattern for the pages that keep the file extension in their URL,
  /// such as `/feed.xml` instead of `/feed`.
  ///
  /// A page keeps its extension when the pattern matches at the start of its path.
  /// Like for [ignorePattern], the path is relative to [directory]
  /// and written with forward slashes on every platform.
  final Pattern? keepSuffixPattern;

  /// A pattern for files that should not be loaded as pages.
  ///
  /// A file is skipped when the pattern matches at the start of its path.
  /// The path is relative to [directory] and written with forward slashes on every platform.
  /// For example, `RegExp(r'(.*/)?README\.md$')` skips every `README.md`,
  /// and `RegExp(r'drafts/.*')` skips everything below the top-level drafts folder.
  ///
  /// Like files excluded by [filterExtensions], ignored files can still be read as partials.
  final Pattern? ignorePattern;

  /// The file system that pages and partials are read from.
  @visibleForTesting
  final FileSystem fileSystem;

  /// The factory for the watcher that reports file changes in [directory].
  @visibleForTesting
  final DirectoryWatcherFactory watcherFactory;

  /// Creates a watcher for the directory at [path],
  /// as the default [watcherFactory].
  static DirectoryWatcher _defaultWatcherFactory(String path) => DirectoryWatcher(path);

  /// The page sources that read each partial, keyed by the path of the partial.
  final Map<String, Set<FilePageSource>> _dependentSources = {};

  /// The subscription to the file changes in [directory],
  /// or `null` when the directory is not being watched.
  StreamSubscription<WatchEvent>? _watcherSub;

  /// Loads the routes of the pages under [directory].
  ///
  /// In debug mode, this also starts watching the directory,
  /// so that pages are added, removed, and rebuilt as their files change.
  @override
  Future<List<RouteBase>> loadRoutes(
    ConfigResolver resolver,
    bool eager,
  ) async {
    if (kDebugMode) {
      _watcherSub ??= watcherFactory(directory).events.listen(_onFileEvent);
    }
    return super.loadRoutes(resolver, eager);
  }

  /// Adds, removes, or invalidates the page source of the file that [event] reports,
  /// and invalidates the pages that read the file as a partial.
  void _onFileEvent(WatchEvent event) {
    // It looks like event.path is relative on most platforms, but an
    // absolute path on Linux. Turn this into the expected relative path.
    final path = p.normalize(p.relative(event.path));

    if (event.type == ChangeType.ADD) {
      if (_createSource(fileSystem.file(path)) case final source?) {
        addSource(source);
      }
    } else if (_sourceForFile(path) case final source?) {
      if (event.type == ChangeType.REMOVE) {
        removeSource(source);
      } else {
        invalidateSource(source);
      }
    }

    // Pages can read any file as a partial, even one that isn't a page,
    // and might have failed to build while an added file was missing.
    // For a changed page, `invalidateSource` already did, so this finds nothing.
    _invalidateDependentSources(path);
  }

  /// Stops watching [directory] when the server is reassembled.
  ///
  /// The next call to [loadRoutes] starts watching it again.
  @override
  @protected
  void onReassemble() {
    _watcherSub?.cancel();
    _watcherSub = null;
  }

  /// Reads the partial at [path], which is absolute or
  /// relative to the current working directory.
  ///
  /// The [page] is invalidated when the file of the partial is
  /// later added, changed, or removed while serving.
  /// Since only [directory] is watched, this only happens for partials inside of it.
  /// Invalidation also requires [path] to be normalized and relative to
  /// the current working directory, such as `content/_includes/header.html`.
  @override
  Future<String> readPartial(String path, Page page) {
    return _getPartial(path, page).readAsString();
  }

  /// Synchronously reads the partial at [path].
  ///
  /// Like [readPartial], this makes the [page] depend on the partial.
  @override
  String readPartialSync(String path, Page page) {
    return _getPartial(path, page).readAsStringSync();
  }

  /// Returns the file of the partial at [path],
  /// recording the source of [page] as depending on it.
  File _getPartial(String path, Page page) {
    final pageSource = getSourceForPage(page);
    if (pageSource != null) {
      (_dependentSources[path] ??= {}).add(pageSource);
    }
    return fileSystem.file(path);
  }

  /// Creates a page source for each file under [directory],
  /// including those in nested folders,
  /// unless [filterExtensions] or [ignorePattern] skip the file.
  ///
  /// Returns no sources if the directory doesn't exist.
  @override
  @protected
  @visibleForTesting
  Future<List<FilePageSource>> loadPageSources() async {
    final root = fileSystem.directory(directory);
    if (!await root.exists()) {
      return [];
    }

    List<FilePageSource> loadFiles(Directory dir) {
      final List<FilePageSource> entities = [];
      for (final entry in dir.listSync()) {
        if (entry is File) {
          if (_createSource(entry) case final source?) {
            entities.add(source);
          }
        } else if (entry is Directory) {
          entities.addAll(loadFiles(entry));
        }
      }
      return entities;
    }

    return loadFiles(root);
  }

  /// Creates the page source for [file], or returns `null` if
  /// [filterExtensions] or [ignorePattern] skip it.
  FilePageSource? _createSource(File file) {
    // The path relative to the directory, with forward slashes on every platform.
    final path = p.posix.fromUri(
      fileSystem.path.toUri(fileSystem.path.relative(file.path, from: directory)),
    );
    if (filterExtensions.isNotEmpty && !filterExtensions.contains(p.posix.extension(path))) {
      return null;
    }
    if (ignorePattern?.matchAsPrefix(path) != null) {
      return null;
    }

    final keepSuffix = keepSuffixPattern?.matchAsPrefix(path) != null;
    return FilePageSource(path, file, this, keepSuffix: keepSuffix);
  }

  /// Finds the page source of the file at [path].
  FilePageSource? _sourceForFile(String path) {
    return sources.firstWhereOrNull((source) => source.file.path == path);
  }

  /// Removes [source] from the loader,
  /// and stops tracking it as a dependent of the partials it read.
  @override
  @protected
  void removeSource(FilePageSource source) {
    super.removeSource(source);
    _dependentSources.removeWhere((_, dependencies) {
      dependencies.remove(source);
      return dependencies.isEmpty;
    });
  }

  /// Invalidates [source] and the pages that read its file as a partial.
  @override
  @protected
  void invalidateSource(FilePageSource source) {
    super.invalidateSource(source);
    _invalidateDependentSources(source.file.path);
  }

  /// Invalidates the page sources that read the file at [path] as a partial.
  ///
  /// They stop being dependents of the partial until they read it again.
  void _invalidateDependentSources(String path) {
    final dependencies = _dependentSources.remove(path);
    if (dependencies == null) return;

    for (final dependent in dependencies) {
      invalidateSource(dependent);
    }
  }

  /// Invalidates all page sources and routes,
  /// and forgets which pages read which partials.
  @override
  @protected
  void invalidateAll() {
    super.invalidateAll();
    _dependentSources.clear();
  }
}

/// A page source that reads the content of its page from a [file].
///
/// A [FilesystemLoader] creates one for each file it loads as a page.
/// A custom [RouteLoaderBase] can also use it for pages that it reads from files.
final class FilePageSource extends PageSource {
  /// Creates a page source for [file] that belongs to [loader].
  ///
  /// The [path] determines the URL of the page and must use forward slashes.
  ///
  /// Unless [keepSuffix] is `true`, the URL of the page drops the file extension,
  /// and an index file gets the URL of its folder.
  FilePageSource(
    super.path,
    this.file,
    super.loader, {
    super.keepSuffix,
  });

  /// The file that the content of the page is read from.
  final File file;

  /// Creates the page from the current content of the [file].
  ///
  /// Throws a [FileSystemException] if the file can't be read.
  @override
  @protected
  Future<Page> buildPage() async {
    final content = await file.readAsString();

    return Page(
      path: path,
      url: url,
      content: content,
      config: config,
      loader: loader,
    );
  }
}
