// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:functionstest/components/counter.dart' as _counter;
import 'package:functionstest/components/header.dart' as _header;
import 'package:functionstest/constants/theme.dart' as _theme;
import 'package:functionstest/pages/about.dart' as _about;
import 'package:functionstest/app.dart' as _app;

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
    _counter.Counter: ClientTarget<_counter.Counter>('counter'),
    _about.About: ClientTarget<_about.About>('about'),
  },
  styles: () => [
    ..._theme.styles,
    ..._app.App.styles,
    ..._counter.CounterState.styles,
    ..._header.Header.styles,
    ..._about.About.styles,
  ],
);
