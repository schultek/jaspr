part of framework;

extension _SyncKey on GlobalKey {
  bool get _canSync {
    var state = currentState;
    return state != null && state is SyncStateMixin;
  }

  SyncStateMixin get _currentState => currentState as SyncStateMixin;

  String get _id => _currentState.syncId;

  void _notifyState(String? state) {
    var s = _currentState;
    s.updateState(state != null ? s.syncCodec.decode(state) : null);
  }

  String _saveState() {
    var s = _currentState;
    return s.syncCodec.encode(s.saveState());
  }
}

/// Mixin on [State] that syncs state data from the server with the client
///
/// Requires a [GlobalKey] on the component.
mixin SyncStateMixin<T extends StatefulComponent, U> on State<T> {
  /// Codec used to serialize the state data on the server and deserialize on the client
  Codec<U, String> get syncCodec => StateJsonCodec();

  /// Globally unique id used to identify the state data between server and client
  String get syncId;

  /// Called on the server after the initial build, to retrieve the state data of this component.
  U saveState();

  /// Called on the client when a new state value is available, either when the state is first initialized, or when the
  /// state becomes available through lazy loading a route.
  ///
  /// On initialization, this will be called as part of the `super.initState()` call. It is recommended to start with the
  /// inherited method call in you custom `initState()` implementation, however when you want to do some work before the
  /// initial `updateState()` call, you can invoke the `super.initState()` later in your implementation.
  ///
  /// ```dart
  /// @override
  /// void initState() {
  ///   // do some pre-initialization
  ///   super.initState(); // this will also call your updateState() implementation
  ///   // do some post-initialization
  /// }
  /// ```
  void updateState(U? value);

  @override
  void initState() {
    super.initState();
    assert((() {
      if (component.key is! GlobalKey) {
        print('[WARNING] Using SyncStateMixin without a GlobalKey is not supported and '
            'will result in unsynched state. Please make sure that the component has a '
            'GlobalKey.');
      }
      return true;
    })());
    if (_element!.root.isClient) {
      var key = component.key;
      if (key is GlobalKey && key._canSync) {
        key._notifyState(_element!.root.getRawState(key._id));
      }
    }
  }
}

/// State codec that will encode / decode the state data to / from JSON
class StateJsonCodec<T> extends Codec<T, String> {
  @override
  Converter<String, T> get decoder => JsonDecoder().cast();
  @override
  Converter<T, String> get encoder => JsonEncoder().cast();
}

/// This defers the first rendering on the client for an async task
mixin DeferRenderMixin<T extends StatefulComponent> on State<T> {
  Future<void> get defer => _deferFuture ?? Future.value();
  Future? _deferFuture;

  bool _defer() {
    if (_element!.root.isClient && _element!.root.isFirstBuild) {
      _deferFuture = Future.sync(() async {
        await beforeFirstRender();
        _element!._initState();
      });
      return true;
    }
    return false;
  }

  /// Called on the client before initState() to perform some asynchronous task
  Future<void> beforeFirstRender();
}

/// Mixin on [State] that preloads state on the server
mixin PreloadStateMixin<T extends StatefulComponent> on State<T> {
  Future<void> get preloadFuture => _preloadFuture ?? Future.value();
  Future? _preloadFuture;

  bool _preload() {
    if (!_element!.root.isClient) {
      _preloadFuture = Future.sync(() async {
        await preloadState();
        _element!._initState();
      });
      return true;
    }
    return false;
  }

  /// Called on the server before initState() to preload asynchronous data
  @protected
  Future<void> preloadState();
}
