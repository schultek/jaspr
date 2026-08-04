// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:client_component_apply_issue/components/inner.dart'
    deferred as _inner;
import 'package:client_component_apply_issue/components/outer.dart'
    deferred as _outer;

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
    'inner': ClientLoader(
      (p) => _inner.InnerButton(),
      loader: _inner.loadLibrary,
    ),
    'outer': ClientLoader(
      (p) => _outer.Outer(child: p.mount(p.get<String>('child'))),
      loader: _outer.loadLibrary,
    ),
  },
);
