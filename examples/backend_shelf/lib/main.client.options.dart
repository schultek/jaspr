// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:backend_shelf/components/app.dart' deferred as _app;
import 'package:backend_shelf/components/hello.dart' deferred as _hello;

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
ClientOptions get defaultClientOptions => ClientOptions(clients: _$clients);

// A top-level function, so hot reload picks up added or removed clients.
Map<String, ClientLoader> _$clients() => {
  'app': ClientLoader((p) => _app.App(), loader: _app.loadLibrary),
  'hello': ClientLoader((p) => _hello.Hello(), loader: _hello.loadLibrary),
};
