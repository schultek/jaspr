// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:flutter_multi_view/components/counter.dart' as $counter;
import 'package:flutter_multi_view/components/embedded_counter.dart'
    as $embedded_counter;
import 'package:flutter_multi_view/components/pulsing_loader.dart'
    as $pulsing_loader;
import 'package:flutter_multi_view/constants/view_transition.dart'
    as $view_transition;
import 'package:flutter_multi_view/app.dart' as $app;

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
  clients: {$app.App: ClientTarget<$app.App>('app')},
  styles: () => [
    ...$counter.CounterState.styles,
    ...$embedded_counter.EmbeddedCounter.styles,
    ...$pulsing_loader.PulsingLoader.styles,
    ...$view_transition.viewTransitionStyles,
    ...$app.AppState.styles,
  ],
);
