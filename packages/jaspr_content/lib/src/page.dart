import 'dart:async';
import 'dart:io';

import 'package:fbh_front_matter/fbh_front_matter.dart' as fm;
import 'package:jaspr/jaspr.dart';

import 'page_extension/page_extension.dart';
import 'page_layout/page_layout.dart';
import 'page_parser/page_parser.dart';
import 'pages_loader/pages_loader.dart';
import 'template_engine/template_engine.dart';

class Page {
  Page(this.path, this.content, this.data, this.config, this._repository);

  final String path;
  String content;
  Map<String, dynamic> data;
  final PageConfig config;

  final PagesLoader _repository;

  void apply({String? content, Map<String, dynamic>? data, bool mergeData = true}) {
    this.content = content ?? this.content;
    if (mergeData && data != null) {
      this.data = this.data.merge(data);
    } else {
      this.data = data ?? this.data;
    }
  }

  static Component wrap(Page page, List<Page> pages, Component child) {
    return _InheritedPage(page: page, pages: pages, child: child);
  }

  File access(Uri path) {
    return _repository.access(path, this);
  }
}

class PageConfig {
  const PageConfig({
    this.enableFrontmatter = true,
    this.templateEngine,
    this.parsers = const [],
    this.extensions = const [],
    this.layouts = const [],
    this.pageBuilder = defaultPageBuilder,
  });

  final bool enableFrontmatter;
  final TemplateEngine? templateEngine;
  final List<PageParser> parsers;
  final List<PageExtension> extensions;
  final List<PageLayout> layouts;
  final PageBuilder pageBuilder;

  static ConfigResolver resolve({
    bool enableFrontmatter = true,
    TemplateEngine? templateEngine,
    List<PageParser> parsers = const [],
    List<PageExtension> extensions = const [],
    List<PageLayout> layouts = const [],
    PageBuilder pageBuilder = defaultPageBuilder,
  }) {
    final config = PageConfig(
      enableFrontmatter: enableFrontmatter,
      templateEngine: templateEngine,
      parsers: parsers,
      extensions: extensions,
      layouts: layouts,
      pageBuilder: pageBuilder,
    );
    return (_) => config;
  }

  static Future<Component> defaultPageBuilder(Page page) async {
    page.parseFrontmatter();
    await page.renderTemplate();
    var nodes = page.parseNodes();
    var component = page.buildComponent(nodes);
    return page.buildLayout(component);
  }
}

typedef PageBuilder = Future<Component> Function(Page);

extension PageHandlers on Page {
  void parseFrontmatter() {
    if (config.enableFrontmatter) {
      final document = fm.parse(content);
      apply(content: document.content, data: document.data.cast());
    }
  }

  FutureOr<void> renderTemplate() {
    if (config.templateEngine != null) {
      return config.templateEngine!.render(this);
    }
  }

  List<Node> parseNodes() {
    return config.parsers.parsePage(this);
  }

  Component buildComponent(List<Node> nodes) {
    for (final extension in config.extensions) {
      nodes = extension.processNodes(nodes, this);
    }
    return nodes.build();
  }

  Component buildLayout(Component child) {
    final layout = config.layouts.where((l) => l.name == data['layout']).firstOrNull ?? config.layouts.firstOrNull;
    if (layout == null) return child;
    return layout.buildLayout(this, child);
  }
}

extension PageContext on BuildContext {
  Page get page => dependOnInheritedComponentOfExactType<_InheritedPage>()!.page;

  List<Page> get pages => dependOnInheritedComponentOfExactType<_InheritedPage>()!.pages;
}

class _InheritedPage extends InheritedComponent {
  _InheritedPage({required this.page, required this.pages, super.child});

  final Page page;
  final List<Page> pages;

  @override
  bool updateShouldNotify(covariant _InheritedPage oldComponent) {
    return oldComponent.page != page;
  }
}

extension MergeData on Map<String, dynamic> {
  Map<String, dynamic> merge(Map<String, dynamic> other) {
    var merged = <String, dynamic>{};
    var otherKeys = other.keys.toSet();
    for (var key in keys) {
      if (otherKeys.remove(key)) {
        if (this[key] is Map<String, dynamic> && other[key] is Map<String, dynamic>) {
          merged[key] = (this[key] as Map<String, dynamic>).merge(other[key] as Map<String, dynamic>);
        } else {
          merged[key] = other[key];
        }
      } else {
        merged[key] = this[key];
      }
    }
    for (var key in otherKeys) {
      merged[key] = other[key];
    }
    return merged;
  }
}
