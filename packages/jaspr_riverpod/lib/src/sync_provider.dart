// ignore_for_file: invalid_use_of_internal_member, subtype_of_sealed_class

import 'dart:async';
import 'dart:convert';

import 'package:jaspr/jaspr.dart';
import 'package:meta/meta.dart';

import 'internals.dart';

part 'sync_provider/base.dart';
part 'sync_provider/sync_scope.dart';

ProviderElementProxy<AsyncValue<T>, Future<T>> _future<T>(_SyncProviderBase<T> that) {
  return ProviderElementProxy<AsyncValue<T>, Future<T>>(that, (element) {
    return FutureHandlerProviderElementMixin.futureNotifierOf(element as FutureHandlerProviderElementMixin<T>);
  });
}

/// {@template jaspr_riverpod.sync_provider}
/// A provider that preloads a value on the server and syncs it to the client.
///
/// This provider takes an additional [id] to uniquely identify this provider between the
/// client and server. This id must be unique across your app.
///
/// - On the server, a [SyncProvider] can be considered as a normal [FutureProvider]
/// that returns a future. Thus, the exposed state of a [SyncProvider<T>] is an [AsyncValue<T>].
/// - On the client, the value of a [SyncProvider] is automatically inserted and it's create function
/// is never executed.
///
/// To properly preload a sync provider on the server, use the [SyncProviderDependencies] mixin
/// on your component and populate the [preloadDependencies] with your provider.
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
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.name,
    required super.from,
    required super.argument,
    required super.debugGetCreateSourceHash,
  });

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
