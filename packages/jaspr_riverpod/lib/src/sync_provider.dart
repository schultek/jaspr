// ignore_for_file: invalid_use_of_internal_member, subtype_of_sealed_class

import 'dart:async';

import 'package:jaspr/jaspr.dart';

import 'internals.dart';

part 'sync_provider/sync_scope.dart';
part 'sync_provider/base.dart';

ProviderElementProxy<AsyncValue<T>, Future<T>> _future<T>(
  _SyncProviderBase<T> that,
) {
  return ProviderElementProxy<AsyncValue<T>, Future<T>>(
    that,
    (element) {
      return FutureHandlerProviderElementMixin.futureNotifierOf(
        element as FutureHandlerProviderElementMixin<T>,
      );
    },
  );
}

/// {@template jaspr_riverpod.syncprovider}
/// A provider that preloads a value on the server and syncs it to the client.
///
/// [SyncProvider] can be considered as a [FutureProvider].
///
/// It can then be combined with:
/// - [SyncProvider.family], for parameterizing the loading function.
///
/// See also:
///
/// - [Provider], a provider that synchronously creates a value
/// - [FutureProvider], a provider that asynchronously exposes a value that
///   can change over time.
/// - [SyncProvider.family], to create a [SyncProvider] from external parameters
/// {@endtemplate}
abstract class _SyncProviderBase<T> extends ProviderBase<AsyncValue<T>> {
  _SyncProviderBase({
    required this.dependencies,
    required super.name,
    required super.from,
    required super.argument,
    required super.debugGetCreateSourceHash,
  });

  @override
  final List<ProviderOrFamily>? dependencies;

  /// Obtains the [Future] associated with a [SyncProvider].
  ///
  /// The instance of [Future] obtained may change over time, if the provider
  /// was recreated (such as when using [Ref.watch]).
  ///
  /// This provider allows using `async`/`await` to easily combine
  /// [FutureProvider] together.
  ProviderListenable<Future<T>> get future;

  FutureOr<T> _create(covariant SyncProviderElement<T> ref);
}
