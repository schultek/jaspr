// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:backend_dart_frog/components/counter.dart' as _counter;
import 'package:backend_dart_frog/components/hello.dart' as _hello;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'utils.server.options.dart';
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
    _counter.Counter: ClientTarget<_counter.Counter>('counter'),
    _hello.Hello: ClientTarget<_hello.Hello>('hello', params: __helloHello),
  },
);

Map<String, Object?> __helloHello(_hello.Hello c) => {'name': c.name};
