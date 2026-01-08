// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:server_components/counter.dart' deferred as _counter;
import 'package:server_components/minicounter.dart' deferred as _minicounter;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'counter': ClientLoader(
      (p) => _counter.Counter(
        step: p.get<int>('step'),
        child: p.mount(p.get<String>('child')),
      ),
      loader: _counter.loadLibrary,
    ),
    'minicounter': ClientLoader(
      (p) => _minicounter.MiniCounter(),
      loader: _minicounter.loadLibrary,
    ),
  },
);
