import 'dart:convert';

import '../../jaspr.dart';

/// Main class for initializing the jaspr framework.
///
/// Call [Jaspr.initializeApp()] at the start of your app, before any calls to [runApp].
class Jaspr {
  static void initializeApp({
    JasprOptions options = const JasprOptions(),
    bool useIsolates = false,
    List<String> allowedPathSuffixes = const ['html', 'htm', 'xml'],
  }) {
    _options = options;
    _useIsolates = useIsolates;
    _allowedPathSuffixes = allowedPathSuffixes;
  }

  static bool get isInitialized => _options != null;

  static JasprOptions get options => _options ?? JasprOptions();
  static JasprOptions? _options;

  static bool get useIsolates => _useIsolates;
  static bool _useIsolates = false;

  static List<String> get allowedPathSuffixes => _allowedPathSuffixes;
  static List<String> _allowedPathSuffixes = [];
}

/// Global options for configuring jaspr. DO NOT USE DIRECTLY.
/// Use the generated [defaultJasprOptions] instead.
class JasprOptions {
  const JasprOptions({this.clients, this.styles});

  final Map<Type, ClientTarget>? clients;
  final List<StyleRule> Function()? styles;
}

/// The target configuration for a @client component. DO NOT USE DIRECTLY.
/// Use the generated [defaultJasprOptions] instead.
class ClientTarget<T extends Component> {
  final String name;
  final Map<String, dynamic> Function(T component)? params;

  const ClientTarget(this.name, {this.params});

  String? dataFor(T component, {Object? Function(Object?)? encode}) {
    if (params == null) return null;
    return const DomValidator().escapeMarkerText(jsonEncode(params!(component), toEncodable: encode));
  }
}
