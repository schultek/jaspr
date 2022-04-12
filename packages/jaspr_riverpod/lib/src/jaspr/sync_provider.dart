part of framework;

final _syncProvider = StateNotifierProvider<SyncNotifier, Map<String, dynamic>>((ref) {
  return SyncNotifier();
});

class SyncNotifier extends StateNotifier<Map<String, dynamic>> {
  SyncNotifier() : super({});

  Map<String, dynamic> _saveState() {
    var map = <String, dynamic>{};
    for (var key in _syncRefs.keys) {
      var sync = _syncRefs[key]!;
      if (sync.id == key) {
        map[key] = sync._onSave();
      }
    }
    return map;
  }

  void _updateState(Map<String, dynamic>? value) {
    state = {...state, ...value ?? {}};
    for (var sync in _syncRefs.values) {
      sync._onUpdate(state[sync.id]);
    }
  }

  final Map<String, _SyncRef> _syncRefs = {};

  T? _register<T>(_SyncRef<T> sync) {
    _registerSync(sync);

    sync.ref.onResume(() => _registerSync(sync));
    sync.ref.onCancel(() => _unregisterSync(sync));

    var s = state[sync.id];
    return s != null ? sync.codec.decode(s) : null;
  }

  void _registerSync<T>(_SyncRef<T> sync) {
    if (_syncRefs.containsKey(sync.id)) {
      print("WARNING: Duplicate sync id ${sync.id} used by two providers.");
    }
    _syncRefs[sync.id] = sync;
  }

  void _unregisterSync<T>(_SyncRef<T> sync) {
    if (_syncRefs[sync.id] == sync) {
      _syncRefs.remove(sync.id);
    }
  }

  final List<Future<void> Function()> _preloadFunctions = [];

  void _registerPreload(Future<void> Function() fn) {
    _preloadFunctions.add(fn);
  }

  Future<void> _preload() {
    var futures = _preloadFunctions.map((fn) => fn()).toList();
    _preloadFunctions.clear();

    if (futures.isEmpty) {
      print("[WARNING] Tried preloading, but the provider did not setup a preload handler.");
    }

    return Future.wait(futures);
  }
}
