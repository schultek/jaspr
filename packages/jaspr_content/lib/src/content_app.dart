import 'dart:async';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../jaspr_content.dart';

/// The root component for building a content-driven site.
///
/// [ContentApp] builds the top-level [Router] for the site. The provided [PageLoader]s are used to load the full set
/// of routes for the site. A [PageLoader] then builds a [Page] for each route based on the resolved [PageConfig].
///
/// For a single page, the following steps are taken:
/// 1. The page is loaded by the [PageLoader].
/// 2. The page's configuration is resolved by the [ConfigResolver] based on its url.
/// 3. The page's content is parsed and processed based on the configuration.
/// 4. The page's content is wrapped in a [Component] and layout.
/// 5. The page's [Component] is built and rendered to HTML.
///
/// Page loading (steps 1 and 2) is always done eagerly at startup for all pages.
///
/// Page building (steps 3 and 4) happens either lazily or eagerly.
/// - In lazy mode (default), pages are built on-demand when they are requested. This is useful for large sites when
///   serving locally or when running in server mode, as it avoids the overhead of building all pages at startup.
/// - In eager mode, all pages are built at startup. This is needed when a page may depend on other pages, such as when
///   rendering a collection of sub-pages. Read [PageContext.pages] for more information.
///
/// Page rendering (step 5) is always done on-demand when a page is requested. In eager mode, it is only done after all
/// pages are built.
class ContentApp extends AsyncStatelessComponent {
  /// Creates a basic [ContentApp] that loads pages from the filesystem and applies the same configuration to all pages.
  ///
  /// For a more customized setup, use [ContentApp.custom].
  ContentApp({
    /// The directory to load pages from.
    String directory = 'content',

    /// Whether to eagerly load all pages at startup. See the discussion on [ContentApp] for more information.
    bool eagerlyLoadAllPages = false,

    /// Whether to enable frontmatter parsing for pages.
    bool enableFrontmatter = true,

    /// An optional [TemplateEngine] to preprocess a page's content.
    TemplateEngine? templateEngine,

    /// A list of [PageParser]s to use for parsing the page content.
    ///
    /// Each parser may be responsible for a file type like markdown, html, etc.
    List<PageParser> parsers = const [],

    /// A list of [PageExtension]s to use for processing the parsed page nodes.
    ///
    /// Each extension may add or modify the nodes of the page.
    /// Extensions are applied in the order they are listed.
    List<PageExtension> extensions = const [],

    /// A list of [PageLayout]s to use for building the page.
    ///
    /// When more than one layout is provided, the layout to use is determined by the 'layout' key in the page data.
    /// Therefore a page can choose its layout by setting 'layout: ___' in its frontmatter.
    /// When no key is set or matching, the first provided layout is used.
    List<PageLayout> layouts = const [],

    /// The [ContentTheme] to use for the pages.
    ContentTheme? theme,
    bool debugPrint = false,
  })  : loaders = [
          FilesystemLoader(
            directory,
            eager: eagerlyLoadAllPages,
            debugPrint: debugPrint,
          )
        ],
        configResolver = PageConfig.resolve(
          enableFrontmatter: enableFrontmatter,
          templateEngine: templateEngine,
          parsers: parsers,
          extensions: extensions,
          layouts: layouts,
          theme: theme,
        ),
        routerBuilder = _defaultRouterBuilder {
    _disableIsolates();
  }

  /// Creates a [ContentApp].
  ContentApp.custom({
    /// A list of [PageLoader]s to load pages from.
    required this.loaders,

    /// A function to resolve the configuration for a page based on its url.
    ///
    /// Use [PageConfig.resolve] to resolve the same config for all pages.
    this.configResolver = _defaultConfigResolver,

    /// A custom builder function to use for building the main [Router] component.
    ///
    /// This can be used to customize the router component, add additional routes or inserting components above the router.
    this.routerBuilder = _defaultRouterBuilder,
  }) {
    _disableIsolates();
  }

  void _disableIsolates() {
    // For caching to work correctly we need to disable isolate rendering.
    Jaspr.initializeApp(options: Jaspr.options, useIsolates: false);
  }

  final List<PageLoader> loaders;
  final ConfigResolver configResolver;
  final Component Function(List<List<RouteBase>> routes) routerBuilder;

  @override
  Stream<Component> build(BuildContext context) async* {
    final routes = await Future.wait(loaders.map((l) => l.loadRoutes(configResolver)));
    yield routerBuilder(routes);
  }
}

PageConfig _defaultConfigResolver(String path) {
  return const PageConfig();
}

Component _defaultRouterBuilder(List<List<RouteBase>> routes) {
  return Router(routes: [for (final r in routes) ...r]);
}
