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
    ContentTheme? theme,
    bool debugPrint = false,
  })  : loaders = [FilesystemLoader(
          directory,
          eager: eagerlyLoadAllPages,
          debugPrint: debugPrint,
        )],
        configResolver = PageConfig.resolve(
          enableFrontmatter: enableFrontmatter,
          templateEngine: templateEngine,
          parsers: parsers,
          extensions: extensions,
          layouts: layouts,
          pageBuilder: pageBuilder,
          theme: theme,
        ) {
    _disableIsolates();
  }

  ContentApp.custom({
    required this.loaders,
    this.configResolver = _defaultConfigResolver,
    this.routerBuilder = _defaultRouterBuilder,
  }) {
    _disableIsolates();
  }

  void _disableIsolates() {
    Jaspr.initializeApp(options: Jaspr.options, useIsolates: false);
  }

  final List<PagesLoader> loaders;
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
