import 'dart:async';

import '../framework/framework.dart';
import 'js_data.dart';
import 'run_app.dart';

typedef IslandLoader = FutureOr<IslandBuilder> Function();
typedef IslandBuilder = Component Function(ConfigParams);

class ConfigParams {
  final Map<String, dynamic> _params;

  ConfigParams(this._params);

  T get<T>(String key) {
    if (_params[key] is! T) {
      print("$key is not $T: ${_params[key]}");
    }
    return _params[key];
  }
}

void runIslands(Map<String, IslandBuilder> islands) {
  _applyIslands((name) => islands[name]!);
}

void runIslandsDeferred(Map<String, IslandLoader> islands) {
  final Map<String, IslandBuilder> builders = {};
  _applyIslands((name) {
    var island = (builders[name] ?? islands[name]!()) as FutureOr<IslandBuilder>;
    if (island is IslandBuilder) {
      return builders[name] = island;
    } else {
      return island.then((b) => builders[name] = b);
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
  var islands = jasprConfig.islands;
  if (islands == null) return;

  for (var island in islands) {
    var builder = fn(island.name);
    if (builder is IslandBuilder) {
      _runIsland(builder, ConfigParams(island.params), island.id);
    } else {
      builder.then((b) => _runIsland(b, ConfigParams(island.params), island.id));
    }
  }
}

void runAppWithParams(IslandBuilder appBuilder) {
  var appConfig = jasprConfig.app;
  _runIsland(appBuilder, ConfigParams(appConfig?.params ?? {}), appConfig?.id ?? 'body');
}
