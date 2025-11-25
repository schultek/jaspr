// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:backend_dart_frog/components/counter.dart' as $counter;
import 'package:backend_dart_frog/components/hello.dart' as $hello;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'utils.server.g.dart';
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
  clients: {
    $counter.Counter: ClientTarget<$counter.Counter>('counter'),
    $hello.Hello: ClientTarget<$hello.Hello>('hello', params: _$helloHello),
  },
);

Map<String, Object?> _$helloHello($hello.Hello c) => {'name': c.name};
