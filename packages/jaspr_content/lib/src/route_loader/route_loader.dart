/// @docImport 'filesystem_loader.dart';
/// @docImport 'github_loader.dart';
/// @docImport 'memory_loader.dart';
library;

import 'dart:async';
import 'dart:collection';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../page.dart';
import '../secondary_output/secondary_output.dart';

/// A loader that loads routes and creates pages.
///
/// See also:
/// - [FilesystemLoader]
/// - [GithubLoader]
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

  final Map<String, PageFactory> _factories = {};

  ConfigResolver? _resolver;
  ConfigResolver get resolver {
    assert(_resolver != null, 'Resolver not available, call loadRoutes first.');
    return _resolver!;
  }

  bool _eager = false;

  StreamSubscription? _reassembleSub;

  String getKeyForRoute(PageRoute route) {
    return route.url;
  }

  String? getKeyForPage(Page page) {
    return _factories.keys.where((k) => _factories[k]!.page == page).firstOrNull;
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
    if (eager) {
      await Future.wait(_factories.values.map((v) => v.future).whereType<Future>());
    }
    return _routes ?? [];
  }

  void onReassemble() {}

  Future<List<RouteBase>> _buildRoutes() async {
    final entities = await loadPageEntities();
    return buildRoutesFromEntities(
      entities: entities,
      buildRoute: (route) {
        final config = resolver(route);
        final factory = _factories[getKeyForRoute(route)] ??= createFactory(route, config);

        if (_eager) {
          factory.future = factory.loadPage();
        }
        final pageBuilder = AsyncBuilder(builder: (context) async* {
          if (_eager) {
            yield await factory.future!;
          } else {
            yield await factory.loadPage();
          }
        });

        final routes = <RouteBase>[];

        routes.add(Route(
          path: route.url,
          builder: (_, __) => pageBuilder,
          routes: route.routes,
        ));

        for (final output in config.secondaryOutputs) {
          if (output.pattern.matchAsPrefix(route.path) != null) {
            routes.add(Route(
              path: output.createRoute(route.url),
              builder: (_, __) => InheritedSecondaryOutput(
                builder: output.build,
                child: pageBuilder,
              ),
            ));
          }
        }

        return routes;
      },
      debugPrint: debugPrint,
    );
  }

  PageFactory createFactory(PageRoute route, PageConfig config);

  Future<List<RouteEntity>> loadPageEntities();

  @override
  void invalidatePage(Page page) {
    final key = getKeyForPage(page);
    if (key != null) {
      invalidateKey(key);
    }
  }

  void invalidateKey(String key, {bool rebuild = true}) {
    final factory = _factories[key];
    factory?.invalidate(rebuild: rebuild);
  }

  void invalidateRoutes() {
    _routes = null;
  }

  void invalidateAll() {
    _factories.clear();
    _routes = null;
    RouteLoader._pages.clear();
  }
}

abstract class PageFactory<T extends RouteLoaderBase> {
  PageFactory(this.route, this.config, this.loader);

  final PageRoute route;
  final PageConfig config;
  final T loader;

  Page? page;
  Component? component;
  Future<Component>? future;

  Future<Component> loadPage() async {
    if (component != null) {
      return component!;
    }

    final newPage = await buildPage();

    if (page != null) {
      RouteLoader._pages.remove(page);
    }

    page = newPage;
    RouteLoader._pages.add(newPage);

    newPage.apply(
      data: <String, dynamic>{
        'page': {'path': route.path, 'url': route.url},
      }.merge(newPage.data),
      mergeData: false,
    );

    var child = Page.wrap(
      newPage,
      loader._eager ? UnmodifiableListView(RouteLoader._pages) : [],
      await newPage.build(),
    );

    component = child;
    return child;
  }

  Future<Page> buildPage();

  void invalidate({bool rebuild = true}) {
    if (page != null) {
      RouteLoader._pages.remove(page);
      page = null;
    }
    component = null;
    if (rebuild && loader._eager) {
      future = loadPage();
    } else {
      future = null;
    }
  }
}

sealed class RouteEntity {
  RouteEntity(this.path);

  final String path;
}

class SourceRoute extends RouteEntity {
  SourceRoute(super.path, this.source, {this.keepSuffix = false});

  final String source;
  final bool keepSuffix;
}

class CollectionRoute extends RouteEntity {
  CollectionRoute(super.path, this.entities);

  final List<RouteEntity> entities;
}

class PageRoute extends SourceRoute {
  PageRoute(super.path, super.source, this.url, this.routes);

  final String url;
  final List<RouteBase> routes;
}

final indexRegex = RegExp(r'index\.[^/]*$');

extension RouteLoaderExtension on RouteLoader {
  List<RouteBase> buildRoutesFromEntities({
    required List<RouteEntity> entities,
    required List<RouteBase> Function(PageRoute route) buildRoute,
    bool debugPrint = false,
  }) {
    final routes = _buildRoutes(entities: entities, buildRoute: buildRoute);
    if (debugPrint) {
      _printRoutes(routes);
    }
    return routes;
  }

  List<RouteBase> _buildRoutes({
    required List<RouteEntity> entities,
    required List<RouteBase> Function(PageRoute route) buildRoute,
    String path = '',
    bool isTopLevel = true,
  }) {
    SourceRoute? indexFile;
    List<SourceRoute> files = [];
    List<CollectionRoute> subdirs = [];

    for (final entry in entities) {
      if (entry.path.startsWith('_')) continue;

      if (entry is SourceRoute) {
        final isIndex = indexRegex.hasMatch(entry.path);
        if (isIndex) {
          indexFile = entry;
        } else {
          files.add(entry);
        }
      } else if (entry is CollectionRoute) {
        subdirs.add(entry);
      }
    }

    List<RouteBase> routes = [];

    for (final file in files) {
      var filePath = file.path;
      if (!file.keepSuffix) {
        filePath = filePath.replaceFirst(RegExp(r'\.[^/]*$'), '');
      }
      final routePath = (isTopLevel ? '/' : '') + (indexFile != null || path.isEmpty ? '' : '$path/') + filePath;
      final result = buildRoute(PageRoute(file.path, file.source, routePath, []));

      routes.addAll(result);
    }

    for (final subdir in subdirs) {
      final subRoutes = _buildRoutes(
        entities: subdir.entities,
        buildRoute: buildRoute,
        path: (isTopLevel ? '/' : '') + (indexFile == null && path.isNotEmpty ? '$path/' : '') + subdir.path,
        isTopLevel: false,
      );
      routes.addAll(subRoutes);
    }

    if (indexFile != null) {
      final routePath = (isTopLevel ? '/' : '') + path;
      final result = buildRoute(PageRoute(
        indexFile.path,
        indexFile.source,
        routePath,
        isTopLevel ? [] : routes,
      ));

      if (isTopLevel) {
        routes.insertAll(0, result);
      } else {
        routes = [...result];
      }
    }

    return routes;
  }

  void _printRoutes(List<RouteBase> routes, [String padding = '']) {
    for (final route in routes) {
      if (route is Route) {
        print('$padding${route.path}');
        _printRoutes(route.routes, '$padding  ');
      }
    }
  }
}
