part of framework;

/// Mixin on [State] that syncs state data from the server with the client
///
/// Requires a [GlobalKey] on the component.
mixin SyncStateMixin<T extends StatefulComponent, U> on State<T> {
  /// Codec used to serialize the state data on the server and deserialize on the client
  /// Should convert the state to any dynamic type: Null, bool, double, int, Uint8List, String, Map, List
  Codec<U, dynamic> get syncCodec => CastCodec();

  /// Globally unique id used to identify the state data between server and client
  /// Returns null if state should not be synced
  String? get syncId;

  late String? _syncId;

  /// Called on the server after the initial build, to retrieve the state data of this component.
  U saveState();

  dynamic _saveState() {
    return syncCodec.encode(saveState());
  }

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
  void updateState(U? value);

  void _updateState(dynamic state) {
    updateState(state != null ? syncCodec.decode(state) : null);
  }

  @override
  void initState() {
    super.initState();
    _syncId = syncId; // Call getter once and save result
    if (_syncId != null) {
      _element!.root._registerSyncState(this);
      if (_element!.root.isClient) {
        _updateState(_element!.root.getRawState(_syncId!));
      }
    }
  }

  @override
  void dispose() {
    if (_syncId != null) {
      _element!.root._unregisterSyncState(this);
    }
    super.dispose();
  }
}

class SimpleCodec<T, R> extends Codec<T, R> {
  SimpleCodec(T Function(R) decode, R Function(T) encode)
      : decoder = SimpleConverter(decode),
        encoder = SimpleConverter(encode);

  @override
  final Converter<R, T> decoder;
  @override
  final Converter<T, R> encoder;
}

class SimpleConverter<T, R> extends Converter<T, R> {
  SimpleConverter(this._convert);

  final R Function(T) _convert;

  @override
  R convert(T input) => _convert(input);
}

Type typeOf<T>() => T;

class CastCodec<T> extends Codec<T, dynamic> {
  @override
  Converter<dynamic, T> get decoder => SimpleConverter((v) {
        if (T == typeOf<Map<String, dynamic>>() && v is Map) {
          v = v.cast<String, dynamic>();
        }
        return v;
      });

  @override
  Converter<T, dynamic> get encoder => SimpleConverter((v) => v);
}

const stateCodec = StateCodec();

class StateCodec extends Codec<dynamic, String> {
  const StateCodec();

  @override
  final Converter<String, dynamic> decoder = const StateDecoder();
  @override
  final Converter<dynamic, String> encoder = const StateEncoder();
}

class StateDecoder extends Converter<String, dynamic> {
  const StateDecoder();

  @override
  dynamic convert(String input) {
    var binary = base64Decode(input);
    return binaryCodec.decode(binary);
  }
}

class StateEncoder extends Converter<dynamic, String> {
  const StateEncoder();
  @override
  String convert(dynamic input) {
    var binary = binaryCodec.encode(input);
    return base64UrlEncode(binary);
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
