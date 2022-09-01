import 'dart:async';

import '../../browser.dart';
import 'js_data.dart';

typedef IslandLoader = FutureOr<IslandBuilder> Function();
typedef IslandBuilder = Component Function(ConfigParams);

void runIslands(Map<String, IslandBuilder> islands) {
  _applyIslands((name) => islands[name]!);
}

void runIslandsDeferred(Map<String, IslandLoader> islands) {
  final Map<String, IslandBuilder> _islands = {};
  _applyIslands((name) {
    var island = (_islands[name] ?? islands[name]!()) as FutureOr<IslandBuilder>;
    if (island is IslandBuilder) {
      return _islands[name] = island;
    } else {
      return island.then((b) => _islands[name] = b);
    }
  });
}

IslandLoader loadIsland(Future<void> Function() loader, IslandBuilder builder) {
  return () => loader().then((_) => builder);
}

void _runIsland(IslandBuilder builder, ConfigParams params, String id) {
  runApp(builder(params), attachTo: id);
}

void _applyIslands(FutureOr<IslandBuilder> Function(String) fn) {
  var islands = jasprConfig?.islands;
  if (islands == null) return;

  for (var island in islands) {
    print("ISLAND $island");
    var builder = fn(island.name);
    if (builder is IslandBuilder) {
      _runIsland(builder, island.config, island.id);
    } else {
      builder.then((b) => _runIsland(b, island.config, island.id));
    }
  }
}

void runAppWithParams(IslandBuilder appBuilder) {
  var appConfig = jasprConfig?.app;
  _runIsland(appBuilder, appConfig.config, appConfig?.id ?? 'body');
}