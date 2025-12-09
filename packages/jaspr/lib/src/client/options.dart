import 'dart:async';

import '../../jaspr.dart';

/// Main class for initializing the Jaspr framework on the client.
///
/// Call [Jaspr.initializeApp] at the start of your app, before any calls to [runApp].
abstract final class Jaspr {
  static void initializeApp({
    ClientOptions options = const ClientOptions(),
  }) {
    _options = options;
    options.initialize?.call();
  }

  static bool get isInitialized => _options != null;

  static ClientOptions get options => _options ?? const ClientOptions();
  static ClientOptions? _options;
}

/// Global options for configuring Jaspr on the client.
///
/// **DO NOT USE DIRECTLY.**
/// Use the generated `defaultClientOptions` instead.
final class ClientOptions {
  const ClientOptions({this.initialize, this.clients = const {}});

  final void Function()? initialize;
  final Map<String, ClientLoader> clients;
}

/// The loader configuration for a @client component.
///
/// **DO NOT USE DIRECTLY.**
/// Use the generated `defaultClientOptions` instead.
final class ClientLoader {
  ClientLoader(this.builder, {this.loader});

  final Future<void> Function()? loader;
  final ClientBuilder builder;

  FutureOr<ClientBuilder>? _loadedBuilder;

  /// Returns the loaded [ClientBuilder].
  ///
  /// If a [loader] is provided, it will be awaited before returning the [builder].
  /// The returned [Future] is cached for future calls, so the [loader] is only called once.
  /// Once loaded, the [builder] is returned directly on subsequent calls.
  FutureOr<ClientBuilder> get loadedBuilder {
    if (_loadedBuilder case final alreadyLoadedBuilder?) {
      return alreadyLoadedBuilder;
    }

    final FutureOr<ClientBuilder>? newLoadedBuilder;
    if (loader case final loader?) {
      newLoadedBuilder = loader().then((_) => _loadedBuilder = builder);
    } else {
      newLoadedBuilder = builder;
    }

    return _loadedBuilder = newLoadedBuilder;
  }
}

/// The builder function type for a @client component.
///
/// **DO NOT USE DIRECTLY.**
/// Use the generated `defaultClientOptions` instead.
typedef ClientBuilder = Component Function(Map<String, dynamic> params);
