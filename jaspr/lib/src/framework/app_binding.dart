part of framework;

/// Main app binding, controls the root component and global state
abstract class AppBinding {
  Uri get currentUri;

  static AppBinding? _instance;
  static AppBinding? get instance => _instance;

  AppBinding() {
    _instance = this;
  }

  void attachRootComponent(Component app, {required String to}) {
    var element = _Root(child: app).createElement();
    element._root = this;

    var syncBuildLock = Future.value();
    _buildQueue.add(syncBuildLock);

    element.mount(null);
    attachRootElement(element, to: to);

    _buildQueue.remove(syncBuildLock);
  }

  @protected
  void attachRootElement(BuildScheduler element, {required String to}) {}

  @protected
  Map<String, String> getStateData() {
    var state = <String, String>{};
    for (var key in _globalKeyRegistry.keys) {
      if (key._canSync) {
        var s = key._saveState();
        state[key._id] = s;
      }
    }
    return state;
  }

  @protected
  String? getRawState(String id);

  @protected
  void updateRawState(String id, String state);

  bool _isLoadingState = false;
  bool get isLoadingState => _isLoadingState;

  /// Loads state from the server and and notifies elements.
  /// This is called when a [LazyRoute] is loaded.
  Future<void> loadState(String path) async {
    _isLoadingState = true;
    var data = await fetchState(path);
    _isLoadingState = false;
    print("LOADED DATA $data");

    for (var id in data.keys) {
      updateRawState(id, data[id]!);
    }

    for (var key in _globalKeyRegistry.keys) {
      if (key._canSync && data.containsKey(key._id)) {
        key._notifyState(data[key._id]);
      }
    }
  }

  @protected
  Future<Map<String, String>> fetchState(String url);

  bool get isFirstBuild => _buildQueue.isNotEmpty;

  final List<Future> _buildQueue = [];
  Future<void> get firstBuild async {
    while (_buildQueue.isNotEmpty) {
      await _buildQueue.first;
    }
  }

  void performRebuildOn(Element? child) {
    var built = performRebuild(child);
    if (built is Future) {
      assert(isFirstBuild);
      _buildQueue.add(built);
      built.whenComplete(() => _buildQueue.remove(built));
    }
  }

  /// The first build on server and browser is allowed to have asynchronous operations (i.e. preloading data)
  /// However we want the component and element apis to stay synchronous, so subclasses
  /// can override this method to simulate an async rebuild for a child
  @protected
  @mustCallSuper
  FutureOr<void> performRebuild(Element? child) {
    child?.rebuild();
  }

  final Map<GlobalKey, Element> _globalKeyRegistry = {};

  void _registerGlobalKey(GlobalKey key, Element element) {
    _globalKeyRegistry[key] = element;
  }

  void _unregisterGlobalKey(GlobalKey key, Element element) {
    if (_globalKeyRegistry[key] == element) {
      _globalKeyRegistry.remove(key);
    }
  }

  void _initState(GlobalKey key) {
    if (key._canSync) {
      key._notifyState(getRawState(key._id));
    }
  }

  final _InactiveElements _inactiveElements = _InactiveElements();
}

/// In difference to Flutter, we have multiple build schedulers instead of one global build owner
/// Particularly each dom element is a build scheduler and manages its subtree of components
mixin BuildScheduler on Element {
  DomView? _view;

  DomView get view => _view!;
  set view(DomView v) {
    _view = v;
  }

  Future? _rebuilding;

  void scheduleBuildFor(Element element) {
    scheduleRebuild();
  }

  Future<void> scheduleRebuild() {
    assert(_dirty || _view != null);
    return _rebuilding ??= Future.microtask(() async {
      try {
        rebuild();
        _view!.update();
        _dirty = false;
        root._inactiveElements._unmountAll();
      } finally {
        _rebuilding = null;
      }
    });
  }
}

class _Root extends Component {
  _Root({required this.child});

  final Component child;

  @override
  _RootElement createElement() => _RootElement(this);
}

class _RootElement extends SingleChildElement with BuildScheduler {
  _RootElement(_Root component) : super(component);

  @override
  _Root get component => super.component as _Root;

  @override
  Component build() => component.child;
}
