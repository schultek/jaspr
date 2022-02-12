part of framework;

/// Main app binding, controls the root component and global state
abstract class AppBinding {
  Uri get currentUri;

  static AppBinding? _instance;
  static AppBinding? get instance => _instance;

  AppBinding() {
    _instance = this;
    _stateData = loadStateData();
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

  /// Global state data returned from the server. See [PreloadStateMixin]
  late final Map<String, dynamic> _stateData;

  @protected
  Map<String, dynamic> loadStateData() => {};

  Map<String, dynamic> getStateData() => _stateData;

  void _saveState(StateKey key, dynamic state) {
    _stateData[key.id] = state;
  }

  dynamic _getState(StateKey key) {
    return _stateData[key.id];
  }

  bool isLoadingState = false;

  /// Notifies elements about new global state synced from the server
  /// This is called when a [LazyRoute] is eagerly loaded.
  void notifyState(Map<String, dynamic> data) {
    isLoadingState = false;
    for (var id in data.keys) {
      _stateData[id] = data[id];
    }

    for (var key in _globalKeyRegistry.keys) {
      if (key is StateKey) {
        var state = key.currentState;
        if (state is PreloadStateMixin) {
          state._notifyLoadedState(_stateData[key.id]);
        }
      }
    }
  }

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
}

/// In difference to Flutter, we have multiple build schedulers instead of one global build owner
/// Particularly each dom element is a build scheduler and manages its subtree of components
mixin BuildScheduler on Element {
  DomView? view;

  Future? _rebuilding;

  // TODO: find out how activation / deactivation of a build scheduler affects its child elements, this probably has some bugs still
  final _InactiveElements _inactiveElements = _InactiveElements();

  void scheduleBuildFor(Element element) {
    scheduleRebuild();
  }

  Future<void> scheduleRebuild() {
    return _rebuilding ??= Future.microtask(() async {
      try {
        rebuild();
        view?.update();
        _inactiveElements._unmountAll();
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
