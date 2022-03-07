part of framework;

extension ProviderContext on BuildContext {
  /// Reads a provider without listening to it
  T read<T>(ProviderBase<T> provider) {
    return ProviderScope._scopeOf(this, listen: false)._read(provider);
  }

  /// Refreshes a provider
  T refresh<T>(ProviderBase<T> provider) {
    return ProviderScope._scopeOf(this, listen: false)._refresh(provider);
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

  void invalidate(ProviderBase<Object?> provider) {
    ProviderScope.containerOf(this, listen: false).invalidate(provider);
  }

  Future<void> preload(ProviderBase provider) async {
    return ProviderScope._scopeOf(this, listen: false)._preload(provider);
  }

  void _ensureDebugDoingBuild(String method) {
    assert(() {
      if (!debugDoingBuild) {
        throw StateError('context.$method can only be used within the build method of a widget');
      }
      return true;
    }());
  }
}
