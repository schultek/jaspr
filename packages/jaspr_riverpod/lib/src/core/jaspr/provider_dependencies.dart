// ignore_for_file: library_private_types_in_public_api

part of '../../core.dart';

class ProviderDependencies {
  final Element dependent;
  final _UncontrolledProviderScopeElement parent;

  ProviderDependencies(this.dependent, this.parent);

  ProviderContainer? listenedContainer;

  Map<ProviderListenable<Object?>, ProviderSubscription<Object?>> watchers = {};
  Map<ProviderListenable<Object?>, ProviderSubscription<Object?>> listeners = {};

  Map<ProviderListenable<Object?>, ProviderSubscription<Object?>> oldWatchers = {};
  Map<ProviderListenable<Object?>, ProviderSubscription<Object?>> oldListeners = {};

  void didRebuild() {
    final oldSubscriptions = [...oldWatchers.values, ...oldListeners.values];
    for (final subscription in oldSubscriptions) {
      subscription.close();
    }

    oldWatchers = watchers;
    watchers = {};
    oldListeners = listeners;
    listeners = {};
  }

  void deactivate() {
    final allSubscriptions = [...watchers.values, ...oldWatchers.values, ...listeners.values, ...oldListeners.values];
    for (final subscription in allSubscriptions) {
      subscription.close();
    }

    oldWatchers = {};
    watchers = {};
    oldListeners = {};
    listeners = {};
  }

  ProviderContainer checkContainer() {
    final container = ProviderScope.containerOf(dependent);
    if (listenedContainer != null && listenedContainer != container) {
      deactivate();
    }
    return listenedContainer = container;
  }

  T watch<T>(ProviderListenable<T> target) {
    final container = checkContainer();

    if (!watchers.containsKey(target)) {
      if (oldWatchers.remove(target) case final oldTargetWatcher?) {
        watchers[target] = oldTargetWatcher;
      } else {
        // Create a new [ProviderSubscription] and add it to the dependencies.
        final subscription = container.listen<T>(target, (_, v) {
          if (watchers[target] == null && oldWatchers[target] == null) return;

          // Trigger a rebuild for this dependent.
          dependent.markNeedsBuild();
        });

        watchers[target] = subscription;
      }
    }

    return watchers[target]!.readSafe().valueOrProviderException as T;
  }

  void listen<T>(
    ProviderListenable<T> target,
    void Function(T? previous, T value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    final container = checkContainer();

    // close any existing listeners for the same provider
    if (listeners.containsKey(target)) {
      listeners[target]!.close();
      fireImmediately = false;
    }

    if (oldListeners.containsKey(target)) {
      oldListeners.remove(target)!.close();
      fireImmediately = false;
    }

    final subscription = container.listen(target, listener, fireImmediately: fireImmediately, onError: onError);

    listeners[target] = subscription;
  }
}
