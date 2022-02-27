part of framework;

/// Main app binding, controls the root component and global state
abstract class ComponentsBinding {
  /// The currently active uri.
  /// On the server, this is the requested uri. On the client, this is the
  /// currently visited uri in the browser.
  Uri get currentUri;

  static ComponentsBinding? _instance;
  static ComponentsBinding? get instance => _instance;

  ComponentsBinding() {
    _instance = this;
  }

  /// Whether the current app is run on the client (in the browser)
  bool get isClient;

  /// Sets [app] as the new root of the component tree and performs an initial build
  void attachRootComponent(Component app, {required String to}) {
    var element = _Root(child: app).createElement();
    element._root = this;

    var syncBuildLock = Future.value();
    _initialBuildQueue.add(syncBuildLock);

    element.mount(null);
    _rootElement = element;

    didAttachRootElement(element, to: to);

    _initialBuildQueue.remove(syncBuildLock);
  }

  @protected
  void didAttachRootElement(BuildScheduler element, {required String to});

  /// The [Element] that is at the root of the hierarchy.
  ///
  /// This is initialized the first time [runApp] is called.
  SingleChildElement? get rootElement => _rootElement;
  SingleChildElement? _rootElement;

  /// Returns the accumulated data from all active [State]s that use the [SyncStateMixin]
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

  /// Must return the serialized state data associated with [id]. On the client this is the
  /// data that is synced from the server.
  @protected
  String? getRawState(String id);

  /// Must update the serialized state data associated with [id]. This is called on the client
  /// when new data is loaded for a [LazyRoute].
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

    for (var id in data.keys) {
      updateRawState(id, data[id]!);
    }

    for (var key in _globalKeyRegistry.keys) {
      if (key._canSync && data.containsKey(key._id)) {
        key._notifyState(data[key._id]);
      }
    }
  }

  /// On the client, this should perform a http request to [url] to fetch state data from the server.
  @protected
  Future<Map<String, String>> fetchState(String url);

  final List<Future> _initialBuildQueue = [];

  /// Whether the initial build is currently performed.
  bool get isFirstBuild => _initialBuildQueue.isNotEmpty;

  /// Future that resolves when the initial build is completed.
  Future<void> get firstBuild async {
    while (_initialBuildQueue.isNotEmpty) {
      await _initialBuildQueue.first;
    }
  }

  final List<Future> _buildQueue = [];

  /// Whether a rebuild is currently performed.
  bool get isRebuilding => _buildQueue.isNotEmpty;

  /// Future that resolves when the current build is completed.
  Future<void> get currentBuild async {
    while (_buildQueue.isNotEmpty) {
      await _buildQueue.first;
    }
  }

  /// Rebuilds [child] and correctly accounts for any asynchronous operations that can occurr during the initial
  /// build of an app.
  /// Async builds are only allowed for [StatefulComponent]s that use the [PreloadDataMixin] or [DeferRenderMixin].
  void performRebuildOn(Element? child) {
    var built = performRebuild(child);
    if (built is Future) {
      assert(isFirstBuild, 'Only the first build is allowed to be asynchronous.');
      _initialBuildQueue.add(built);
      built.whenComplete(() => _initialBuildQueue.remove(built));
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

  /// Schedules a rebuild of the subtree relative to this element.
  ///
  /// Multiple calls to [scheduleRebuild] are ignored when a rebuild is already scheduled.
  Future<void> scheduleRebuild() {
    assert(_dirty || _view != null, 'View was not initialized on BuildScheduler');
    if (_rebuilding == null) {
      if (_parent?._scheduler?._rebuilding != null) {
        return _parent!._scheduler!._rebuilding!;
      }

      _rebuilding = Future.microtask(() {
        try {
          rebuild();
          _view!.update();
          _dirty = false;
          root._inactiveElements._unmountAll();
        } finally {
          root._buildQueue.remove(_rebuilding);
          _rebuilding = null;
        }
      });
      root._buildQueue.add(_rebuilding!);
    }
    return _rebuilding!;
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
