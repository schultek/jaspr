import 'dart:async';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../jaspr_content.dart';
import 'pages_repository.dart';

class ContentApp extends AsyncStatelessComponent {
  ContentApp({
    String directory = 'content',
    bool eagerlyLoadAllPages = false,
    this.routerBuilder = _defaultRouterBuilder,
    PageConfig? config,
    required List<PageBuilder> builders,
    bool debugPrint = false,
  }) : repository = FilesystemPagesRepository(
          directory,
          eager: eagerlyLoadAllPages,
          config: config,
          builders: builders,
          debugPrint: debugPrint,
        );

  ContentApp.fromRepository({
    this.routerBuilder = _defaultRouterBuilder,
    required this.repository,
  });

  final Component Function(List<RouteBase> routes) routerBuilder;
  final PagesRepository repository;

  @override
  Stream<Component> build(BuildContext context) async* {
    final routes = await repository.routes;
    yield routerBuilder(routes);
  }
}

Component _defaultRouterBuilder(List<RouteBase> routes) {
  return Router(routes: routes);
}
