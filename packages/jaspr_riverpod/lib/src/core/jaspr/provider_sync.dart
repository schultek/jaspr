// ignore_for_file: invalid_use_of_internal_member
part of '../../core.dart';

sealed class ProviderSync {}

class _ProviderSync<T> implements ProviderSync {
  _ProviderSync(this.provider, this.id, this.codec, this.fn);

  final ProviderBase<T> provider;
  final String id;
  final Codec<T, Object?>? codec;
  final Override Function(Object? value) fn;
}

extension SyncNotifierExtension<NotifierT extends Notifier<T>, T> on NotifierProvider<NotifierT, T> {
  ProviderSync syncWith(String id, {Codec<T, Object?>? codec}) {
    return _ProviderSync(this, id, codec, (value) {
      return overrideWithBuild((_, _) => value as T);
    });
  }
}

extension SyncAsyncNotifierExtension<NotifierT extends AsyncNotifier<T>, T> on AsyncNotifierProvider<NotifierT, T> {
  ProviderSync syncWith(String id, {Codec<T, Object?>? codec}) {
    return _ProviderSync(this, id, codec, (value) {
      return overrideWithBuild((_, _) => value as T);
    });
  }
}

extension SyncProviderExtension<T> on Provider<T> {
  ProviderSync syncWith(String id, {Codec<T, Object?>? codec}) {
    return _ProviderSync(this, id, codec, (value) {
      return overrideWithValue(value as T);
    });
  }
}

extension SyncFutureProviderExtension<T> on FutureProvider<T> {
  ProviderSync syncWith(String id, {Codec<T, Object?>? codec}) {
    return _ProviderSync(this, id, codec, (value) {
      return overrideWithValue(AsyncValue.data(value as T));
    });
  }
}

extension SyncStreamProviderExtension<T> on StreamProvider<T> {
  ProviderSync syncWith(String id, {Codec<T, Object?>? codec}) {
    return _ProviderSync(this, id, codec, (value) {
      return overrideWithValue(AsyncValue.data(value as T));
    });
  }
}

extension SyncStateProviderExtension<T> on StateProvider<T> {
  ProviderSync syncWith(String id, {Codec<T, Object?>? codec}) {
    return _ProviderSync(this, id, codec, (value) {
      return overrideWith((_) => value as T);
    });
  }
}

mixin SyncScopeMixin on State<ProviderScope>
    implements PreloadStateMixin<ProviderScope>, SyncStateMixin<ProviderScope, Map<String, Object?>?> {
  ProviderContainer get container;

  final Map<String, Object?> _syncValues = {};

  Future<void> _preloadSyncProviders() {
    if (component.sync.isEmpty) {
      return Future.value();
    }
    final futures = <Future<void>>[];
    for (final s in component.sync) {
      final provider = (s as _ProviderSync).provider;
      final Object? value;
      if (provider is $FutureModifier) {
        value = container.read(provider.future);
      } else {
        value = container.read(provider);
      }
      if (value is Future) {
        futures.add(value);
        value.then((v) => _syncValues[s.id] = s.codec?.encode(v) ?? v);
      } else {
        _syncValues[s.id] = s.codec?.encode(value) ?? value;
      }
    }
    return futures.wait;
  }

  @override
  Map<String, Object?>? getState() {
    return _syncValues;
  }

  final List<Override> _syncOverrides = [];

  @override
  void updateState(Map<String, Object?>? value) {
    if (value == null) {
      return;
    }
    for (final s in component.sync) {
      if (!value.containsKey((s as _ProviderSync).id)) {
        continue;
      }

      final encodedValue = value[s.id];
      final Object? decodedValue;
      if (s.codec case final codec? when encodedValue != null) {
        decodedValue = codec.decode(encodedValue);
      } else {
        decodedValue = encodedValue;
      }

      _syncOverrides.add(s.fn(decodedValue));
    }
  }

  @override
  void initState() {
    super.initState();
    SyncStateMixin.initSyncState(this);
  }
}
