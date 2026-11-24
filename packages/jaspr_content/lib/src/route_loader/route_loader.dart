/// @docImport 'filesystem_loader.dart';
/// @docImport 'github_loader.dart';
/// @docImport 'memory_loader.dart';
library;

import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:path/path.dart' as p;
import 'package:pool/pool.dart' show Pool;

import '../page.dart';
import '../secondary_output/secondary_output.dart';
import 'url_prefix.dart';

/// A loader that loads routes and creates pages.
///
/// `ContentApp` uses a [FilesystemLoader] for its `directory`.
/// To use other loaders, or several at once,
/// pass them to `ContentApp.custom` as `loaders`.
///
/// The package includes these built-in loaders:
///
/// - [FilesystemLoader], which loads pages from a directory on the file system.
/// - [GitHubLoader], which loads pages from a folder in a GitHub repository.
/// - [MemoryLoader], which creates pages from [MemoryPage]s defined in Dart code.
///
/// To load pages from another kind of source, extend [RouteLoaderBase],
/// which implements this interface.
abstract interface class RouteLoader {
  /// Loads the routes of the pages of this loader,
  /// and resolves the config of each page with [resolver].
  ///
  /// If [eager] is `true`, the pages are also loaded right away,
  /// so that each page can access the data of all other pages.
  Future<List<RouteBase>> loadRoutes(ConfigResolver resolver, bool eager);

  /// Reads the partial at [path] for [page].
  ///
  /// Partials are commonly used by template engines to include other files during rendering.
  /// Loaders can use [page] to rebuild it when the partial changes.
  Future<String> readPartial(String path, Page page);

  /// Synchronously reads the partial at [path] for [page].
  ///
  /// Like [readPartial], but for template engines that can't wait for a [Future].
  String readPartialSync(String path, Page page);

  /// Invalidates the given [page],
  /// so that it's rebuilt when it's next requested,
  /// or right away when loading eagerly.
  void invalidatePage(Page page);

  /// The pages that all loaders built and haven't invalidated,
  /// which each page can access when loading eagerly.
  static final List<Page> _pages = [];
}

/// A base class for [RouteLoader] implementations.
///
/// Subclasses implement [loadPageSources] to create a [PageSource] for each page,
/// and can update their sources later with the protected methods,
/// such as [addSource] and [invalidateSource].
/// Code outside of the loader rebuilds a page with [Page.markNeedsRebuild] instead.
abstract class RouteLoaderBase<T extends PageSource> implements RouteLoader {
  /// Creates a loader that prints its routes each time it builds them if [debugPrint] is `true`.
  ///
  /// If [urlPrefix] is set, the URL of each page starts with it.
  /// Throws an [ArgumentError] if [urlPrefix] isn't a valid prefix.
  RouteLoaderBase({this.debugPrint = false, this.urlPrefix}) {
    if (urlPrefix case final prefix?) {
      checkUrlPrefix(prefix);
    }
  }

  /// Whether to print the routes each time they're built.
  final bool debugPrint;

  /// The prefix of the URLs of all pages of this loader, such as `/docs/v2`,
  /// or `null` to not prefix them.
  ///
  /// The prefix is added in front of the URL that each page gets from its path.
  /// For example, with the prefix `/docs/v2`, the page at `guide/intro.md`
  /// gets the URL `/docs/v2/guide/intro`, and the page at `index.md` gets `/docs/v2`.
  ///
  /// Relative links in the content of the pages, such as `guide/intro`,
  /// still resolve from the root of the site with the built-in layouts,
  /// so links between the pages of this loader need to include the prefix,
  /// such as `/docs/v2/guide/intro`.
  ///
  /// The paths of the pages don't include the prefix,
  /// so patterns that match them, such as for [PageConfig.match],
  /// parsers, and secondary outputs, stay the same.
  /// To vary the config of the pages by their prefix,
  /// use [PageConfig.matchUrlPrefix] as the [ConfigResolver],
  /// or check [PageSource.loader] in a custom one.
  ///
  /// The prefix must start with a `/` and not end with one,
  /// and its segments can't be empty, `.`, or `..`.
  /// It can't contain `:`, `%`, or a character that URLs percent-encode,
  /// such as a space, `?`, `#`, or a non-ASCII letter,
  /// since routes can't match those characters as they are written.
  /// A `.` in the last segment, such as in `/docs/1.2`, isn't supported.
  final String? urlPrefix;

  /// The routes from the latest call to [loadRoutes],
  /// or `null` if they need to be created again.
  Future<List<RouteBase>>? _routes;

  /// The sources of this loader, or `null` if they need to be loaded again.
  List<T>? _sources;

  /// The sources of this loader, or an empty list if they aren't loaded yet.
  List<T> get sources => UnmodifiableListView(_sources ?? []);

  /// The resolver from the latest call to [loadRoutes].
  ConfigResolver? _resolver;

  /// The resolver of each page's config, from the latest call to [loadRoutes].
  ///
  /// Only available once [loadRoutes] was called.
  @protected
  ConfigResolver get resolver {
    assert(_resolver != null, 'Resolver not available, call loadRoutes first.');
    return _resolver!;
  }

  /// Whether the latest call to [loadRoutes] loads the pages eagerly.
  bool _eager = false;

  /// The subscription to [ServerApp.onReassemble],
  /// which discards all sources and routes once the server is reassembled.
  StreamSubscription<void>? _reassembleSub;

  /// Throws an [UnsupportedError], since this loader can't read partials.
  ///
  /// Loaders that can, such as [FilesystemLoader], override this.
  @override
  Future<String> readPartial(String path, Page page) {
    throw UnsupportedError('Reading partial files is not supported for $runtimeType');
  }

  /// Throws an [UnsupportedError], since this loader can't read partials.
  ///
  /// Loaders that can, such as [FilesystemLoader], override this.
  @override
  String readPartialSync(String path, Page page) {
    throw UnsupportedError('Reading partial files is not supported for $runtimeType');
  }

  /// Returns the source of this loader that built [page],
  /// or `null` if none of its sources did.
  @protected
  T? getSourceForPage(Page page) {
    return _sources?.firstWhereOrNull((source) => source.page == page);
  }

  /// Loads the routes for the sources from [loadPageSources],
  /// and resolves the config of each page with [resolver].
  ///
  /// Sources with a path segment that starts with `_` or `.` don't get a route.
  /// If [eager] is `true`, every page is also loaded right away.
  /// The routes are reused until [invalidateRoutes] or [invalidateAll] is called.
  @override
  @mustCallSuper
  Future<List<RouteBase>> loadRoutes(ConfigResolver resolver, bool eager) async {
    _reassembleSub ??= ServerApp.onReassemble.listen((_) {
      invalidateAll();
      onReassemble();
      _reassembleSub?.cancel();
      _reassembleSub = null;
    });

    _resolver = resolver;
    _eager = eager;

    return _routes ??= _buildRoutes();
  }

  /// Called when the server is reassembled, after [invalidateAll].
  ///
  /// Override this to release resources, such as file watchers,
  /// that the next call to [loadRoutes] can set up again.
  @protected
  void onReassemble() {}

  /// Creates a route for each source that isn't private,
  /// and one for each secondary output whose pattern matches its path.
  ///
  /// When loading eagerly, this also loads every routed page first.
  Future<List<RouteBase>> _buildRoutes() async {
    final sources = _sources ??= await loadPageSources();

    final List<RouteBase> routes = [];
    final List<T> eagerSources = [];

    for (final source in sources) {
      if (source.path.isEmpty || source.private) {
        continue;
      }

      final config = resolver(source);
      source.config = config;

      if (_eager) {
        eagerSources.add(source);
      }
      final pageBuilder = AsyncBuilder(builder: (_) => source.load());

      routes.add(Route(path: source.url, builder: (_, _) => pageBuilder));

      for (final output in config.secondaryOutputs) {
        if (output.pattern.matchAsPrefix(source.path) != null) {
          routes.add(
            Route(
              path: output.createRoute(source.url),
              builder: (_, _) => InheritedSecondaryOutput(builder: output.build, child: pageBuilder),
            ),
          );
        }
      }
    }

    // Use a pool to avoid running out of file descriptors.
    if (eagerSources.isNotEmpty) {
      const maxConcurrentLoads = 64;
      final pool = Pool(maxConcurrentLoads);
      await eagerSources.map((s) => pool.withResource(s.load)).wait;
      await pool.close();
    }

    if (debugPrint) {
      _printRoutes(routes);
    }

    return routes;
  }

  /// Creates the sources of all pages of this loader.
  ///
  /// Called when the routes are first loaded, and again after [invalidateAll].
  @protected
  Future<List<T>> loadPageSources();

  /// Invalidates the source of this loader that built [page], if any.
  @override
  void invalidatePage(Page page) {
    final source = getSourceForPage(page);
    if (source != null) {
      invalidateSource(source);
    }
  }

  /// Adds [source] to the sources of this loader,
  /// so that the next call to [loadRoutes] creates a route for it.
  @protected
  @mustCallSuper
  void addSource(T source) {
    _sources ??= [];
    _sources!.add(source);
    invalidateRoutes();
  }

  /// Removes [source] from the sources of this loader,
  /// so that the next call to [loadRoutes] no longer creates a route for it.
  ///
  /// Also discards the page that [source] built without rebuilding it,
  /// and reloads the browsers that show it while serving.
  @protected
  @mustCallSuper
  void removeSource(T source) {
    source.invalidate(rebuild: false);
    ServerApp.reloadClients(source.url);
    _sources?.remove(source);
    invalidateRoutes();
  }

  /// Discards the page that [source] built,
  /// and reloads the browsers that show it while serving.
  ///
  /// When loading eagerly, the page is rebuilt right away.
  @protected
  @mustCallSuper
  void invalidateSource(T source) {
    source.invalidate();
    ServerApp.reloadClients(source.url);
  }

  /// Makes the next call to [loadRoutes] create the routes again,
  /// such as after the sources changed.
  @protected
  @mustCallSuper
  void invalidateRoutes() {
    _routes = null;
  }

  /// Discards all sources and routes,
  /// so that the next call to [loadRoutes] loads them again.
  @protected
  @mustCallSuper
  void invalidateAll() {
    _sources = null;
    _routes = null;
    RouteLoader._pages.clear();
  }
}

/// The source of one page of a [RouteLoaderBase].
///
/// It builds the page with [buildPage] when the page is first loaded,
/// and reuses it until the source is invalidated.
/// To write a loader, extend this class and implement [buildPage].
abstract class PageSource {
  /// Creates a source for the page at [path] that belongs to [loader].
  ///
  /// The [path] determines the URL of the page and must use forward slashes.
  /// Unless [keepSuffix] is `true`, the URL of the page drops the file extension,
  /// and an index file gets the URL of its folder.
  /// The URL starts with the [RouteLoaderBase.urlPrefix] of [loader], if set.
  PageSource(this.path, this.loader, {bool keepSuffix = false})
    : assert(!path.contains(p.windows.separator), 'PageSource path must be in posix format (using forward slashes).'),
      assert(!p.posix.isAbsolute(path), 'PageSource path must be relative, such as `blog/post.md`.'),
      private = p.posix.split(path).any((segment) => segment.startsWith('_') || segment.startsWith('.')),
      url = _createUrl(path, loader.urlPrefix, keepSuffix: keepSuffix);

  /// Returns the URL of the page at [path], starting with [prefix] if it isn't `null`.
  static String _createUrl(String path, String? prefix, {required bool keepSuffix}) {
    var segments = p.posix.split(path);
    if (segments case [...final folders, final file] when !keepSuffix) {
      // An index file gets the URL of its folder, such as `/blog` for `blog/index.md`.
      // Other files drop their extension, such as `/blog/post` for `blog/post.md`.
      final name = p.posix.basenameWithoutExtension(file);
      segments = name == 'index' ? folders : [...folders, name];
    }

    // Without any segments, the URL is the prefix itself, such as `/docs` for `index.md`.
    if (segments.isEmpty) return prefix ?? '/';
    return '${prefix ?? ''}/${segments.join('/')}';
  }

  /// The path of the page, such as `blog/post.md`, written with forward slashes.
  ///
  /// Config patterns, such as for secondary outputs, match against it.
  /// It never includes the [RouteLoaderBase.urlPrefix] of the [loader].
  final String path;

  /// The URL of the page, such as `/blog/post`,
  /// derived from [path] and the [RouteLoaderBase.urlPrefix] of the [loader].
  final String url;

  /// Whether a segment of [path] starts with `_` or `.`,
  /// in which case the page doesn't get a route.
  final bool private;

  /// The loader that this source belongs to.
  final RouteLoaderBase loader;

  /// The config of the page, which the loader resolves when it loads the routes.
  PageConfig config = PageConfig();

  /// The page from the latest [load], or `null` if it isn't built yet or was invalidated.
  Page? _page;

  /// The result of the latest [load], reused until the source is invalidated.
  Future<Component>? _future;

  /// The page that this source built,
  /// or `null` if it isn't built yet or was invalidated.
  Page? get page => _page;

  /// Builds and renders the page of this source,
  /// or returns the result of an earlier call until the source is invalidated.
  ///
  /// If building the page fails, later calls fail with the same error
  /// until the source is invalidated.
  Future<Component> load() async {
    return _future ??= _loadPage();
  }

  /// Builds the page with [buildPage], makes it the current [page],
  /// and renders it with its path and URL added to its data.
  Future<Component> _loadPage() async {
    final newPage = await buildPage();

    if (_page != null) {
      RouteLoader._pages.remove(_page);
    }

    _page = newPage;
    RouteLoader._pages.add(newPage);

    // Preserve original data to reapply
    // after first specifying our provided data.
    final builtData = newPage.data;

    newPage.apply(
      data: <String, Object?>{
        'page': {'path': path, 'url': url},
      },
      mergeData: false,
    );
    newPage.apply(data: builtData);

    final child = Page.wrap(
      newPage,
      loader._eager ? UnmodifiableListView(RouteLoader._pages) : [],
      await newPage.render(),
    );

    return child;
  }

  /// Builds the page from the current content of this source.
  ///
  /// Called by [load] when the page isn't built yet or was invalidated.
  /// Subclasses implement this to read their content, such as from a file.
  @protected
  Future<Page> buildPage();

  /// Discards the page of this source, so that the next call to [load] builds it again.
  ///
  /// When the loader loads pages eagerly, the page is rebuilt right away,
  /// unless [rebuild] is `false`.
  @protected
  @mustCallSuper
  void invalidate({bool rebuild = true}) {
    if (_page != null) {
      RouteLoader._pages.remove(_page);
      _page = null;
    }
    _future = null;
    if (rebuild && loader._eager) {
      // Don't report a failed rebuild here,
      // such as for invalid front matter saved while serving.
      // The error is kept and surfaces when the page is requested.
      load().ignore();
    }
  }
}

/// Debugging helpers for route loaders.
extension _RouteLoaderExtension on RouteLoader {
  /// Prints the path of each of the [routes] and of their nested routes,
  /// indented by [padding].
  void _printRoutes(List<RouteBase> routes, [String padding = '']) {
    for (final route in routes) {
      if (route is Route) {
        print('$padding${route.path}');
        _printRoutes(route.routes, '$padding  ');
      }
    }
  }
}
