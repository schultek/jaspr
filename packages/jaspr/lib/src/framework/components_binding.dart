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
    _owner = BuildOwner();
  }

  late BuildOwner _owner;

  /// Whether the current app is run on the client (in the browser)
  bool get isClient;

  /// Sets [app] as the new root of the component tree and performs an initial build
  void attachRootComponent(Component app, {required String attachTo}) {
    var element = _Root(child: app).createElement();
    element._root = this;

    var syncBuildLock = Future.value();
    _initialBuildQueue.add(syncBuildLock);

    element.mount(null);
    _rootElement = element;

    didAttachRootElement(element, to: attachTo);

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
  Map<String, dynamic> getStateData() {
    var state = <String, dynamic>{};
    for (var key in _globalSyncRegistry.keys) {
      var syncState = _globalSyncRegistry[key]!;
      assert(syncState._syncId == key);
      if (syncState.mounted) {
        state[key] = syncState._saveState();
      }
    }
    return state;
  }

  /// Must return the serialized state data associated with [id]. On the client this is the
  /// data that is synced from the server.
  @protected
  dynamic getRawState(String id);

  /// Must update the serialized state data associated with [id]. This is called on the client
  /// when new data is loaded for a [LazyRoute].
  @protected
  void updateRawState(String id, dynamic state);

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

    for (var key in _globalSyncRegistry.keys) {
      if (data.containsKey(key)) {
        var state = _globalSyncRegistry[key]!;
        assert(state._syncId == key);
        if (state.mounted) {
          state._updateState(data[key]);
        }
      }
    }
  }

  /// On the client, this should perform a http request to [url] to fetch state data from the server.
  @protected
  Future<Map<String, dynamic>> fetchState(String url);

  final List<Future> _initialBuildQueue = [];

  /// Whether the initial build is currently performed.
  bool get isFirstBuild => _initialBuildQueue.isNotEmpty;

  /// Future that resolves when the initial build is completed.
  Future<void> get firstBuild async {
    while (_initialBuildQueue.isNotEmpty) {
      await _initialBuildQueue.first;
    }
  }

  /// Rebuilds [child] and correctly accounts for any asynchronous operations that can
  /// occur during the initial build of the app.
  /// We want the component and element apis to stay synchronous, so this delays
  /// the execution of [child.performRebuild()] instead of calling it directly.
  void performRebuildOn(Element? child, [void Function()? whenComplete]) {
    var asyncFirstBuild = child?._asyncFirstBuild;
    if (asyncFirstBuild is Future) {
      assert(isFirstBuild, 'Only the first build is allowed to be asynchronous.');
      _initialBuildQueue.add(asyncFirstBuild);
      asyncFirstBuild.whenComplete(() {
        child?.performRebuild();
        _initialBuildQueue.remove(asyncFirstBuild);
        whenComplete?.call();
      });
    } else {
      child?.performRebuild();
      whenComplete?.call();
    }
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

  final Map<String, SyncStateMixin> _globalSyncRegistry = {};

  void _registerSyncState(SyncStateMixin syncState) {
    _globalSyncRegistry[syncState._syncId!] = syncState;
  }

  void _unregisterSyncState(SyncStateMixin syncState) {
    if (_globalSyncRegistry[syncState._syncId] == syncState) {
      _globalSyncRegistry.remove(syncState._syncId);
    }
  }
}

/// In difference to Flutter, we have multiple build schedulers instead of one global build owner
/// Particularly each dom element is a build scheduler and manages its subtree of components
mixin BuildScheduler on Element {
  DomView? _view;

  DomView get view => _view!;
  set view(DomView v) {
    _view = v;
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
