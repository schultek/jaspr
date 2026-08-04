// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:client_component_apply_issue/components/inner.dart' as _inner;
import 'package:client_component_apply_issue/components/outer.dart' as _outer;

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
    _inner.InnerButton: ClientTarget<_inner.InnerButton>('inner'),
    _outer.Outer: ClientTarget<_outer.Outer>('outer', params: __outerOuter),
  },
);

Map<String, Object?> __outerOuter(_outer.Outer c) => {'child': c.child};
