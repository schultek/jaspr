import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../page.dart';
import 'pages_loader.dart';

class GithubLoader implements PagesLoader {
  GithubLoader(
    this.repo, {
    this.ref = 'main',
    this.path = 'docs',
    this.accessToken,
    this.eager = false,
    this.debugPrint = false,
  });

  final String repo;
  final String ref;
  final String path;
  final String? accessToken;
  final bool eager;
  final bool debugPrint;

  Future<List<RouteBase>> _routes = Future.value([]);
  final Map<String, Future<Component>> _futures = {};

  final Map<String, (Page, Component)> _components = {};
  final List<Page> _pages = [];

  @override
  Future<List<RouteBase>> loadRoutes(ConfigResolver resolver) async {
    if (_resolver != resolver) {
      _resolver = resolver;
      _init(resolver);
    }
    if (eager) {
      await Future.wait(_futures.values);
    }
    return _routes;
  }

  @override
  File access(Uri path, Page page) {
    throw UnsupportedError('Accessing partial files is not supported for GithubLoader');
  }

  ConfigResolver? _resolver;

  void _init(ConfigResolver resolver) {
    _futures.clear();
    _routes = _loadRoutes(
      root: path,
      buildPage: (file) {
        final config = resolver(file.path);
        if (eager) {
          var future = _loadPage(file, config);
          _futures[file.path] = future;
          return AsyncBuilder(builder: (context) async* {
            yield await _futures[file.path]!;
          });
        } else {
          return AsyncBuilder(builder: (context) async* {
            yield await _loadPage(file, config);
          });
        }
      },
    );
  }

  void add(String url, Page page, Component component) {
    var curr = _components[url];
    if (curr != null) {
      _pages.remove(curr.$1);
    }
    _components[url] = (page, component);
    _pages.add(page);
  }

  Future<Component> _loadPage(PageSource file, PageConfig config) async {
    var cached = _components[file.path]?.$2;
    if (cached != null) {
      return cached;
    }

    final response = await http.get(Uri.parse(file.url!), headers: {
      'Accept': 'application/vnd.github.raw+json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      'X-GitHub-Api-Version': '2022-11-28',
    });
    final content = response.body;
    final data = {
      'page': {'path': file.path},
      if (eager) 'pages': UnmodifiableListView(_pages),
    };

    final page = Page(file.path, content, data, config, this);
    var child = Page.wrap(page, await config.pageBuilder(page));

    add(file.path, page, child);
    return child;
  }

  Future<List<dynamic>> _loadTree() async {
    var response = await http.get(
      Uri.parse('https://api.github.com/repos/$repo/git/trees/$ref?recursive=true'),
      headers: {
        'Accept': 'application/vnd.github+json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load tree: ${response.statusCode} - ${response.body}');
    }
    var files = jsonDecode(response.body)['tree'] as List;
    return files;
  }

  final indexRegex = RegExp(r'index\.[^/]*$');

  Future<List<RouteBase>> _loadRoutes({
    required String root,
    required Component Function(PageSource) buildPage,
  }) async {
    var files = await _loadTree();

    Map<String, dynamic> tree = {};

    for (final file in files) {
      if (file['type'] != 'blob') continue;
      var path = file['path'];

      if (!file['path'].startsWith(root)) continue;
      path = path.substring(root.length);
      if (path.startsWith('/')) path = path.substring(1);
      if (path.isEmpty) continue;

      var segments = path.split('/');

      var current = tree;
      for (var i = 0; i < segments.length - 1; i++) {
        var segment = segments[i];
        current = (current[segment] ??= <String, dynamic>{});
      }
      current[segments.last] = PageSource(segments.last, path, file['url']);
    }

    PageEntity? getEntity(MapEntry<String, dynamic> entry) {
      if (entry.value case PageSource file) {
        return file;
      } else if (entry.value case Map<String, dynamic> map) {
        return PageCollection(entry.key, map.entries.map(getEntity).whereType<PageEntity>().toList());
      } else {
        return null;
      }
    }

    final entities = tree.entries.map(getEntity).whereType<PageEntity>().toList();

    return buildRoutes(
      entities: entities,
      buildPage: buildPage,
      debugPrint: debugPrint,
    );
  }
}
