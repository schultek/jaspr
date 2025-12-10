// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:backend_dart_frog/components/counter.dart' deferred as _counter;
import 'package:backend_dart_frog/components/hello.dart' deferred as _hello;

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
      (p) => _counter.Counter(),
      loader: _counter.loadLibrary,
    ),
    'hello': ClientLoader(
      (p) => _hello.Hello(name: p['name'] as String),
      loader: _hello.loadLibrary,
    ),
  },
);
