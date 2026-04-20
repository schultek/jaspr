// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:functionstest/components/counter.dart' deferred as _counter;
import 'package:functionstest/pages/about.dart' deferred as _about;

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
    'about': ClientLoader((p) => _about.About(), loader: _about.loadLibrary),
  },
);
