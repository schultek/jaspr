import 'dart:async';
import 'dart:math';

import 'jaspr.dart';

class Island {
  const Island();
}

abstract class IslandComponent extends StatelessComponent {
  final String name;

  const IslandComponent({required this.name, this.containerBuilder, Key? key}) : super(key: key);

  final Component Function(BuildContext context, String id, Component child)? containerBuilder;

  Map<String, dynamic> get params;
  Component buildChild(BuildContext context);

  Component _buildContainer(BuildContext context, String id, Component child) {
    return DomComponent(tag: 'div', id: id, child: child);
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var app = context.findAncestorStateOfType<_IslandsAppState>()!;
    var id = app.registerIsland(name, params);
    yield (containerBuilder ?? _buildContainer)(context, id, buildChild(context));
  }
}

typedef IslandLoader = FutureOr<IslandBuilder> Function();
typedef IslandBuilder = Component Function(BuildContext, IslandParams);

class IslandParams {
  final Map<String, dynamic> _params;

  IslandParams(this._params);

  T get<T>(String key) {
    return _params[key];
  }
}

class IslandsApp extends StatefulComponent {
  final Component child;

  const IslandsApp({required this.child, Key? key}) : super(key: key);

  @override
  State<IslandsApp> createState() => _IslandsAppState();

  static void _runIsland(IslandBuilder builder, IslandParams params, String id) {
    runApp(Builder.single(builder: (c) => builder(c, params)), attachTo: '#$id');
  }

  static void _applyIslands(FutureOr<IslandBuilder> Function(String) fn) {
    AppBinding.ensureInitialized();
    var islandsState = SyncBinding.instance!.getInitialState<Map>('islands') ?? {};

    for (var id in islandsState.keys) {
      var data = islandsState[id]!.split('=');
      var name = data[0];
      var params = IslandParams(stateCodec.decode(data[1]));
      var builder = fn(name);
      if (builder is IslandBuilder) {
        _runIsland(builder, params, id);
      } else {
        builder.then((b) => _runIsland(b, params, id));
      }
    }
  }

  static void run(Map<String, IslandBuilder> islands) {
    _applyIslands((name) => islands[name]!);
  }

  static void runDeferred(Map<String, IslandLoader> islands) {
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
}

class _IslandsAppState extends State<IslandsApp> with SyncStateMixin<IslandsApp, Map<String, String>> {
  @override
  String get syncId => 'islands';

  final Map<String, String> _islands = {};

  @override
  Map<String, String> getState() => _islands;

  @override
  void updateState(Map<String, String>? value) {}

  final _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String _randomId() {
    var r = Random();
    return List.generate(8, (i) => _chars[r.nextInt(_chars.length)]).join();
  }

  String registerIsland(String name, dynamic params) {
    var id = _randomId();
    _islands[id] = name + '|' + stateCodec.encode(params);
    return id;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield component.child;
  }
}
