part of framework;

abstract class AppBinding {
  Uri get currentUri;

  static AppBinding? _instance;
  static AppBinding? get instance => _instance;

  AppBinding() {
    _instance = this;
    _stateData = loadStateData();
  }

  bool get isFirstBuild => _buildQueue.isNotEmpty;

  final List<Future> _buildQueue = [];
  Future<void> get firstBuild async {
    while (_buildQueue.isNotEmpty) {
      await _buildQueue.first;
    }
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

  void performRebuildOn(Element? child) {
    var built = performRebuild(child);
    if (built is Future) {
      assert(isFirstBuild);
      _buildQueue.add(built);
      built.whenComplete(() => _buildQueue.remove(built));
    }
  }

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

mixin BuildScheduler on Element {
  DomView? view;

  Future? _rebuilding;

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
