// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:backend_dart_frog/components/counter.dart' deferred as $counter;
import 'package:backend_dart_frog/components/hello.dart' deferred as $hello;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.g.dart';
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
      (p) => $counter.Counter(),
      loader: $counter.loadLibrary,
    ),
    'hello': ClientLoader(
      (p) => $hello.Hello(name: p['name']),
      loader: $hello.loadLibrary,
    ),
  },
);
