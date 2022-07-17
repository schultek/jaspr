import 'dart:async';
import 'dart:math';

import 'jaspr.dart';

abstract class Island<T> {
  final String name;

  const Island({required this.name});

  @protected
  Component build(BuildContext context, T value);

  static Component put<T>(Island<T> island, T value) {
    return _Island<T>(island, value);
  }
}

class _Island<T> extends StatelessComponent {
  final T value;
  final Island<T> island;

  const _Island(this.island, this.value, {Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var islandsApp = context.findAncestorStateOfType<_IslandsAppState>()!;
    var id = islandsApp.registerIsland(island.name, value);
    yield DomComponent(tag: 'div', id: id, child: island.build(context, value));
  }
}

typedef IslandLoader = Future<Island> Function();

class IslandsApp extends StatefulComponent {
  final Component child;

  const IslandsApp({required this.child, Key? key}) : super(key: key);

  @override
  State<IslandsApp> createState() => _IslandsAppState();

  static void run(List<Island> islands) {
    final Map<String, Island> _nameToEntry = {};
    for (var island in islands) {
      _nameToEntry[island.name] = island;
    }

    AppBinding.ensureInitialized();
    var islandsState = SyncBinding.instance!.getInitialState<Map>('islands') ?? {};

    for (var id in islandsState.keys) {
      var data = islandsState[id]!.split('|');
      var params = stateCodec.decode(data[1]);
      runApp(Builder.single(builder: (c) => _nameToEntry[data[0]]!.build(c, params)), attachTo: '#$id');
    }
  }

  static void runDeferred(Map<String, IslandLoader> islands) {
    final Map<String, Island> _islands = {};
    AppBinding.ensureInitialized();
    var islandsState = SyncBinding.instance!.getInitialState<Map>('islands') ?? {};

    for (var id in islandsState.keys) {
      var data = islandsState[id]!.split('|');
      var name = data[0];
      var params = stateCodec.decode(data[1]);

      unawaited(Future(() async {
        var island = _islands[name];
        if (island == null) {
          island = await islands[name]!();
          _islands[name] = island;
        }
        runApp(Builder.single(builder: (c) => island!.build(c, params)), attachTo: '#$id');
      }));
    }
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
