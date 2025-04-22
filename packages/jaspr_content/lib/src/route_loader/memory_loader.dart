import 'dart:convert';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr/server.dart';

import '../page.dart';
import 'route_loader.dart';

/// A loader that loads routes from memory.
///
/// Takes a list of [MemoryPage]s and creates routes from them.
class MemoryLoader extends RouteLoaderBase {
  MemoryLoader({required List<MemoryPage> pages, super.debugPrint}) : _pages = pages;

  final List<MemoryPage> _pages;

  @override
  PageFactory createFactory(PageRoute route, PageConfig config) {
    final page = _pages.where((p) => p.path == route.path).first;
    return MemoryPageFactory(page, route, config, this);
  }

  @override
  Future<List<RouteEntity>> loadPageEntities() async {
    final entities = <RouteEntity>[];
    for (final page in _pages) {
      entities.add(SourceRoute(page.path, page.path, keepSuffix: true));
    }
    return entities;
  }

  @override
  Future<String> readPartial(String path, Page page) {
    throw UnsupportedError('Reading partial files is not supported for MemoryLoader');
  }

  @override
  String readPartialSync(String path, Page page) {
    throw UnsupportedError('Reading partial files is not supported for MemoryLoader');
  }
}

class MemoryPage {
  const MemoryPage({
    required this.path,
    this.content,
    this.data = const {},
  }) : builder = null;
  
  const MemoryPage.builder({
    required this.path,
    this.builder,
    this.data = const {},
  }) : content = null;

  final String path;
  final String? content;
  final Component Function(Page page)? builder;
  final Map<String, dynamic> data;
}

class MemoryPageFactory extends PageFactory {
  MemoryPageFactory(this._page, super.route, super.config, super.loader);

  final MemoryPage _page;

  @override
  Future<Page> buildPage() async {
    if (_page.builder != null) {
      return _BuilderPage(
        path: route.path,
        url: route.url,
        builder: _page.builder!,
        data: _page.data,
        config: config,
        loader: loader,
      );
    }
    return Page(
      path: route.path,
      url: route.url,
      content: _page.content ?? '',
      data: _page.data,
      config: config,
      loader: loader,
    );
  }
}

class _BuilderPage extends Page {
  _BuilderPage({
    required super.path,
    required super.url,
    required this.builder,
    required super.data,
    required super.config,
    required super.loader,
  }) : super(content: '');

  final Component Function(Page page) builder;

  @override
  Future<Component> build() async {
    await loadData();
    return AsyncBuilder(builder: (context) async* {
      if (kGenerateMode && data['page']['sitemap'] != null) {
        context.setHeader('jaspr-sitemap-data', jsonEncode(data['page']['sitemap']));
      }

      yield builder(this);
    });
  }
}
