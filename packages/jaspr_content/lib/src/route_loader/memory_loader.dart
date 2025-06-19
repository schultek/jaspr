import 'dart:convert';

import 'package:jaspr/server.dart';

import '../page.dart';
import 'route_loader.dart';

/// A loader that loads routes from memory.
///
/// Takes a list of [MemoryPage]s and creates routes from them.
class MemoryLoader extends RouteLoaderBase {
  MemoryLoader({required List<MemoryPage> pages, super.debugPrint})
    : _pages = pages;

  final List<MemoryPage> _pages;

  @override
  Future<List<PageSource>> loadPageSources() async {
    final entities = <PageSource>[];
    for (final page in _pages) {
      entities.add(
        MemoryPageSource(page, page.path, this, keepSuffix: page.keepSuffix),
      );
    }
    return entities;
  }
}

/// A page that is loaded from memory.
///
/// This can be used to programmatically create pages.
///
/// - Use `MemoryPage()` to create a normal page from a content String.
/// - Use `MemoryPage.builder()` to create a page from a component builder function.
class MemoryPage {
  /// Creates a new [MemoryPage] with the given [path] and [content].
  ///
  /// Optionally takes initial [data] to pass to the page.
  const MemoryPage({
    required this.path,
    this.keepSuffix = false,
    this.content,
    this.data = const {},
  }) : builder = null,
       applyLayout = true;

  /// Creates a new [MemoryPage] with the given [path] and builds it using the [builder].
  ///
  /// This is a special case where the page has no content, but is built using the [builder] function.
  /// Therefore, the any template engine, parsers or extensions will not be used. The layout and theme
  /// will only be applied if [applyLayout] is set to true (default).
  ///
  /// Optionally takes initial [data] to pass to the page.
  const MemoryPage.builder({
    required this.path,
    this.keepSuffix = false,
    this.builder,
    this.applyLayout = true,
    this.data = const {},
  }) : content = null;

  /// The path to the page.
  final String path;

  /// Whether to keep the suffix of the page.
  final bool keepSuffix;

  /// The content of the page.
  final String? content;

  /// A builder function to create the page.
  final Component Function(Page page)? builder;

  /// Whether to apply a layout to the page.
  final bool applyLayout;

  /// The initial data to pass to the page.
  final Map<String, dynamic> data;
}

class MemoryPageSource extends PageSource {
  MemoryPageSource(
    this._page,
    super.path,
    super.loader, {
    super.keepSuffix = false,
  });

  final MemoryPage _page;

  @override
  Future<Page> buildPage() async {
    if (_page.builder != null) {
      return _BuilderPage(
        path: this.path,
        url: url,
        builder: _page.builder!,
        applyLayout: _page.applyLayout,
        data: _page.data,
        config: config,
        loader: loader,
      );
    }
    return Page(
      path: this.path,
      url: url,
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
    required this.applyLayout,
    required super.data,
    required super.config,
    required super.loader,
  }) : super(content: '');

  final Component Function(Page page) builder;
  final bool applyLayout;

  @override
  Page copy() {
    return _BuilderPage(
      path: this.path,
      url: url,
      builder: builder,
      applyLayout: applyLayout,
      data: data,
      config: config,
      loader: loader,
    );
  }

  @override
  Future<Component> render() async {
    await loadData();
    return Builder.single(
      builder: (context) {
        if (kGenerateMode && data['page']['sitemap'] != null) {
          context.setHeader(
            'jaspr-sitemap-data',
            jsonEncode(data['page']['sitemap']),
          );
        }

        final child = builder(this);

        if (applyLayout) {
          final layout = buildLayout(child);
          return wrapTheme(layout);
        }

        return child;
      },
    );
  }
}
