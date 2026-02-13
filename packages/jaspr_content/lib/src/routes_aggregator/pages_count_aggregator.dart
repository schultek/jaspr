import 'dart:async';

import '../page.dart';
import '../route_loader/route_loader.dart';
import 'routes_aggregator.dart';

class PagesCountAggregator extends RoutesAggregator {
  PagesCountAggregator();

  @override
  Future<List<PageSource>> loadPageSources() async {
    final previouslyLoadedPages = List<Page>.unmodifiable(RouteLoader.pages);

    print('Current page count: ${previouslyLoadedPages.length}');

    return [];
  }
}
