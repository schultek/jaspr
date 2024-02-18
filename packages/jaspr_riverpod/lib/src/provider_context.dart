part of 'framework.dart';

extension ProviderContext on BuildContext {
  /// Reads a provider without listening to it
  T read<T>(ProviderListenable<T> provider) {
    return ProviderScope.containerOf(this, listen: false).read(provider);
  }

  /// Refreshes a provider
  T refresh<T>(Refreshable<T> provider) {
    return ProviderScope.containerOf(this, listen: false).refresh(provider);
  }

  /// Invalidates a provider
  void invalidate(ProviderOrFamily provider) {
    ProviderScope.containerOf(this, listen: false).invalidate(provider);
  }

  /// Watches a provider and rebuilds the current context on change
  T watch<T>(ProviderListenable<T> provider) {
    _ensureDebugDoingBuild('watch');
    return ProviderScope._scopeOf(this, listen: true)._watch(this, provider);
  }

  /// Listens to a provider and automatically manages the subscription
  void listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ensureDebugDoingBuild('listen');
    return ProviderScope._scopeOf(this, listen: true)._listen(
      this,
      provider,
      listener,
      onError: onError,
      fireImmediately: fireImmediately,
    );
  }

  /// Listens to a provider and returns the subscription.
  ProviderSubscription<T> subscribe<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    return ProviderScope._scopeOf(this, listen: false)._subscribe(
      provider,
      listener,
      onError: onError,
      fireImmediately: fireImmediately,
    );
  }

  void _ensureDebugDoingBuild(String method) {
    assert(() {
      if (!debugDoingBuild) {
        throw StateError(
            'context.$method can only be used within the build method of a widget. When calling: ${StackTrace.current}');
      }
      return true;
    }());
  }
}
