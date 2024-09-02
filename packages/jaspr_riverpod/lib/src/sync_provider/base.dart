// ignore_for_file: invalid_use_of_internal_member, subtype_of_sealed_class

part of '../sync_provider.dart';

/// {@macro riverpod.providerrefbase}
/// - [state], the value currently exposed by this provider.
abstract class SyncProviderRef<State> implements Ref<AsyncValue<State>> {
  /// Obtains the state currently exposed by this provider.
  ///
  /// Mutating this property will notify the provider listeners.
  ///
  /// Cannot be called while a provider is creating, unless the setter was called first.
  ///
  /// Will throw if the provider threw during creation.
  AsyncValue<State> get state;
  set state(AsyncValue<State> newState);

  /// Obtains the [Future] associated to this provider.
  ///
  /// This is equivalent to doing `ref.read(myProvider.future)`.
  /// See also [SyncProvider.future].
  Future<State> get future;
}

/// {@macro riverpod.syncprovider}
class SyncProvider<T> extends _SyncProviderBase<T>
    with AlwaysAliveProviderBase<AsyncValue<T>>, AlwaysAliveAsyncSelector<T> {
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
  FutureOr<T> _create(SyncProviderElement<T> ref) {
    if (kIsWeb) {
      return ref.watch(_syncStateProvider.select((s) {
        if (!s.containsKey(id)) {
          return Completer<T>().future;
        }
        var value = s[id];
        return value != null && codec != null ? codec!.decode(value) : value;
      }));
    }
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
class SyncProviderElement<T> extends ProviderElementBase<AsyncValue<T>>
    with FutureHandlerProviderElementMixin<T>
    implements SyncProviderRef<T> {
  SyncProviderElement._(_SyncProviderBase<T> super.provider);

  @override
  Future<T> get future {
    flush();
    return futureNotifier.value;
  }

  @override
  bool updateShouldNotify(AsyncValue<T> previous, AsyncValue<T> next) {
    return FutureHandlerProviderElementMixin.handleUpdateShouldNotify(
      previous,
      next,
    );
  }

  @override
  void create({required bool didChangeDependency}) {
    final provider = this.provider as _SyncProviderBase<T>;

    return handleFuture(
      () => provider._create(this),
      didChangeDependency: didChangeDependency,
    );
  }
}

/// The [Family] of a [SyncProvider]
class SyncProviderFamily<R, Arg>
    extends FamilyBase<SyncProviderRef<R>, AsyncValue<R>, Arg, FutureOr<R>, SyncProvider<R>> {
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
