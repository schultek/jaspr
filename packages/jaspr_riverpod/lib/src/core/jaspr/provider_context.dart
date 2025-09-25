part of '../../core.dart';

extension ProviderContext on BuildContext {
  /// Returns the value exposed by a provider and rebuild the component when that
  /// value changes.
  ///
  /// This method should only be used at the "root" of the `build` method of a component.
  ///
  /// **Good**: Use [watch] inside the `build` method.
  /// ```dart
  /// class Example extends StatelessComponent {
  ///   @override
  ///   Component build(BuildContext context) {
  ///     // Correct, we are inside the build method and at its root.
  ///     final count = context.watch(counterProvider);
  ///   }
  /// }
  /// ```
  /// **Good**: It is accepted to use [watch] at the root of "builders" too.
  /// ```dart
  /// class Example extends StatelessComponent {
  ///   @override
  ///   Component build(BuildContext context) {
  ///     return Builder(
  ///       builder: (context) {
  ///          // This is accepted, as we are at the root of a "builder"
  ///          final count = context.watch(counterProvider);
  ///       },
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Don't use [watch] outside of the `build` method.
  /// ```dart
  /// class Example extends StatefulComponent {
  ///   @override
  ///   ExampleState createState() => ExampleState();
  /// }
  ///
  /// class ExampleState extends State<Example> {
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     // Incorrect, we are not inside the build method.
  ///     final count = context.watch(counterProvider);
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Don't use [watch] inside event handles withing `build` method.
  /// ```dart
  /// class Example extends StatelessComponent {
  ///   @override
  ///   Component build(BuildContext context) {
  ///     return button(
  ///       onClick: () {
  ///         // Incorrect, we are inside the build method, but neither at its
  ///         // root, nor inside a "builder".
  ///         final count = context.watch(counterProvider);
  ///       },
  ///       [],
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// - [ProviderListenableSelect.select], which allows a component to filter rebuilds by
  ///   observing only the selected properties.
  /// - [listen], to react to changes on a provider, such as for showing modals.
  T watch<T>(ProviderListenable<T> provider) {
    _ensureDebugDoingBuild('watch');
    return ProviderScope._scopeOf(this, listen: true)._watch(this, provider);
  }

  /// Determines whether a provider is initialized or not.
  ///
  /// Writing logic that conditionally depends on the existence of a provider
  /// is generally unsafe and should be avoided.
  /// The problem is that once the provider gets initialized, logic that
  /// depends on the existence or not of a provider won't be rerun; possibly
  /// causing your state to get out of date.
  ///
  /// But it can be useful in some cases, such as to avoid re-fetching an
  /// object if a different network request already obtained it:
  ///
  /// ```dart
  /// final fetchItemList = FutureProvider<List<Item>>(...);
  ///
  /// final fetchItem = FutureProvider.autoDispose.family<Item, String>((ref, id) async {
  ///   if (ref.exists(fetchItemList)) {
  ///     // If `fetchItemList` is initialized, we look into its state
  ///     // and return the already obtained item.
  ///     final itemFromItemList = await ref.watch(
  ///       fetchItemList.selectAsync((items) => items.firstWhereOrNull((item) => item.id == id)),
  ///     );
  ///     if (itemFromItemList != null) return itemFromItemList;
  ///   }
  ///
  ///   // If `fetchItemList` is not initialized, perform a network request for
  ///   // "id" separately
  ///
  ///   final json = await http.get('api/items/$id');
  ///   return Item.fromJson(json);
  /// });
  /// ```
  bool exists(ProviderBase<Object?> provider) {
    return ProviderScope.containerOf(this, listen: false).exists(provider);
  }

  /// Listen to a provider and call `listener` whenever its value changes,
  /// without having to take care of removing the listener.
  ///
  /// The [listen] method should exclusively be used at the root of the `build` method:
  ///
  /// **Good**: Use [listen] inside the `build` method.
  /// ```dart
  /// class Example extends Statelessomponent {
  ///   @override
  ///   Component build(BuildContext context) {
  ///     // Correct, we are inside the build method and at its root.
  ///     context.listen(counterProvider, (prev, next) {});
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Do not use [listen] inside builders.
  /// ```dart
  /// class Example extends StatelessComponent {
  ///   @override
  ///   Component build(BuildContext context) {
  ///     return Builder(
  ///       builder: (context) {
  ///          // Incorrect, as we are not at the root of the build method.
  ///          context.listen(counterProvider, (prev, next) {});
  ///       },
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Don't use [listen] outside of the `build` method.
  /// ```dart
  /// class Example extends StatefulComponent {
  ///   @override
  ///   ExampleState createState() => ExampleState();
  /// }
  ///
  /// class ExampleState extends State<Example> {
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     // Incorrect, we are not inside the build method.
  ///     context.listen(counterProvider, (prev, next) {});
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Don't use [listen] inside event handles withing `build` method.
  /// ```dart
  /// class Example extends StatelessComponent {
  ///   @override
  ///   Component build(BuildContext context, ComponentRef ref) {
  ///     return button(
  ///       onClick: () {
  ///         // Incorrect, we are inside the build method, but not at its
  ///         // root.
  ///         context.listen(counterProvider, (prev, next) {});
  ///       },
  ///       [],
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// **Note**:
  /// Listeners will automatically be removed if a component rebuilds and stops
  /// listening to a provider.
  ///
  /// See also:
  /// - [listenManual], for listening to a provider from outside `build`.
  /// - [watch], to listen to providers in a declarative manner.
  /// - [read], to read a provider without listening to it.
  ///
  /// This is useful for showing modals or other imperative logic.
  void listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    _ensureDebugDoingBuild('listen');
    return ProviderScope._scopeOf(
      this,
      listen: true,
    )._listen(this, provider, listener, onError: onError, fireImmediately: fireImmediately);
  }

  /// Listen to a provider and call `listener` whenever its value changes.
  ///
  /// As opposed to [listen], [listenManual] is not safe to use within the `build`
  /// method of a component.
  /// Instead, [listenManual] is designed to be used inside [State.initState] or
  /// other [State] life-cycles.
  ///
  /// [listenManual] returns a [ProviderSubscription] which can be used to stop
  /// listening to the provider, or to read the current value exposed by
  /// the provider.
  ///
  /// It is necessary to call [ProviderSubscription.close] inside [State.dispose].
  ProviderSubscription<T> listenManual<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T value) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    return ProviderScope._scopeOf(this, listen: false)._listenManual(
      provider,
      listener,
      onError: onError,
      fireImmediately: fireImmediately,
    );
  }

  /// Reads a provider without listening to it.
  ///
  /// **AVOID** calling [read] inside build if the value is used only for events:
  ///
  /// ```dart
  /// Component build(BuildContext context) {
  ///   // counter is used only for the onClick of button
  ///   final counter = context.read(counterProvider);
  ///
  ///   return button(
  ///     onClick: () => counter.increment(),
  ///   );
  /// }
  /// ```
  ///
  /// While this code is not bugged in itself, this is an anti-pattern.
  /// It could easily lead to bugs in the future after refactoring the component
  /// to use `counter` for other things, but forget to change [read] into [watch].
  ///
  /// **CONSIDER** calling [read] inside event handlers:
  ///
  /// ```dart
  /// Component build(BuildContext context) {
  ///   return button(
  ///     onClick: () {
  ///       // As performant as the previous solution, but resilient to refactoring
  ///       context.read(counterProvider).increment(),
  ///     },
  ///   );
  /// }
  /// ```
  ///
  /// This has the same efficiency as the previous anti-pattern, but does not
  /// suffer from the drawback of being brittle.
  ///
  /// **AVOID** using [read] for creating components with a value that never changes
  ///
  /// ```dart
  /// Component build(BuildContext context) {
  ///   // using read because we only use a value that never changes.
  ///   final model = context.read(modelProvider);
  ///
  ///   return Text('${model.valueThatNeverChanges}');
  /// }
  /// ```
  ///
  /// While the idea of not rebuilding the component if unnecessary is good,
  /// this should not be done with [read].
  /// Relying on [read] for optimizations is very brittle and dependent
  /// on an implementation detail.
  ///
  /// **CONSIDER** using [Provider] or `select` for filtering unwanted rebuilds:
  ///
  /// ```dart
  /// Component build(BuildContext context) {
  ///   // Using select to listen only to the value that used
  ///   final valueThatNeverChanges = context.watch(modelProvider.select((model) {
  ///     return model.valueThatNeverChanges;
  ///   }));
  ///
  ///   return Text('$valueThatNeverChanges');
  /// }
  /// ```
  ///
  /// While more verbose than [read], using [Provider]/`select` is a lot safer.
  /// It does not rely on implementation details on `Model`, and it makes it
  /// impossible to have a bug where our UI does not refresh.
  T read<T>(ProviderListenable<T> provider) {
    return ProviderScope.containerOf(this, listen: false).read(provider);
  }

  /// Forces a provider to re-evaluate its state immediately, and return the created value.
  ///
  /// Writing:
  ///
  /// ```dart
  /// final newValue = context.refresh(provider);
  /// ```
  ///
  /// is strictly identical to doing:
  ///
  /// ```dart
  /// context.invalidate(provider);
  /// final newValue = context.read(provider);
  /// ```
  ///
  /// If you do not care about the return value of [refresh], use [invalidate] instead.
  /// Doing so has the benefit of:
  /// - making the invalidation logic more resilient by avoiding multiple
  ///   refreshes at once.
  /// - possibly avoiding recomputing a provider if it isn't needed immediately.
  ///
  /// This method is useful for features like "pull to refresh" or "retry on error",
  /// to restart a specific provider.
  @useResult
  T refresh<T>(Refreshable<T> provider) {
    return ProviderScope.containerOf(this, listen: false).refresh(provider);
  }

  /// Invalidates a provider
  /// Invalidates the state of the provider, causing it to refresh.
  ///
  /// As opposed to [refresh], the refresh is not immediate and is instead
  /// delayed to the next read or next frame.
  ///
  /// Calling [invalidate] multiple times will refresh the provider only
  /// once.
  ///
  /// Calling [invalidate] will cause the provider to be disposed immediately.
  ///
  /// - [asReload] (false by default) can be optionally passed to tell
  ///   Riverpod to clear the state before refreshing it.
  ///   This is only useful for asynchronous providers, as by default,
  ///   [AsyncValue] keeps a reference on state during loading states.
  ///   Using [asReload] will disable this behavior and count as a
  ///   "hard refresh".
  ///
  /// If used on a provider which is not initialized, this method will have no effect.
  void invalidate(ProviderOrFamily provider, {bool asReload = false}) {
    ProviderScope.containerOf(this, listen: false).invalidate(provider, asReload: asReload);
  }

  void _ensureDebugDoingBuild(String method) {
    assert(() {
      if (!debugDoingBuild) {
        throw StateError(
          'context.$method can only be used within the build method of a component. When calling: ${StackTrace.current}',
        );
      }
      return true;
    }());
  }
}
