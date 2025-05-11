/// @docImport 'content.dart';
/// @docImport 'data_loader/data_loader.dart';
library;

import 'dart:async';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart' hide RouteLoader;

import 'data_loader/filesystem_data_loader.dart';
import 'layouts/page_layout.dart';
import 'page.dart';
import 'page_extension/page_extension.dart';
import 'page_parser/page_parser.dart';
import 'route_loader/filesystem_loader.dart';
import 'route_loader/route_loader.dart';
import 'template_engine/template_engine.dart';
import 'theme/theme.dart';

/// The root component for building a content-driven site.
///
/// [ContentApp] builds the top-level [Router] for the site. The provided [RouteLoader]s are used to load the full set
/// of routes for the site. A [RouteLoader] then builds a [Page] for each route based on the resolved [PageConfig].
///
/// For a single page, the following steps are taken:
/// 1. The page is created by one of the provided [RouteLoader]s.
/// 2. The page's configuration is resolved by the provided [ConfigResolver] based on its route.
/// 3. The page's frontmatter is parsed and additional data is loaded by the configured [DataLoader]s.
/// 4. The page's content is pre-processed by the configured [TemplateEngine].
/// 5. The page's content is parsed by one of the configured [PageParser]s.
/// 6. The parsed content is further processed by the configured [PageExtension]s.
/// 7. The processed content is rendered using the configured [CustomComponent]s ans wrapped in a [Content] component.
/// 8. The content is wrapped in a [PageLayout] and gets applied the configured [ContentTheme].
/// 9. The result is rendered to HTML.
///
/// Page creation (steps 1 and 2) is always done eagerly at startup for all pages.
///
/// Page loading (step 3) happens either lazily or eagerly.
/// - In lazy mode (default), pages are loaded on-demand when they are requested. This is useful for large sites when
///   serving locally or when running in server mode, as it avoids the overhead of loading all pages at startup.
/// - In eager mode, all pages are loaded at startup. This is needed when a page may depend on other pages, such as when
///   rendering a collection of sub-pages. Read [PageContext.pages] for more information.
///
/// Page rendering (steps 4 to 9) is always done on-demand when a page is requested. In eager mode, this waits for all
/// pages to be loaded before rendering the requested page.
class ContentApp extends AsyncStatelessComponent {
  /// Creates a basic [ContentApp] that loads pages from the filesystem and applies the same configuration to all pages.
  ///
  /// For a more customized setup, use [ContentApp.custom].
  ContentApp({
    /// The directory to load pages from.
    ///
    /// This is relative to the root of the project.
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

    /// A list of [CustomComponent]s to use for rendering the page.
    List<CustomComponent> components = const [],

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
          components: components,
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
    /// This can be used to customize the [Router] component like add additional routes or inserting components above the router.
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

PageConfig _defaultConfigResolver(PageSource source) {
  return const PageConfig();
}

Component _defaultRouterBuilder(List<List<RouteBase>> routes) {
  return Router(routes: [for (final r in routes) ...r]);
}