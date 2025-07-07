/// @docImport 'filesystem_loader.dart';
/// @docImport 'github_loader.dart';
/// @docImport 'memory_loader.dart';
library;

import 'dart:async';
import 'dart:collection';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:path/path.dart' as pkg_path;

import '../page.dart';
import '../secondary_output/secondary_output.dart';

/// A loader that loads routes and creates pages.
///
/// See also:
/// - [FilesystemLoader]
/// - [GitHubLoader]
/// - [MemoryLoader]
abstract class RouteLoader {
  /// Loads the routes with the given [ConfigResolver].
  Future<List<RouteBase>> loadRoutes(ConfigResolver resolver, bool eager);

  /// Reads a partial from the given [path].
  ///
  /// Partials are commonly used by templating engines to include other files during rendering.
  Future<String> readPartial(String path, Page page);

  /// Reads a partial from the given [path] synchronously.
  ///
  /// Partials are commonly used by templating engines to include other files during rendering.
  String readPartialSync(String path, Page page);

  /// Invalidates the given [page].
  ///
  /// This will cause the page to be rebuilt
  /// - when next accessed in lazy mode, or
  /// - immediately in eager mode.
  void invalidatePage(Page page);

  static final List<Page> _pages = [];
}

/// A base class for [RouteLoader] implementations.
abstract class RouteLoaderBase implements RouteLoader {
  RouteLoaderBase({
    this.debugPrint = false,
  });

  final bool debugPrint;

  Future<List<RouteBase>>? _routes;
  List<PageSource>? _sources;
  List<PageSource> get sources => UnmodifiableListView(_sources ?? []);

  ConfigResolver? _resolver;
  ConfigResolver get resolver {
    assert(_resolver != null, 'Resolver not available, call loadRoutes first.');
    return _resolver!;
  }

  bool _eager = false;

  StreamSubscription<void>? _reassembleSub;

  @override
  Future<String> readPartial(String path, Page page) {
    throw UnsupportedError('Reading partial files is not supported for $runtimeType');
  }

  @override
  String readPartialSync(String path, Page page) {
    throw UnsupportedError('Reading partial files is not supported for $runtimeType');
  }

  PageSource? getSourceForPage(Page page) {
    return _sources?.where((s) => s.page == page).firstOrNull;
  }

  @override
  Future<List<RouteBase>> loadRoutes(ConfigResolver resolver, bool eager) async {
    _reassembleSub ??= ServerApp.onReassemble.listen((_) {
      invalidateAll();
      onReassemble();
      _reassembleSub?.cancel();
      _reassembleSub = null;
    });

    _resolver = resolver;
    _eager = eager;

    _routes ??= _buildRoutes();
    if (eager && _sources != null) {
      await Future.wait([
        for (final s in _sources!) s.onLoad,
      ]);
    }
    return _routes ?? [];
  }

  void onReassemble() {}

  Future<List<RouteBase>> _buildRoutes() async {
    final sources = _sources ??= await loadPageSources();

    List<RouteBase> routes = [];
    for (final source in sources) {
      if (source.path.isEmpty || source.private) {
        continue;
      }

      final config = resolver(source);
      source.config = config;

      if (_eager) {
        source.load();
      }
      final pageBuilder = AsyncBuilder(builder: (_) => source.load());

      routes.add(Route(
        path: source.url,
        builder: (_, __) => pageBuilder,
      ));

      for (final output in config.secondaryOutputs) {
        if (output.pattern.matchAsPrefix(source.path) != null) {
          routes.add(Route(
            path: output.createRoute(source.url),
            builder: (_, __) => InheritedSecondaryOutput(
              builder: output.build,
              child: pageBuilder,
            ),
          ));
        }
      }
    }

    if (debugPrint) {
      _printRoutes(routes);
    }

    return routes;
  }

  Future<List<PageSource>> loadPageSources();

  @override
  void invalidatePage(Page page) {
    final source = getSourceForPage(page);
    if (source != null) {
      invalidateSource(source);
    }
  }

  void addSource(PageSource source) {
    _sources ??= [];
    _sources!.add(source);
    invalidateRoutes();
  }

  void removeSource(PageSource source) {
    _sources?.remove(source);
    invalidateRoutes();
  }

  void invalidateSource(PageSource source, {bool rebuild = true}) {
    source.invalidate(rebuild: rebuild);
  }

  void invalidateRoutes() {
    _routes = null;
  }

  void invalidateAll() {
    _sources = null;
    _routes = null;
    RouteLoader._pages.clear();
  }
}

final indexRegex = RegExp(r'index\.[^/]*$');

abstract class PageSource {
  PageSource(this.path, this.loader, {bool keepSuffix = false, pkg_path.Context? context}) {
    final segments = (context ?? pkg_path.context).split(path);

    private = segments.any((s) => s.startsWith('_') || s.startsWith('.'));

    if (segments.isEmpty) {
      url = '/';
      return;
    }

    if (segments.first.isEmpty) {
      segments.removeAt(0);
    }
    if (segments.last.isEmpty) {
      segments.removeLast();
    }

    if (!keepSuffix) {
      final isIndex = indexRegex.hasMatch(segments.last);
      if (isIndex) {
        segments.removeLast();
      } else {
        segments.last = segments.last.replaceFirst(RegExp(r'\.[^/]*$'), '');
      }
    }

    url = '/${segments.join('/')}';
  }

  final String path;
  late final String url;
  late final bool private;
  final RouteLoaderBase loader;

  PageConfig config = PageConfig();

  Page? _page;
  Future<Component>? _future;

  Page? get page => _page;
  Future<void> get onLoad => _future ?? Future.value();

  Future<Component> load() async {
    _future ??= loadPage();
    return _future!;
  }

  Future<Component> loadPage() async {
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

    var child = Page.wrap(
      newPage,
      loader._eager ? UnmodifiableListView(RouteLoader._pages) : [],
      await newPage.render(),
    );

    return child;
  }

  Future<Page> buildPage();

  void invalidate({bool rebuild = true}) {
    if (_page != null) {
      RouteLoader._pages.remove(_page);
      _page = null;
    }
    _future = null;
    if (rebuild && loader._eager) {
      load();
    }
  }
}

extension RouteLoaderExtension on RouteLoader {
  void _printRoutes(List<RouteBase> routes, [String padding = '']) {
    for (final route in routes) {
      if (route is Route) {
        print('$padding${route.path}');
        _printRoutes(route.routes, '$padding  ');
      }
    }
  }
}
