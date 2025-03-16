import 'dart:async';
import 'dart:collection';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../page.dart';

/// A loader that loads pages and creates routes.
abstract class PageLoader {
  /// Loads the routes with the given [ConfigResolver].
  Future<List<RouteBase>> loadRoutes(ConfigResolver resolver);

  /// Reads a partial from the given [uri].
  Future<String> readPartial(Uri uri, Page page);
  /// Reads a partial from the given [uri] synchronously.
  String readPartialSync(Uri uri, Page page);
}

/// A base class for [PageLoader] implementations.
abstract class PageLoaderBase implements PageLoader {
  PageLoaderBase({
    this.eager = false,
    this.debugPrint = false,
  });

  final bool eager;
  final bool debugPrint;

  Future<List<RouteBase>> _routes = Future.value([]);

  final Map<String, PageFactory> _factories = {};

  final List<Page> pages = [];

  ConfigResolver? _resolver;
  ConfigResolver get resolver {
    assert(_resolver != null, 'Resolver not available, call loadRoutes first.');
    return _resolver!;
  }

  String getKeyForRoute(PageRoute route) {
    return route.route;
  }

  String? getKeyForPage(Page page) {
    return _factories.keys.where((k) => _factories[k]!.page == page).firstOrNull;
  }

  @override
  Future<List<RouteBase>> loadRoutes(ConfigResolver resolver) async {
    if (_resolver != resolver) {
      _resolver = resolver;
      invalidateAll();
      reload();
      didInit();
    }
    if (eager) {
      await Future.wait(_factories.values.map((v) => v.future).whereType<Future>());
    }
    return _routes;
  }

  void didInit() {}

  void reload() {
    _routes = _buildRoutes();
  }

  Future<List<RouteBase>> _buildRoutes() async {
    final entities = await loadPageEntities();
    return buildRoutesFromEntities(
      entities: entities,
      buildPage: (page) {
        final config = resolver(page.route);
        final factory = _factories[getKeyForRoute(page)] ??= createFactory(page);
        if (eager) {
          factory.future = factory.loadPage(config);
          return AsyncBuilder(builder: (context) async* {
            yield await factory.future!;
          });
        } else {
          return AsyncBuilder(builder: (context) async* {
            yield await factory.loadPage(config);
          });
        }
      },
      debugPrint: debugPrint,
    );
  }

  PageFactory createFactory(PageRoute page);

  Future<List<PageEntity>> loadPageEntities();

  void invalidate(String key, {bool rebuild = true}) {
    final factory = _factories[key];
    if (factory?.page case final page?) {
      pages.remove(page);
    }
    if (factory != null && rebuild && eager) {
      factory.future = factory.loadPage(_resolver?.call(factory.route.route) ?? PageConfig());
    }
  }

  void invalidateAll() {
    _factories.clear();
    pages.clear();
  }
}

abstract class PageFactory<T extends PageLoaderBase> {
  PageFactory(this.route, this.loader);

  final PageRoute route;
  final T loader;

  Page? page;
  Component? component;
  Future<Component>? future;

  Future<Component> loadPage(PageConfig config) async {
    if (component != null) {
      return component!;
    }

    final newPage = await buildPage(config);

    if (page != null) {
      loader.pages.remove(page);
    }

    page = newPage;
    loader.pages.add(newPage);

    var child = Page.wrap(newPage, UnmodifiableListView(loader.pages), await config.pageBuilder(newPage));

    component = child;
    return child;
  }

  Future<Page> buildPage(PageConfig config);
}

sealed class PageEntity {
  PageEntity(this.name);

  final String name;
}

class PageSource extends PageEntity {
  PageSource(super.name, this.source);

  final String source;
}

class PageCollection extends PageEntity {
  PageCollection(super.name, this.entities);

  final List<PageEntity> entities;
}

class PageRoute extends PageSource {
  PageRoute(super.name, super.source, this.route);

  final String route;
}

final indexRegex = RegExp(r'index\.[^/]*$');

extension PagesRepositoryExtension on PageLoader {
  List<RouteBase> buildRoutesFromEntities({
    required List<PageEntity> entities,
    required Component Function(PageRoute page) buildPage,
    bool debugPrint = false,
  }) {
    final routes = _buildRoutes(entities: entities, buildPage: buildPage);
    if (debugPrint) {
      _printRoutes(routes);
    }
    return routes;
  }

  List<RouteBase> _buildRoutes({
    required List<PageEntity> entities,
    required Component Function(PageRoute page) buildPage,
    String path = '',
    bool isTopLevel = true,
  }) {
    PageSource? indexFile;
    List<PageSource> files = [];
    List<PageCollection> subdirs = [];

    for (final entry in entities) {
      if (entry.name.startsWith('_')) continue;

      if (entry is PageSource) {
        final isIndex = indexRegex.hasMatch(entry.name);
        if (isIndex) {
          indexFile = entry;
        } else {
          files.add(entry);
        }
      } else if (entry is PageCollection) {
        subdirs.add(entry);
      }
    }

    List<RouteBase> routes = [];

    for (final file in files) {
      final routePath = (isTopLevel ? '/' : '') +
          (indexFile != null || path.isEmpty ? '' : '$path/') +
          file.name.replaceFirst(RegExp(r'\..*'), '');
      final child = buildPage(PageRoute(file.name, file.source, routePath));

      final route = Route(
        path: routePath,
        builder: (context, state) => child,
      );
      routes.add(route);
    }

    for (final subdir in subdirs) {
      final subRoutes = _buildRoutes(
        entities: subdir.entities,
        buildPage: buildPage,
        path: (isTopLevel ? '/' : '') + (indexFile == null && path.isNotEmpty ? '$path/' : '') + subdir.name,
        isTopLevel: false,
      );
      routes.addAll(subRoutes);
    }

    if (indexFile != null) {
      final routePath = (isTopLevel ? '/' : '') + path;
      final child = buildPage(PageRoute(indexFile.name, indexFile.source, routePath));

      final route = Route(
        path: routePath,
        builder: (context, state) => child,
        routes: isTopLevel ? [] : routes,
      );

      if (isTopLevel) {
        routes.insert(0, route);
      } else {
        routes = [route];
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
