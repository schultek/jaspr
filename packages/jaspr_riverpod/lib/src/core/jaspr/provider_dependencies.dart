// ignore_for_file: library_private_types_in_public_api

part of '../../core.dart';

class ProviderDependencies {
  final Element dependent;
  final _UncontrolledProviderScopeElement parent;

  ProviderDependencies(this.dependent, this.parent);

  ProviderContainer? listenedContainer;

  Map<ProviderListenable, ProviderSubscription> watchers = {};
  Map<ProviderListenable, ProviderSubscription> listeners = {};

  Map<ProviderListenable, ProviderSubscription> oldWatchers = {};
  Map<ProviderListenable, ProviderSubscription> oldListeners = {};

  void didRebuild() {
    var oldSubscriptions = [...oldWatchers.values, ...oldListeners.values];
    for (var subscription in oldSubscriptions) {
      subscription.close();
    }

    oldWatchers = watchers;
    watchers = {};
    oldListeners = listeners;
    listeners = {};
  }

  void deactivate() {
    var allSubscriptions = [...watchers.values, ...oldWatchers.values, ...listeners.values, ...oldListeners.values];
    for (var subscription in allSubscriptions) {
      subscription.close();
    }

    oldWatchers = {};
    watchers = {};
    oldListeners = {};
    listeners = {};
  }

  ProviderContainer checkContainer() {
    var container = ProviderScope.containerOf(dependent);
    if (listenedContainer != null && listenedContainer != container) {
      deactivate();
    }
    return listenedContainer = container;
  }

  T watch<T>(ProviderListenable<T> target) {
    var container = checkContainer();

    if (!watchers.containsKey(target)) {
      if (oldWatchers.containsKey(target)) {
        watchers[target] = oldWatchers.remove(target)!;
      } else {
        // create a new [ProviderSubscription] and add it to the dependencies

        var subscription = container.listen<T>(target, (_, v) {
          if (watchers[target] == null && oldWatchers[target] == null) return;

          // trigger a rebuild for this dependent
          dependent.markNeedsBuild();
        });

        watchers[target] = subscription;
      }
    }

    return watchers[target]!.readSafe().valueOrProviderException;
  }

  void listen<T>(
    ProviderListenable<T> target,
    void Function(T? previous, T value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    var container = checkContainer();

    // close any existing listeners for the same provider
    if (listeners.containsKey(target)) {
      listeners[target]!.close();
      fireImmediately = false;
    }

    if (oldListeners.containsKey(target)) {
      oldListeners.remove(target)!.close();
      fireImmediately = false;
    }

    var subscription = container.listen(target, listener, fireImmediately: fireImmediately, onError: onError);

    listeners[target] = subscription;
  }
}
