// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:flutter_multi_view/components/counter.dart' as _counter;
import 'package:flutter_multi_view/components/embedded_counter.dart'
    as _embedded_counter;
import 'package:flutter_multi_view/components/pulsing_loader.dart'
    as _pulsing_loader;
import 'package:flutter_multi_view/constants/view_transition.dart'
    as _view_transition;
import 'package:flutter_multi_view/app.dart' as _app;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.g.dart';
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
  clients: {_app.App: ClientTarget<_app.App>('app')},
  styles: () => [
    ..._counter.CounterState.styles,
    ..._embedded_counter.EmbeddedCounter.styles,
    ..._pulsing_loader.PulsingLoader.styles,
    ..._view_transition.viewTransitionStyles,
    ..._app.AppState.styles,
  ],
);
