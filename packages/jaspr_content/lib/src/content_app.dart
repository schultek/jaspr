import 'dart:async';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../jaspr_content.dart';

class ContentApp extends AsyncStatelessComponent {
  ContentApp({
    String directory = 'content',
    bool eagerlyLoadAllPages = false,
    bool enableFrontmatter = true,
    TemplateEngine? templateEngine,
    List<PageParser> parsers = const [],
    List<PageExtension> extensions = const [],
    List<PageLayout> layouts = const [],
    PageBuilder pageBuilder = PageConfig.defaultPageBuilder,
    this.routerBuilder = _defaultRouterBuilder,
    bool debugPrint = false,
  })  : loader = FilesystemLoader(
          directory,
          eager: eagerlyLoadAllPages,
          debugPrint: debugPrint,
        ),
        configResolver = PageConfig.resolve(
          enableFrontmatter: enableFrontmatter,
          templateEngine: templateEngine,
          parsers: parsers,
          extensions: extensions,
          layouts: layouts,
          pageBuilder: pageBuilder,
        ) {
    _disableIsolates();
  }

  ContentApp.custom({
    required this.loader,
    this.configResolver = _defaultConfigResolver,
    this.routerBuilder = _defaultRouterBuilder,
  }) {
    _disableIsolates();
  }

  void _disableIsolates() {
    Jaspr.initializeApp(options: Jaspr.options, useIsolates: false);
  }

  final PagesLoader loader;
  final ConfigResolver configResolver;
  final Component Function(List<RouteBase> routes) routerBuilder;

  @override
  Stream<Component> build(BuildContext context) async* {
    final routes = await loader.loadRoutes(configResolver);
    yield routerBuilder(routes);
  }

  @css
  static List<StyleRule> styles = [
    css('body').styles(
      backgroundColor: Colors.black,
    ),
  ];
}

PageConfig _defaultConfigResolver(String path) {
  return const PageConfig();
}

Component _defaultRouterBuilder(List<RouteBase> routes) {
  return Router(routes: routes);
}
