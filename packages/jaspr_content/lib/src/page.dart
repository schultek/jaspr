import 'dart:async';
import 'dart:convert';

import 'package:fbh_front_matter/fbh_front_matter.dart' as fm;
import 'package:jaspr/server.dart';

import 'content.dart';
import 'data_loader/data_loader.dart';
import 'layouts/page_layout.dart';
import 'page_extension/page_extension.dart';
import 'page_parser/page_parser.dart';
import 'route_loader/route_loader.dart';
import 'secondary_output/secondary_output.dart';
import 'template_engine/template_engine.dart';
import 'theme/theme.dart';
import 'utils.dart';

/// A single page of the site.
///
/// It contains the page's path, url, content, and additional data.
/// The page object is passed to the different modules of the content package and may be modified by them.
/// How the page is built is determined by the [PageConfig] object.
class Page {
  Page({
    required this.path,
    required this.url,
    required this.content,
    Map<String, Object?> initialData = const {},
    required this.config,
    required this.loader,
  }) : _data = PageDataMap._({...initialData});

  /// The path of the page including its suffix, e.g. 'index.html', 'some/path.md'.
  final String path;

  /// The url of the page, e.g. '/', '/some/path'.
  final String url;

  /// The (unparsed) content of the page.
  ///
  /// This may be modified by the different modules during the page building process.
  String content;

  /// Data available to the page.
  Map<String, Object?> _data;

  /// Data available to the page.
  ///
  /// The data data might be modified by
  /// different modules during the page building process.
  ///
  /// Prefer modifying or replacing data with [apply].
  PageDataMap get data => PageDataMap._(_data);

  /// The configuration for the page.
  ///
  /// This determines how the page is built.
  final PageConfig config;

  /// The route loader that created this page.
  final RouteLoader loader;

  /// Applies changes to the page [content] or [data].
  ///
  /// If [data] isn't `null` and [mergeData] is `true`,
  /// values from [data] override those from [Page.data].
  /// Maps with string keys are deeply merged,
  /// also favoring values from [data].
  ///
  /// If [data] isn't `null` and [mergeData] is `false`,
  /// [data] replaces the page's entire [Page.data].
  void apply({String? content, Map<String, Object?>? data, bool mergeData = true}) {
    if (content != null) {
      this.content = content;
    }

    if (data != null) {
      _data = mergeData ? _data.merge(data) : {...data};
    }
  }

  Page copy() {
    return Page(path: path, url: url, content: content, initialData: data, config: config, loader: loader);
  }

  void markNeedsRebuild() {
    loader.invalidatePage(this);
  }

  static Component wrap(Page page, List<Page> pages, Component child) {
    return _InheritedPage(page: page, pages: pages, child: child);
  }

  Future<String> readPartial(String path) {
    return loader.readPartial(path, this);
  }

  String readPartialSync(String path) {
    return loader.readPartialSync(path, this);
  }

  /// Renders the page.
  ///
  /// This performs the following steps in order:
  /// 1. Parses the frontmatter if [enableFrontmatter] is true.
  /// 2. Loads additional data using the provided [dataLoaders].
  /// 3. Preprocesses the content if a [templateEngine] is provided.
  /// 4. If [enableRawOutput] is true, outputs the content as raw text and skips further processing.
  ///    Else continues with 5.
  /// 5. Parses the nodes of the page using one of the [parsers].
  /// 6. Processes the nodes by applying the provided [extensions].
  /// 7. Builds the [Content] component from the processed nodes.
  /// 8. Builds the layout for the page using one of the [layouts].
  /// 9. Wraps the layout in the provided [theme].
  Future<Component> render() async {
    parseFrontmatter();
    await loadData();
    return AsyncBuilder(
      builder: (context) async {
        await renderTemplate(context.pages);

        if (kGenerateMode) {
          if (data.page['sitemap'] case final sitemap?) {
            context.setHeader('jaspr-sitemap-data', jsonEncode(sitemap));
          }
        }

        if (InheritedSecondaryOutput.of(context) case final secondaryOutput?) {
          return secondaryOutput.builder(this);
        }

        if (config.rawOutputPattern?.matchAsPrefix(path) != null) {
          context.setHeader('Content-Type', getContentType());
          context.setStatusCode(200, responseBody: content);
          return Component.fragment([]);
        }

        return await build();
      },
    );
  }

  Future<Component> build() async {
    var nodes = parseNodes();
    nodes = await applyExtensions(nodes);
    final component = Content(NodesBuilder(config.components).build(nodes));
    final layout = buildLayout(component);
    return wrapTheme(layout);
  }
}

/// The configuration for building a page.
///
/// This controls how a page is parsed, processed and built.
class PageConfig {
  const PageConfig({
    this.enableFrontmatter = true,
    this.dataLoaders = const [],
    this.templateEngine,
    this.rawOutputPattern,
    this.secondaryOutputs = const [],
    this.parsers = const [],
    this.extensions = const [],
    this.components = const [],
    this.layouts = const [],
    this.theme,
  });

  /// Whether to enable frontmatter parsing.
  final bool enableFrontmatter;

  /// The data loaders to use for loading additional data for the page.
  final List<DataLoader> dataLoaders;

  /// The template engine to use for preprocessing the page content before parsing.
  final TemplateEngine? templateEngine;

  /// A pattern to match pages that should output their raw content.
  ///
  /// When this matches a page's path, this will skip parsing and rendering the page and return the content as is.
  /// This may be used for matching non-html pages like robots.txt, sitemap.xml, etc.
  final Pattern? rawOutputPattern;

  /// A collection of secondary outputs to create for matching pages.
  ///
  /// When an output matches a page's path, it is used to generate additional files for the page.
  /// This may be used for outputting supplementary files like the raw markdown of a page, an llms.txt file
  final List<SecondaryOutput> secondaryOutputs;

  /// The parsers to use for parsing the page content.
  ///
  /// Each parser may be responsible for a file type like markdown, html, etc.
  final List<PageParser> parsers;

  /// The extensions to use for processing the parsed page nodes.
  ///
  /// Each extension may add or modify the nodes of the page.
  /// Extensions are applied in the order they are listed.
  final List<PageExtension> extensions;

  /// A collection of custom components to render in the page.
  final List<CustomComponent> components;

  /// The layouts to use for building the page.
  ///
  /// When more than one layout is provided, the layout to use is determined by the 'layout' key in the page data.
  /// Therefore a page can choose its layout by setting 'layout: ___' in its frontmatter.
  /// When no key is set or matching, the first provided layout is used.
  final List<PageLayout> layouts;

  /// The theme to use for the page.
  final ContentTheme? theme;

  /// Resolves the given configuration for all pages.
  static ConfigResolver all({
    bool enableFrontmatter = true,
    List<DataLoader> dataLoaders = const [],
    TemplateEngine? templateEngine,
    Pattern? rawOutputPattern,
    List<SecondaryOutput> secondaryOutputs = const [],
    List<PageParser> parsers = const [],
    List<PageExtension> extensions = const [],
    List<CustomComponent> components = const [],
    List<PageLayout> layouts = const [],
    ContentTheme? theme,
  }) {
    final config = PageConfig(
      enableFrontmatter: enableFrontmatter,
      dataLoaders: dataLoaders,
      templateEngine: templateEngine,
      rawOutputPattern: rawOutputPattern,
      secondaryOutputs: secondaryOutputs,
      parsers: parsers,
      extensions: extensions,
      components: components,
      layouts: layouts,
      theme: theme,
    );

    return (_) => config;
  }

  /// Resolves the first config for that the pattern matches the page path.
  ///
  /// If no pattern matches, the default config is returned.
  static ConfigResolver match(Map<Pattern, PageConfig> configs) {
    return (PageSource source) {
      for (final entry in configs.entries) {
        if (entry.key.matchAsPrefix(source.path) != null) {
          return entry.value;
        }
      }
      return PageConfig();
    };
  }
}

/// A function that resolves the configuration for a page based on its source.
typedef ConfigResolver = PageConfig Function(PageSource);

/// A function that builds a page based on its configuration.
typedef PageBuilder = Future<Component> Function(Page);

/// Common build steps that may be used in a page builder function.
extension PageHandlersExtension on Page {
  /// Parses the frontmatter of the page content and adds it to the page data.
  ///
  /// This is only done if [PageConfig.enableFrontmatter] is true.
  /// Modifies the page content and data.
  void parseFrontmatter() {
    if (config.enableFrontmatter) {
      final document = fm.parse(content);
      final normalizedData = document.data.normalize();
      apply(content: document.content, data: {'page': normalizedData});
    }
  }

  /// Loads additional data for the page using the configured data loaders.
  Future<void> loadData() async {
    for (final loader in config.dataLoaders) {
      await loader.loadData(this);
    }
  }

  /// Renders the page content using the configured template engine.
  ///
  /// Modifies the page content.
  FutureOr<void> renderTemplate(List<Page> pages) {
    if (config.templateEngine != null) {
      return config.templateEngine!.render(this, pages);
    }
  }

  String getContentType() {
    if (data['content-type'] case final String type) {
      return type;
    }
    if (path.endsWith('.html')) {
      return 'text/html';
    } else if (path.endsWith('.xml')) {
      return 'text/xml';
    } else if (path.endsWith('.md')) {
      return 'text/markdown';
    } else if (path.endsWith('.json')) {
      return 'application/json';
    } else if (path.endsWith('.yaml') || path.endsWith('.yml')) {
      return 'application/yaml';
    } else {
      return 'text/plain';
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
  Future<List<Node>> applyExtensions(List<Node> nodes) async {
    for (final extension in config.extensions) {
      nodes = await extension.apply(this, nodes);
    }
    return nodes;
  }

  /// Builds the layout for the page using one of the configured layouts.
  ///
  /// When more than one layout is provided, the layout to use is determined by the 'layout' key in the page data.
  /// When no key is set or matching, the first provided layout is used.
  /// Returns [child] if no layout is provided.
  Component buildLayout(Component child) {
    final pageLayout = switch (data.page['layout']) {
      final String layoutName => config.layouts.where((l) => l.name.matchAsPrefix(layoutName) != null).firstOrNull,
      _ => config.layouts.firstOrNull,
    };

    if (pageLayout == null) return child;
    return pageLayout.buildLayout(this, child);
  }

  /// Wraps [child] in the provided theme.
  ///
  /// If no theme is provided, uses the default [ContentTheme].
  /// Adds any missing component themes from the configured components to the page theme.
  Component wrapTheme(Component child) {
    var theme = config.theme ?? ContentTheme();
    if (theme.enabled) {
      final addExtensions = <ThemeExtension<Object?>>[];
      for (final component in config.components) {
        final componentTheme = component.theme;
        if (componentTheme != null && !theme.extensions.containsKey(componentTheme.type)) {
          addExtensions.add(componentTheme);
        }
      }
      theme = theme.apply(extensions: addExtensions);
    }
    return Content.wrapTheme(theme, child: child);
  }
}

/// Context extensions to get the current page and pages in a components build method.
extension PageContext on BuildContext {
  /// Returns the current [Page] that this component is being built for.
  ///
  /// The page should not be modified, otherwise it could lead to unexpected behavior.
  Page get page {
    if (kIsWeb) {
      throw UnsupportedError(
        'context.page is not supported on the client any only allowed to be called on the server.\n'
        'Wrap the call with a !kIsWeb check or move it out of any client component.',
      );
    }

    final comp = dependOnInheritedComponentOfExactType<_InheritedPage>();
    if (comp == null) {
      throw StateError('No Page object found in context. Make sure you are inside a page rendered by ContentApp.');
    }
    return comp.page;
  }

  /// Returns the list of all pages that are being built.
  ///
  /// This list will only be fully available if the [RouteLoader] is eagerly loading all pages before building them.
  /// Otherwise, it will only contain the pages that have been built so far.
  ///
  /// The list should not be modified, otherwise it could lead to unexpected behavior.
  List<Page> get pages {
    if (kIsWeb) {
      throw UnsupportedError(
        'context.pages is not supported on the client any only allowed to be called on the server.\n'
        'Wrap the call with a !kIsWeb check or move it out of any client component.',
      );
    }

    final comp = dependOnInheritedComponentOfExactType<_InheritedPage>();
    if (comp == null) {
      throw StateError('No Page objects found in context. Make sure you are inside a page rendered by ContentApp.');
    }
    return comp.pages;
  }
}

class _InheritedPage extends InheritedComponent {
  _InheritedPage({required this.page, required this.pages, required super.child});

  final Page page;
  final List<Page> pages;

  @override
  bool updateShouldNotify(covariant _InheritedPage oldComponent) {
    return oldComponent.page != page;
  }
}

/// The data exposed to and used by the page, accessed with [Page.data].
///
/// Rather than directly modifying or replacing the underlying data,
/// use [Page.apply] to apply changes.
extension type PageDataMap._(Map<String, Object?> _data) implements Map<String, Object?> {
  /// Data specific to this page, namespaced under 'page' in [data].
  Map<String, Object?> get page => switch (_data['page']) {
    final Map<String, Object?> nestedPageData => nestedPageData,
    _ => const {},
  };

  /// Data declared under the 'site' key in [data],
  /// often loaded from a `_data/site.yml` file and shared across the site.
  Map<String, Object?> get site => switch (_data['site']) {
    final Map<String, Object?> siteData => siteData,
    _ => const {},
  };
}

extension on Map<String, Object?> {
  /// Merge this map with the [other] specified map.
  ///
  /// When both maps share the same key,
  /// values from [other] are favored.
  ///
  /// Maps with string keys are deeply merged,
  /// also favoring values from [other].
  Map<String, Object?> merge(Map<String, Object?> other) {
    final merged = <String, Object?>{};
    final otherKeys = other.keys.toSet();

    for (final MapEntry(key: thisKey, value: thisValue) in entries) {
      if (otherKeys.remove(thisKey)) {
        // If both maps have an entry with this key,
        // prefer the value from other.
        final otherValue = other[thisKey];
        // If the value of this entry for both maps is a map with string keys,
        // recursively merge those maps as well.
        if (thisValue is Map<String, Object?> && otherValue is Map<String, Object?>) {
          merged[thisKey] = thisValue.merge(otherValue);
        } else {
          merged[thisKey] = otherValue;
        }
      } else {
        // Other doesn't have an entry with this key,
        // so use the value from this map.
        merged[thisKey] = thisValue;
      }
    }

    // Add entries from other that have a unique key.
    for (final uniqueKey in otherKeys) {
      merged[uniqueKey] = other[uniqueKey];
    }

    return merged;
  }
}
