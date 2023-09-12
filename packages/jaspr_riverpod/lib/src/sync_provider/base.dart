// ignore_for_file: invalid_use_of_internal_member, subtype_of_sealed_class

part of '../sync_provider.dart';

/// {@macro riverpod.providerrefbase}
/// - [state], the value currently exposed by this provider.
abstract class SyncProviderRef<State> implements Ref<State> {
  /// Obtains the state currently exposed by this provider.
  ///
  /// Mutating this property will notify the provider listeners.
  ///
  /// Cannot be called while a provider is creating, unless the setter was called first.
  ///
  /// Will throw if the provider threw during creation.
  AsyncValue<State> get value;
  set value(AsyncValue<State> newState);

  /// Obtains the [Future] associated to this provider.
  ///
  /// This is equivalent to doing `ref.read(myProvider.future)`.
  /// See also [SyncProvider.future].
  Future<State> get future;
}

/// {@macro riverpod.syncprovider}
class SyncProvider<T> extends _SyncProviderBase<T> with AlwaysAliveProviderBase<T> {
  /// {@macro riverpod.syncprovider}
  SyncProvider(
    this._createFn, {
    required this.id,
    this.codec,
    super.name,
    super.dependencies,
    @Deprecated('Will be removed in 3.0.0') super.from,
    @Deprecated('Will be removed in 3.0.0') super.argument,
    @Deprecated('Will be removed in 3.0.0') super.debugGetCreateSourceHash,
  }) : super(
          allTransitiveDependencies: computeAllTransitiveDependencies(dependencies),
        );

  /// An implementation detail of Riverpod
  @internal
  SyncProvider.internal(
    this._createFn, {
    required this.id,
    this.codec,
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    super.from,
    super.argument,
  });

  /// {@macro riverpod.family}
  static const family = SyncProviderFamilyBuilder();

  final FutureOr<T> Function(SyncProviderRef<T> ref) _createFn;

  /// The unique id to sync between server and client.
  final String id;

  final Codec<T, dynamic>? codec;

  @override
  late final AlwaysAliveRefreshable<Future<T>> future = _future(this);

  @override
  late final AlwaysAliveRefreshable<AsyncValue<T>> value = _value(this);

  @override
  FutureOr<T> _create(SyncProviderElement<T> ref) {
    return _createFn(ref);
  }

  @override
  SyncProviderElement<T> createElement() => SyncProviderElement._(this);

  /// {@macro riverpod.overridewith}
  Override overrideWith(Create<FutureOr<T>, SyncProviderRef<T>> create) {
    return ProviderOverride(
      origin: this,
      override: SyncProvider.internal(
        create,
        id: id,
        codec: codec,
        from: from,
        argument: argument,
        debugGetCreateSourceHash: null,
        dependencies: null,
        allTransitiveDependencies: null,
        name: null,
      ),
    );
  }
}

/// The element of a [SyncProvider]
class SyncProviderElement<T> extends ProviderElementBase<T> implements SyncProviderRef<T> {
  SyncProviderElement._(_SyncProviderBase<T> super.provider);

  /// An observable for [SyncProvider.future].
  @internal
  final futureNotifier = ProxyElementValueNotifier<Future<T>>();
  Completer<T>? _futureCompleter;
  Future<T>? _lastFuture;
  CancelAsyncSubscription? _lastFutureSub;
  CancelAsyncSubscription? _cancelSubscription;

  /// Handles manual state change (as opposed to automatic state change from
  /// listening to the [Future]).
  @protected
  AsyncValue<T> get state => requireState;

  @protected
  set state(AsyncValue<T> newState) {
    // TODO assert Notifier isn't disposed
    newState.map(
      loading: _onLoading,
      error: onError,
      data: onData,
    );
  }

  void _onLoading(AsyncLoading<T> value, {bool seamless = false}) {
    asyncTransition(value, seamless: seamless);
    if (_futureCompleter == null) {
      final completer = _futureCompleter = Completer();
      futureNotifier.result = ResultData(completer.future);
    }
  }

  /// Life-cycle for when an error from the provider's "build" method is received.
  ///
  /// Might be invokved after the element is disposed in the case where `provider.future`
  /// has yet to complete.
  @internal
  void onError(AsyncError<T> value, {bool seamless = false}) {
    if (mounted) {
      asyncTransition(value, seamless: seamless);
    }

    final completer = _futureCompleter;
    if (completer != null) {
      completer
        // TODO test ignore
        ..future.ignore()
        ..completeError(
          value.error,
          value.stackTrace,
        );
      _futureCompleter = null;
      // TODO SynchronousFuture.error
    } else if (mounted) {
      futureNotifier.result = Result.data(
        // TODO test ignore
        Future.error(
          value.error,
          value.stackTrace,
        )..ignore(),
      );
    }
  }

  /// Life-cycle for when a data from the provider's "build" method is received.
  ///
  /// Might be invokved after the element is disposed in the case where `provider.future`
  /// has yet to complete.
  @internal
  void onData(AsyncData<T> value, {bool seamless = false}) {
    if (mounted) {
      asyncTransition(value, seamless: seamless);
    }

    final completer = _futureCompleter;
    if (completer != null) {
      completer.complete(value.value);
      _futureCompleter = null;
    } else if (mounted) {
      futureNotifier.result = Result.data(Future.value(value.value));
    }
  }

  /// Listens to a [Future] and convert it into an [AsyncValue].
  @internal
  void handleFuture(
    FutureOr<T> Function() create, {
    required bool didChangeDependency,
  }) {
    _handleAsync(didChangeDependency: didChangeDependency, ({
      required data,
      required done,
      required error,
      required last,
    }) {
      final futureOr = create();
      if (futureOr is! Future<T>) {
        data(futureOr);
        done();
        return null;
      }
      // Received a Future<T>

      var running = true;
      void cancel() {
        running = false;
      }

      futureOr.then(
        (value) {
          if (!running) return;
          data(value);
          done();
        },
        // ignore: avoid_types_on_closure_parameters
        onError: (Object err, StackTrace stackTrace) {
          if (!running) return;
          error(err, stackTrace);
          done();
        },
      );

      last(futureOr, cancel);

      return cancel;
    });
  }

  /// Listens to a [Future] and transforms it into an [AsyncValue].
  void _handleAsync(
    // Stream<T> Function({required void Function(T) fireImmediately}) create,
    CancelAsyncSubscription? Function({
      required void Function(T) data,
      required void Function(Object, StackTrace) error,
      required void Function() done,
      required void Function(Future<T>, CancelAsyncSubscription) last,
    }) listen, {
    required bool didChangeDependency,
  }) {
    _onLoading(AsyncLoading<T>(), seamless: !didChangeDependency);

    try {
      final sub = _cancelSubscription = listen(
        data: (value) {
          onData(AsyncData(value), seamless: !didChangeDependency);
        },
        error: (error, stack) {
          onError(AsyncError(error, stack), seamless: !didChangeDependency);
        },
        last: (last, sub) {
          assert(_lastFuture == null, 'bad state');
          assert(_lastFutureSub == null, 'bad state');
          _lastFuture = last;
          _lastFutureSub = sub;
        },
        done: () {
          _lastFutureSub?.call();
          _lastFutureSub = null;
          _lastFuture = null;
        },
      );
      assert(
        sub == null || _lastFuture != null,
        'An async operation is pending but the state for provider.future was not initialized.',
      );

      // TODO test build throws -> provider emits AsyncError synchronously & .future emits Future.error
      // TODO test build resolves with error -> emits AsyncError & .future emits Future.error
      // TODO test build emits value -> .future emits value & provider emits AsyncData
    } catch (error, stackTrace) {
      onError(
        AsyncError<T>(error, stackTrace),
        seamless: !didChangeDependency,
      );
    }
  }

  @override
  @internal
  void runOnDispose() {
    // Stops listening to the previous async operation
    _lastFutureSub?.call();
    _lastFutureSub = null;
    _lastFuture = null;
    _cancelSubscription?.call();
    _cancelSubscription = null;
    super.runOnDispose();
  }

  @override
  void dispose() {
    final completer = _futureCompleter;
    if (completer != null) {
      // Whatever happens after this, the error is emitted post dispose of the provider.
      // So the error doesn't matter anymore.
      completer.future.ignore();

      final lastFuture = _lastFuture;
      if (lastFuture != null) {
        // The completer will be completed by the while loop in handleStream

        final cancelSubscription = _cancelSubscription;
        if (cancelSubscription != null) {
          completer.future
              .then(
                (_) {},
                // ignore: avoid_types_on_closure_parameters
                onError: (Object _) {},
              )
              .whenComplete(cancelSubscription);
        }

        // Prevent super.dispose from cancelling the subscription on the "last"
        // stream value, so that it can be sent to `provider.future`.
        _lastFuture = null;
        _lastFutureSub = null;
        _cancelSubscription = null;
      } else {
        // The listened stream completed during a "loading" state.
        completer.completeError(
          _missingLastValueError(),
          StackTrace.current,
        );
      }
    }
    super.dispose();
  }

  @override
  void visitChildren({
    required void Function(ProviderElementBase<Object?> element) elementVisitor,
    required void Function(ProxyElementValueNotifier<Object?> element) notifierVisitor,
  }) {
    super.visitChildren(
      elementVisitor: elementVisitor,
      notifierVisitor: notifierVisitor,
    );
    notifierVisitor(futureNotifier);
  }

  @override
  Future<T> get future {
    flush();
    return futureNotifier.value;
  }

  @override
  void create({required bool didChangeDependency}) {
    final provider = this.provider as _SyncProviderBase<T>;

    if (ref.binding.isClient) {
      return ref.watch(_syncStateProvider.select((s) {
        if (!s.containsKey(id)) {
          return Completer<T>().future;
        }
        var value = s[id];
        return value != null ? (codec ?? CastCodec()).decode(value) : value;
      }));
    }

    return handleFuture(
      () => provider._create(this),
      didChangeDependency: didChangeDependency,
    );
  }
}

/// The [Family] of a [SyncProvider]
class SyncProviderFamily<R, Arg> extends FamilyBase<SyncProviderRef<R>, R, Arg, FutureOr<R>, SyncProvider<R>> {
  /// The [Family] of a [SyncProvider]
  SyncProviderFamily(
    super.create, {
    required this.id,
    this.codec,
    super.name,
    super.dependencies,
  }) : super(
          providerFactory: (
            Create<FutureOr<R>, SyncProviderRef<R>> create, {
            required String? name,
            Family? from,
            Object? argument,
            required Iterable<ProviderOrFamily>? dependencies,
            required String Function()? debugGetCreateSourceHash,
            required Set<ProviderOrFamily>? allTransitiveDependencies,
          }) =>
              SyncProvider<R>.internal(create,
                  id: id,
                  codec: codec,
                  name: name,
                  dependencies: dependencies,
                  allTransitiveDependencies: allTransitiveDependencies,
                  debugGetCreateSourceHash: debugGetCreateSourceHash,
                  from: from,
                  argument: argument),
          allTransitiveDependencies: computeAllTransitiveDependencies(dependencies),
          debugGetCreateSourceHash: null,
        );

  final String id;

  final Codec<R, dynamic>? codec;

  /// {@macro riverpod.overridewith}
  Override overrideWith(
    FutureOr<R> Function(SyncProviderRef<R> ref, Arg arg) create,
  ) {
    return FamilyOverrideImpl<AsyncValue<R>, Arg, SyncProvider<R>>(
      this,
      (arg) => SyncProvider<R>.internal(
        (ref) => create(ref, arg),
        id: id,
        codec: codec,
        from: from,
        argument: arg,
        debugGetCreateSourceHash: null,
        dependencies: null,
        allTransitiveDependencies: null,
        name: null,
      ),
    );
  }
}

/// Builds a [SyncProviderFamily].
class SyncProviderFamilyBuilder {
  /// Builds a [SyncProviderFamily].
  const SyncProviderFamilyBuilder();

  /// {@macro riverpod.family}
  SyncProviderFamily<State, Arg> call<State, Arg>(
    FamilyCreate<FutureOr<State>, SyncProviderRef<State>, Arg> create, {
    required String id,
    Codec<State, dynamic>? codec,
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) {
    return SyncProviderFamily<State, Arg>(
      create,
      id: id,
      codec: codec,
      name: name,
      dependencies: dependencies,
    );
  }
}
