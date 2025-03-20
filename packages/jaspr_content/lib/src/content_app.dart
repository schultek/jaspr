import 'dart:async';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart' hide RouteLoader;

import 'content/content.dart';
import 'data_loader/filesystem_data_loader.dart';
import 'layouts/page_layout.dart';
import 'page.dart';
import 'page_extension/page_extension.dart';
import 'page_parser/page_parser.dart';
import 'route_loader/filesystem_loader.dart';
import 'route_loader/route_loader.dart';
import 'template_engine/template_engine.dart';

/// The root component for building a content-driven site.
///
/// [ContentApp] builds the top-level [Router] for the site. The provided [RouteLoader]s are used to load the full set
/// of routes for the site. A [RouteLoader] then builds a [Page] for each route based on the resolved [PageConfig].
///
/// For a single page, the following steps are taken:
/// 1. The page is created by the [RouteLoader].
/// 2. The page's configuration is resolved by the [ConfigResolver] based on its url.
/// 3. The page's frontmatter is parsed and additional data is loaded.
/// 4. The page's content is parsed and processed based on the configuration.
/// 5. The page is wrapped in a layout and rendered to HTML.
///
/// Page creation (steps 1 and 2) is always done eagerly at startup for all pages.
///
/// Page loading (step 3) happens either lazily or eagerly.
/// - In lazy mode (default), pages are loaded on-demand when they are requested. This is useful for large sites when
///   serving locally or when running in server mode, as it avoids the overhead of loading all pages at startup.
/// - In eager mode, all pages are loaded at startup. This is needed when a page may depend on other pages, such as when
///   rendering a collection of sub-pages. Read [PageContext.pages] for more information.
///
/// Page rendering (steps 4 and 5) is always done on-demand when a page is requested. In eager mode, this waits for all
/// pages to be loaded before rendering the requested page.
class ContentApp extends AsyncStatelessComponent {
  /// Creates a basic [ContentApp] that loads pages from the filesystem and applies the same configuration to all pages.
  ///
  /// For a more customized setup, use [ContentApp.custom].
  ContentApp({
    /// The directory to load pages from.
    String directory = 'content',

    /// Whether to eagerly load all pages at startup. See the discussion on [ContentApp] for more information.
    this.eagerlyLoadAllPages = false,

    /// Whether to enable frontmatter parsing for pages.
    bool enableFrontmatter = true,

    /// The directory to load data files from.
    String dataDirectory = 'content/_data',

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
  })  : loaders = [FilesystemLoader(directory, debugPrint: debugPrint)],
        configResolver = PageConfig.all(
          enableFrontmatter: enableFrontmatter,
          dataLoaders: [
            FilesystemDataLoader(dataDirectory),
          ],
          templateEngine: templateEngine,
          parsers: parsers,
          extensions: extensions,
          layouts: layouts,
          theme: theme,
        ),
        routerBuilder = _defaultRouterBuilder {
    _overrideGlobalOptions();
  }

  /// Creates a [ContentApp].
  ContentApp.custom({
    /// A list of [RouteLoader]s to load pages from.
    required this.loaders,

    /// Whether to eagerly load all pages at startup. See the discussion on [ContentApp] for more information.
    this.eagerlyLoadAllPages = false,

    /// A function to resolve the configuration for a page based on its url.
    ///
    /// Use [PageConfig.all] to resolve the same config for all pages.
    this.configResolver = _defaultConfigResolver,

    /// A custom builder function to use for building the main [Router] component.
    ///
    /// This can be used to customize the router component, add additional routes or inserting components above the router.
    this.routerBuilder = _defaultRouterBuilder,
  }) {
    _overrideGlobalOptions();
  }

  void _overrideGlobalOptions() {
    if (Jaspr.useIsolates) {
      print("[Warning] ContentApp only supports non-isolate rendering. Disabling isolate rendering.");
      // For caching to work correctly we need to disable isolate rendering.
      Jaspr.initializeApp(options: Jaspr.options, useIsolates: false);
    }
  }

  final List<RouteLoader> loaders;
  final bool eagerlyLoadAllPages;
  final ConfigResolver configResolver;
  final Component Function(List<List<RouteBase>> routes) routerBuilder;

  @override
  Stream<Component> build(BuildContext context) async* {
    final routes = await Future.wait(loaders.map((l) => l.loadRoutes(configResolver, eagerlyLoadAllPages)));
    _ensureAllowedSuffixes(routes);
    yield routerBuilder(routes);
  }

  void _ensureAllowedSuffixes(List<List<RouteBase>> routes) {
    List<String> getSuffixes(RouteBase route) {
      if (route is Route) {
        return [
          if (route.path.split('/').last.split('.') case [_, ..., final suffix]) suffix,
          ...route.routes.expand((r) => getSuffixes(r)),
        ];
      } else if (route is ShellRoute) {
        return route.routes.expand((r) => getSuffixes(r)).toList();
      } else {
        return [];
      }
    }

    final suffixes = routes.expand((r) => r).expand((r) => getSuffixes(r)).toSet();
    final missing = suffixes.difference(Jaspr.allowedPathSuffixes.toSet());
    if (missing.isNotEmpty) {
      Jaspr.initializeApp(
        options: Jaspr.options,
        useIsolates: Jaspr.useIsolates,
        allowedPathSuffixes: [...Jaspr.allowedPathSuffixes, ...missing],
      );
    }
  }
}

PageConfig _defaultConfigResolver(PageRoute route) {
  return const PageConfig();
}

Component _defaultRouterBuilder(List<List<RouteBase>> routes) {
  return Router(routes: [for (final r in routes) ...r]);
}
