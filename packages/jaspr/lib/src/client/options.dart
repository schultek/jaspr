import 'dart:async';

import 'package:meta/meta.dart';

import '../../jaspr.dart';
import '../dom/validator.dart';
import 'component_anchors.dart';

/// Main class for initializing the Jaspr framework on the client.
///
/// Call [Jaspr.initializeApp] at the start of your app, before any calls to [runApp].
abstract final class Jaspr {
  static void initializeApp({ClientOptions options = const ClientOptions()}) {
    _options = options;
    invalidateClients();
    options.initialize?.call();
  }

  static bool get isInitialized => _options != null;

  static ClientOptions get options => _options ?? const ClientOptions();
  static ClientOptions? _options;

  /// The client registrations, cached so preloading and hydration share loaders.
  @internal
  static Map<String, ClientLoader> get clients => _clients ??= options.clients?.call() ?? const {};
  static Map<String, ClientLoader>? _clients;

  /// Invalidates cached client registrations, such as after hot reload.
  @internal
  static void invalidateClients() {
    _clients = null;
  }
}

/// Global options for configuring Jaspr on the client.
///
/// **DO NOT USE DIRECTLY.**
/// Use the generated `defaultClientOptions` instead.
final class ClientOptions {
  const ClientOptions({this.initialize, this.clients});

  final void Function()? initialize;

  /// Creates client registrations from the current generated code.
  ///
  /// The result is cached by [Jaspr] until initialization or hot reload.
  ///
  /// This must be or call a top-level function, like the generated `_$clients`.
  /// Closures created before a hot reload keep running their old body,
  /// so a closure that returns a map literal never picks up new clients.
  final Map<String, ClientLoader> Function()? clients;
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

/// A function that builds a @client component from its decoded [ClientParams].
///
/// **DO NOT USE DIRECTLY.**
/// Use the generated `defaultClientOptions` instead.
typedef ClientBuilder = Component Function(ClientParams params);

/// The parameters of a @client component, decoded from its server-rendered markup.
///
/// Component parameters, which render as server components,
/// are passed as IDs that [mount] resolves.
///
/// **DO NOT USE DIRECTLY.**
/// Use the generated `defaultClientOptions` instead.
final class ClientParams {
  /// Creates the parameters of a client component from its decoded parameter values
  /// and the server components rendered within it.
  ClientParams(this._params, List<ServerComponentAnchor> serverComponents)
    : serverComponents = List.of(serverComponents);

  final Map<String, Object?> _params;

  /// The server components rendered within the client component that aren't mounted yet.
  final List<ServerComponentAnchor> serverComponents;

  /// Returns a component that renders the server component with the ID [sId],
  /// reusing the DOM nodes the server rendered for it.
  ///
  /// When it mounts, the returned component takes the next instance
  /// that the server rendered with this ID.
  /// If none are left, it reports an error and renders nothing.
  Component mount(String sId) {
    assert(sId.startsWith('s${DomValidator.clientMarkerPrefixRegex}'));
    final name = sId.substring(2);
    return ServerComponent(serverComponents, name, key: GlobalKey());
  }

  /// Returns `null` if [sId] is `null`, and otherwise the same as [mount].
  Component? mountOrNull(String? sId) {
    if (sId == null) return null;
    return mount(sId);
  }

  /// Returns the JSON value of the parameter named [key].
  ///
  /// Throws a [StateError] if the value isn't a [T].
  T get<T>(String key) {
    final value = _params[key];
    if (value is! T) {
      throw StateError('$key is not $T: $value');
    }
    return value;
  }
}
