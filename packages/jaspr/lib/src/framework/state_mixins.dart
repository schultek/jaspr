part of framework;

/// Mixin on [State] that syncs state data from the server with the client
///
/// Requires a [GlobalKey] on the component.
mixin SyncStateMixin<T extends StatefulComponent, U> on State<T> implements SyncState<U> {
  /// Codec used to serialize the state data on the server and deserialize on the client
  /// Should convert the state to any dynamic type: Null, bool, double, int, Uint8List, String, Map, List
  @override
  Codec<U, dynamic>? get syncCodec => null;

  /// Globally unique id used to identify the state data between server and client
  /// Returns null if state should not be synced
  @override
  String get syncId;

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
  ///
  /// The framework won't call setState() for you, so you have to call it yourself if you want to rebuild the component.
  /// That allows for custom update logic and reduces unnecessary builds.
  @override
  void updateState(U? value);

  /// Can be overridden to signal that the state should not be synced
  @override
  bool wantsSync() => true;

  @override
  void initState() {
    super.initState();
    SyncBinding.instance!.registerSyncState(this, initialUpdate: ComponentsBinding.instance!.isClient);
  }

  @override
  void dispose() {
    SyncBinding.instance!.unregisterSyncState(this);
    super.dispose();
  }
}

/// This defers the first rendering on the client for an async task
mixin DeferRenderMixin<T extends StatefulComponent> on State<T> {
  /// Called on the client before initState() to perform some asynchronous task
  Future<void> beforeFirstRender();
}

/// Mixin on [State] that preloads state on the server
mixin PreloadStateMixin<T extends StatefulComponent> on State<T> {
  /// Called on the server before initState() to preload asynchronous data
  @protected
  Future<void> preloadState();
}
