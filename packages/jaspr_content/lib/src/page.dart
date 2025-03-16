import 'dart:async';

import 'package:fbh_front_matter/fbh_front_matter.dart' as fm;
import 'package:jaspr/jaspr.dart';

import 'content/content.dart';
import 'layouts/page_layout.dart';
import 'page_extension/page_extension.dart';
import 'page_loader/page_loader.dart';
import 'page_parser/page_parser.dart';
import 'template_engine/template_engine.dart';

/// A single page of the site.
///
/// It contains the page's name, url, content, and additional data.
/// The page object is passed to the different modules of the content package and may be modified by them.
/// How the page is built is determined by the [PageConfig] object.
class Page {
  Page(this.name, this.url, this.content, this.data, this.config, this._loader);

  /// The name of the page including its suffix.
  ///
  /// E.g. index.html, about.md
  final String name;

  /// The url path of the page.
  final String url;

  /// The content of the page.
  ///
  /// This may be modified by the different modules during the page building process.
  String content;

  /// Additional data for the page.
  ///
  /// This may be modified by the different modules during the page building process.
  Map<String, dynamic> data;

  /// The configuration for the page.
  ///
  /// This determines how the page is built.
  final PageConfig config;

  final PageLoader _loader;

  /// Applies changes to the page content or data.
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

  Future<String> readPartial(Uri uri) {
    return _loader.readPartial(uri, this);
  }

  String readPartialSync(Uri uri) {
    return _loader.readPartialSync(uri, this);
  }
}

/// The configuration for building a page.
///
/// This controls how a page is parsed, processed and built.
class PageConfig {
  const PageConfig({
    this.enableFrontmatter = true,
    this.templateEngine,
    this.parsers = const [],
    this.extensions = const [],
    this.layouts = const [],
    this.pageBuilder = defaultPageBuilder,
    this.theme,
  });

  /// Whether to enable frontmatter parsing.
  final bool enableFrontmatter;

  /// The template engine to use for preprocessing the page content before parsing.
  final TemplateEngine? templateEngine;

  /// The parsers to use for parsing the page content.
  ///
  /// Each parser may be responsible for a file type like markdown, html, etc.
  final List<PageParser> parsers;

  /// The extensions to use for processing the parsed page nodes.
  ///
  /// Each extension may add or modify the nodes of the page.
  /// Extensions are applied in the order they are listed.
  final List<PageExtension> extensions;

  /// The layouts to use for building the page.
  ///
  /// When more than one layout is provided, the layout to use is determined by the 'layout' key in the page data.
  /// Therefore a page can choose its layout by setting 'layout: ___' in its frontmatter.
  /// When no key is set or matching, the first provided layout is used.
  final List<PageLayout> layouts;

  /// A custom builder function to use for building the page.
  ///
  /// This function controls the page building process and should only be overridden for advanced use-cases.
  /// It defaults to [PageConfig.defaultPageBuilder].
  final PageBuilder pageBuilder;

  /// The theme to use for the page.
  final ContentTheme? theme;

  /// Resolves the given configuration for all pages.
  static ConfigResolver resolve({
    bool enableFrontmatter = true,
    TemplateEngine? templateEngine,
    List<PageParser> parsers = const [],
    List<PageExtension> extensions = const [],
    List<PageLayout> layouts = const [],
    PageBuilder pageBuilder = defaultPageBuilder,
    ContentTheme? theme,
  }) {
    final config = PageConfig(
      enableFrontmatter: enableFrontmatter,
      templateEngine: templateEngine,
      parsers: parsers,
      extensions: extensions,
      layouts: layouts,
      pageBuilder: pageBuilder,
      theme: theme,
    );
    return (_) => config;
  }

  /// The default page builder function.
  ///
  /// This performs the following steps in order:
  /// 1. Parses the frontmatter if [enableFrontmatter] is true.
  /// 2. Preprocesses the content if a [templateEngine] is provided.
  /// 3. Parses the nodes of the page using one of the [parsers].
  /// 4. Processes the nodes by applying the provided [extensions].
  /// 5. Builds the [Content] component from the processed nodes.
  /// 6. Builds the layout for the page using one of the [layouts].
  /// 7. Wraps the layout in the provided [theme].
  ///
  /// Custom page builder functions may copy and modify this function as needed.
  static Future<Component> defaultPageBuilder(Page page) async {
    page.parseFrontmatter();
    await page.renderTemplate();
    var nodes = page.parseNodes();
    nodes = page.applyExtensions(nodes);
    final component = Content(nodes.build());
    final layout = page.buildLayout(component);
    return page.wrapTheme(layout);
  }
}

/// A function that resolves the configuration for a page based on its url.
typedef ConfigResolver = PageConfig Function(String);

/// A function that builds a page based on its configuration.
typedef PageBuilder = Future<Component> Function(Page);

/// Common build steps that may be used in a page builder function.
extension PageHandlers on Page {
  /// Parses the frontmatter of the page content and adds it to the page data.
  ///
  /// This is only done if [PageConfig.enableFrontmatter] is true.
  /// Modifies the page content and data.
  void parseFrontmatter() {
    if (config.enableFrontmatter) {
      final document = fm.parse(content);
      apply(content: document.content, data: document.data.cast());
    }
  }

  /// Renders the page content using the configured template engine.
  ///
  /// Modifies the page content.
  FutureOr<void> renderTemplate() {
    if (config.templateEngine != null) {
      return config.templateEngine!.render(this);
    }
  }

  /// Parses the page content using one of the configured parsers.
  ///
  /// Throws an error if no parser supports the current page.
  List<Node> parseNodes() {
    return config.parsers.parsePage(this);
  }

  /// Applies the configured extensions to the parsed nodes.
  ///
  /// Returns the new list of nodes.
  List<Node> applyExtensions(List<Node> nodes) {
    for (final extension in config.extensions) {
      nodes = extension.apply(this, nodes);
    }
    return nodes;
  }

  /// Builds the layout for the page using one of the configured layouts.
  ///
  /// When more than one layout is provided, the layout to use is determined by the 'layout' key in the page data.
  /// When no key is set or matching, the first provided layout is used.
  /// Returns [child] if no layout is provided.
  Component buildLayout(Component child) {
    final layout = config.layouts.where((l) => l.name.matchAsPrefix(data['layout']) != null).firstOrNull ??
        config.layouts.firstOrNull;
    if (layout == null) return child;
    return layout.buildLayout(this, child);
  }

  /// Wraps [child] in the provided theme.
  Component wrapTheme(Component child) {
    if (config.theme case final theme?) {
      return Content.wrapTheme(theme, child: child);
    }
    return child;
  }
}

/// Context extensions to get the current page and pages in a components build method.
extension PageContext on BuildContext {
  /// Returns the current [Page] that this component is being built for.
  ///
  /// The page should not be modified, otherwise it could lead to unexpected behavior.
  Page get page => dependOnInheritedComponentOfExactType<_InheritedPage>()!.page;

  /// Returns the list of all pages that are being built.
  ///
  /// This list will only be fully available if the [PageLoader] is eagerly loading all pages before building them.
  /// Otherwise, it will only contain the pages that have been built so far.
  ///
  /// The list should not be modified, otherwise it could lead to unexpected behavior.
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

extension on Map<String, dynamic> {
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
