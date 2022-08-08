import 'dart:convert';

import 'package:binary_codec/binary_codec.dart';
import 'package:meta/meta.dart';

import 'binding.dart';

mixin SyncBinding on BindingBase {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static SyncBinding? _instance;
  static SyncBinding? get instance => _instance!;

  /// Returns the accumulated data from all active [State]s that use the [SyncStateMixin]
  @protected
  Map<String, dynamic> getStateData() {
    var state = <String, dynamic>{};
    for (var key in _globalSyncRegistry.keys) {
      var syncState = _globalSyncRegistry[key]!;
      assert(syncState.syncId == key);
      if (syncState.wantsSync()) {
        state[key] = syncState._get();
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
        assert(state.syncId == key);
        if (state.wantsSync()) {
          state._update(data[key]);
        }
      }
    }
  }

  /// On the client, this should perform a http request to [url] to fetch state data from the server.
  @protected
  Future<Map<String, dynamic>> fetchState(String url);

  final Map<String, SyncState> _globalSyncRegistry = {};

  void registerSyncState(SyncState syncState, {bool initialUpdate = true}) {
    _globalSyncRegistry[syncState.syncId] = syncState;
    if (initialUpdate && syncState.wantsSync()) {
      var data = getRawState(syncState.syncId);
      syncState._update(data);
    }
  }

  void unregisterSyncState(SyncState syncState) {
    if (_globalSyncRegistry[syncState.syncId] == syncState) {
      _globalSyncRegistry.remove(syncState.syncId);
    }
  }

  T? getInitialState<T>(String id, {Codec<T, dynamic>? codec}) {
    var data = getRawState(id);
    return data == null || codec == null ? data : codec.decode(data);
  }
}

/// Interface to sync state across server and client
abstract class SyncState<U> {
  /// Codec used to serialize the state data on the server and deserialize on the client
  /// Should convert the state to any dynamic type: Null, bool, double, int, Uint8List, String, Map, List
  Codec<U, dynamic>? get syncCodec;

  /// Globally unique id used to identify the state data between server and client
  String get syncId;

  /// Called on the server after the initial build, to retrieve the state data of this component.
  @visibleForOverriding
  U getState();

  /// Called on the client when a new state value is available, either when the state is first initialized, or when the
  /// state becomes available through lazy loading a route.
  @visibleForOverriding
  void updateState(U? value);

  /// Can be overridden to signal that the state should not be synced
  @protected
  bool wantsSync();
}

extension _SyncEncoding<U> on SyncState<U> {
  _update(dynamic data) {
    if (data == null || syncCodec == null) {
      updateState(data);
    } else {
      updateState(syncCodec!.decode(data));
    }
  }

  U _get() {
    var state = getState();
    return syncCodec != null ? syncCodec!.encode(state) : state;
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
