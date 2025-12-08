import 'dart:convert';

import '../../jaspr.dart';
import '../dom/styles.dart';
import '../dom/validator.dart';

/// Main class for initializing the Jaspr framework on the server.
///
/// Call [Jaspr.initializeApp] at the start of your app, before any calls to [runApp].
abstract final class Jaspr {
  static void initializeApp({
    ServerOptions options = const ServerOptions(),
    bool useIsolates = false,
    List<String> allowedPathSuffixes = const ['html', 'htm', 'xml'],
  }) {
    _options = options;
    _useIsolates = useIsolates;
    _allowedPathSuffixes = allowedPathSuffixes;
  }

  static bool get isInitialized => _options != null;

  static ServerOptions get options => _options ?? const ServerOptions();
  static ServerOptions? _options;

  static bool get useIsolates => _useIsolates;
  static bool _useIsolates = false;

  static List<String> get allowedPathSuffixes => _allowedPathSuffixes;
  static List<String> _allowedPathSuffixes = [];
}

/// Global options for configuring Jaspr on the server.
///
/// **DO NOT USE DIRECTLY.**
/// Use the generated `defaultServerOptions` instead.
final class ServerOptions {
  const ServerOptions({this.clientId, this.clients, this.styles});

  final String? clientId;
  final Map<Type, ClientTarget>? clients;
  final List<StyleRule> Function()? styles;
}

/// The target configuration for a @client component.
///
/// **DO NOT USE DIRECTLY.**
/// Use the generated `defaultServerOptions` instead.
final class ClientTarget<T extends Component> {
  final String name;
  final Map<String, Object?> Function(T component)? params;

  const ClientTarget(this.name, {this.params});

  String? dataFor(T component) {
    if (params == null) return null;
    return const DomValidator().escapeMarkerText(jsonEncode(params!(component)));
  }
}
