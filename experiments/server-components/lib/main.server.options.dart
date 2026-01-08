// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:server_components/counter.dart' as _counter;
import 'package:server_components/main.server.dart' as _main$server;
import 'package:server_components/minicounter.dart' as _minicounter;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _counter.Counter: ClientTarget<_counter.Counter>(
      'counter',
      params: __counterCounter,
    ),
    _minicounter.MiniCounter: ClientTarget<_minicounter.MiniCounter>(
      'minicounter',
    ),
  },
  styles: () => [..._main$server.styles],
);

Map<String, Object?> __counterCounter(_counter.Counter c) => {
  'step': c.step,
  'child': c.child,
};
