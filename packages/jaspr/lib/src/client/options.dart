import 'dart:async';

import '../../jaspr.dart';
import '../dom/validator.dart';
import 'component_anchors.dart';

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
    _loadedBuilder ??= loader != null
        ? loader!().then((_) {
            _loadedBuilder = builder;
            return builder;
          })
        : builder;
    return _loadedBuilder!;
  }
}

/// The builder function type for a @client component.
///
/// **DO NOT USE DIRECTLY.**
/// Use the generated `defaultClientOptions` instead.
typedef ClientBuilder = Component Function(ClientParams params);

class ClientParams {
  ClientParams(this._params, this.serverComponents);

  final Map<String, dynamic> _params;
  final Map<String, ServerComponentAnchor> serverComponents;

  Component mount(String sId) {
    assert(sId.startsWith('s${DomValidator.clientMarkerPrefixRegex}'));
    var s = serverComponents[sId.substring(2)];
    if (s != null) {
      return s.build();
    } else {
      return const Component.text("");
    }
  }

  T get<T>(String key) {
    if (_params[key] is! T) {
      print("$key is not $T: ${_params[key]}");
    }
    return _params[key] as T;
  }
}
