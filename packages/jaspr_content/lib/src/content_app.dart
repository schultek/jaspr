import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:watcher/watcher.dart';

import '../jaspr_content.dart';

class ContentApp extends AsyncStatelessComponent {
  ContentApp({
    this.directory = 'content',
    this.eagerlyLoadAllPages = false,
    this.routerBuilder = _defaultRouterBuilder,
    this.config,
    required this.builders,
    this.debugPrint = false,
  }) : _cache = PagesCache(
          directory,
          eager: eagerlyLoadAllPages,
          config: config,
          builders: builders,
          debugPrint: debugPrint,
        );

  final String directory;
  final bool eagerlyLoadAllPages;
  final Component Function(List<RouteBase> routes) routerBuilder;
  final PageConfig? config;
  final List<PageBuilder> builders;
  final bool debugPrint;

  final PagesCache _cache;

  @override
  Stream<Component> build(BuildContext context) async* {
    final routes = await _cache.routes;
    yield routerBuilder(routes);
  }
}

Component _defaultRouterBuilder(List<RouteBase> routes) {
  return Router(routes: routes);
}

class PagesCache {
  PagesCache(
    this.directory, {
    this.eager = false,
    this.config,
    required this.builders,
    this.debugPrint = false,
  }) {
    _init();
    if (kDebugMode) {
      _watchEvents?.cancel();
      _watchEvents = DirectoryWatcher(directory).events.listen((event) {
        var path = event.path;
        print("CHANGE FILE: $path ${event.type}");
        if (event.type == ChangeType.MODIFY) {
          invalidate(path);
        } else if (event.type == ChangeType.REMOVE) {
          invalidate(path, rebuild: false);
          _init();
        } else if (event.type == ChangeType.ADD) {
          _init();
        }
      });
    }
  }

  static StreamSubscription<WatchEvent>? _watchEvents;

  final String directory;
  final bool eager;
  final PageConfig? config;
  final List<PageBuilder> builders;
  final bool debugPrint;

  final List<RouteBase> _routes = [];
  final Map<String, Future<Component>> _futures = {};

  final Map<String, (Page, Component)> _components = {};
  final List<Page> _pages = [];

  final Map<String, Set<String>> dependentPages = {};

  void _add(String path, Page page, Component component) {
    var curr = _components[path];
    if (curr != null) {
      _pages.remove(curr.$1);
    }
    _components[path] = (page, component);
    _pages.add(page);
  }

  void invalidate(String path, {bool rebuild = true}) {
    print("INVALIDATE $path");
    var curr = _components.remove(path);
    if (curr != null) {
      _pages.remove(curr.$1);
    }
    if (_futures.remove(path) != null && rebuild && eager) {
      _futures[path] = _buildPage(path);
    }
    final dependencies = {...?dependentPages[path]};
    dependentPages[path]?.clear();
    for (var dpath in dependencies) {
      invalidate(dpath, rebuild: rebuild);
    }
  }

  Future<List<RouteBase>> get routes async {
    if (eager) {
      await Future.wait(_futures.values);
    }
    return _routes;
  }

  void _init() {
    _futures.clear();
    _routes.clear();
    _routes.addAll(_loadRoutes(
      dir: Directory(directory),
      buildPage: (path) {
        if (eager) {
          var future = _buildPage(path);
          _futures[path] = future;
          return AsyncBuilder(builder: (context) async* {
            yield await _futures[path]!;
          });
        } else {
          return AsyncBuilder(builder: (context) async* {
            yield await _buildPage(path);
          });
        }
      },
    ));
    if (debugPrint) {
      _printRoutes(_routes);
    }
  }

  Future<Component> _buildPage(String path) async {
    var cached = _components[path]?.$2;
    if (cached != null) {
      return cached;
    }

    print(("READ FILE", path));
    final file = File(path);
    final content = await file.readAsString();
    final data = {
      'page': {'path': path},
      if (eager) 'pages': UnmodifiableListView(_pages),
    };
    final page = Page(path, content, data, config ?? PageConfig(), this);
    var child = Page.wrap(page, await _buildPage2(page));

    _add(path, page, child);
    return child;
  }

  Future<Component> _buildPage2(Page page) {
    final builder = builders.where((builder) => builder.suffix.any((s) => page.path.endsWith(s))).firstOrNull;
    if (builder == null) {
      throw Exception('No suffix builder found for path: $path');
    }

    return builder.buildPage(page);
  }
}

List<RouteBase> _loadRoutes({
  required Directory dir,
  required Component Function(String) buildPage,
  String path = '',
  bool isTopLevel = true,
}) {
  print("LOAD ROUTES");
  Route? index;
  var routes = <RouteBase>[];

  var hasIndex = File('${dir.path}/index.md').existsSync();

  for (final entry in dir.listSync()) {
    final name = entry.path.substring(dir.path.length + 1);

    if (name.startsWith('_')) continue;

    if (entry is File) {
      final isIndex = RegExp(r'index\..*$').hasMatch(name);
      final child = buildPage(entry.path);

      final route = Route(
        path: (isTopLevel ? '/' : '') +
            (isIndex ? path : ((hasIndex || path.isEmpty ? '' : '$path/') + name.replaceFirst(RegExp(r'\..*'), ''))),
        builder: (context, state) => child,
      );
      if (isIndex) {
        index = route;
      } else {
        routes.add(route);
      }
    }
    if (entry is Directory) {
      final subRoutes = _loadRoutes(
        dir: entry,
        buildPage: buildPage,
        path: '${isTopLevel ? '/' : ''}${!hasIndex && path.isNotEmpty ? '$path/' : ''}$name',
        isTopLevel: false,
      );
      routes.addAll(subRoutes);
    }
  }

  if (isTopLevel) {
    return [
      if (index != null) index,
      ...routes,
    ];
  }

  assert(!hasIndex || index != null);
  if (index != null) {
    assert(hasIndex);
    return [
      Route(
        path: index.path,
        builder: index.builder,
        routes: routes,
      )
    ];
  } else {
    assert(!hasIndex);
    return routes;
  }
}

void _printRoutes(List<RouteBase> routes, [String padding = '']) {
  for (final route in routes) {
    if (route is Route) {
      print('$padding${route.path}');
      _printRoutes(route.routes, '$padding  ');
    }
  }
}
