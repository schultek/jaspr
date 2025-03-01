import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:watcher/watcher.dart';

import '../page.dart';
import 'pages_loader.dart';

class FilesystemLoader implements PagesLoader {
  FilesystemLoader(
    this.directory, {
    this.eager = false,
    this.debugPrint = false,
  });

  final String directory;
  final bool eager;
  final bool debugPrint;

  final List<RouteBase> _routes = [];
  final Map<String, Future<Component>> _futures = {};

  final Map<String, (Page, Component)> _components = {};
  final List<Page> _pages = [];

  final Map<String, Set<String>> dependentPages = {};

  @override
  Future<List<RouteBase>> loadRoutes(ConfigResolver resolver) async {
    if (_resolver != resolver) {
      _resolver = resolver;
      _invalidateAll();
      _init(resolver);
    }
    if (eager) {
      await Future.wait(_futures.values);
    }
    return _routes;
  }

  @override
  File access(Uri path, Page page) {
    (dependentPages[path.toFilePath()] ??= {}).add(page.path);
    return File.fromUri(path);
  }

  ConfigResolver? _resolver;
  static StreamSubscription<WatchEvent>? _watchEvents;

  void _init(ConfigResolver resolver) {
    _futures.clear();
    _routes.clear();
    _routes.addAll(_loadRoutes(
      dir: Directory(directory),
      buildPage: (file) {
        final config = resolver(file.path);
        if (eager) {
          var future = _loadPage(file.path, config);
          _futures[file.path] = future;
          return AsyncBuilder(builder: (context) async* {
            yield await _futures[file.path]!;
          });
        } else {
          return AsyncBuilder(builder: (context) async* {
            yield await _loadPage(file.path, config);
          });
        }
      },
    ));

    if (kDebugMode) {
      _watchEvents?.cancel();
      _watchEvents = DirectoryWatcher(directory).events.listen((event) {
        var path = event.path;
        if (event.type == ChangeType.MODIFY) {
          invalidate(path);
        } else if (event.type == ChangeType.REMOVE) {
          invalidate(path, rebuild: false);
          _init(resolver);
        } else if (event.type == ChangeType.ADD) {
          _init(resolver);
        }
      });
    }
  }

  void add(String path, Page page, Component component) {
    var curr = _components[path];
    if (curr != null) {
      _pages.remove(curr.$1);
    }
    _components[path] = (page, component);
    _pages.add(page);
  }

  void invalidate(String path, {bool rebuild = true}) {
    var curr = _components.remove(path);
    if (curr != null) {
      _pages.remove(curr.$1);
    }
    if (_futures.remove(path) != null && rebuild && eager) {
      _futures[path] = _loadPage(path, _resolver?.call(path) ?? PageConfig());
    }
    final dependencies = {...?dependentPages[path]};
    dependentPages[path]?.clear();
    for (var dpath in dependencies) {
      invalidate(dpath, rebuild: rebuild);
    }
  }

  void _invalidateAll() {
    _components.clear();
    _pages.clear();
    dependentPages.clear();
  }

  Future<Component> _loadPage(String path, PageConfig config) async {
    var cached = _components[path]?.$2;
    if (cached != null) {
      return cached;
    }

    final file = File(path);
    final content = await file.readAsString();
    final data = {
      'page': {'path': path},
      if (eager) 'pages': UnmodifiableListView(_pages),
    };
    final page = Page(path, content, data, config, this);
    var child = Page.wrap(page, await config.pageBuilder(page));

    add(path, page, child);
    return child;
  }

  final indexRegex = RegExp(r'index\.[^/]*$');

  List<RouteBase> _loadRoutes({
    required Directory dir,
    required Component Function(PageSource) buildPage,
  }) {
    List<PageEntity> loadEntities(Directory dir) {
      List<PageEntity> entities = [];
      for (final entry in dir.listSync()) {
        final name = entry.path.substring(dir.path.length + 1);
        if (entry is File) {
          entities.add(PageSource(name, entry.path));
        } else if (entry is Directory) {
          entities.add(PageCollection(name, loadEntities(entry)));
        }
      }
      return entities;
    }

    return buildRoutes(
      entities: loadEntities(dir),
      buildPage: buildPage,
      debugPrint: debugPrint,
    );
  }
}
