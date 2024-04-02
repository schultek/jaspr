// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
{{^multipage}}
import 'app.dart' as c0;{{/multipage}}{{#multipage}}
import 'pages/about.dart' as c0;
import 'pages/home.dart' as c1;{{/multipage}}

/// Default [JasprOptions] for use with your jaspr project.
///
/// Use this to initialize jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'jaspr_options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultJasprOptions,
///   );
///
///   runApp(...);
/// }
/// ```
const defaultJasprOptions = JasprOptions(
  targets: {
  {{^multipage}}  c0.App: ClientTarget<c0.App>('app'),
  {{/multipage}}{{#multipage}}  c0.About: ClientTarget<c0.About>('pages/about'),
    c1.Home: ClientTarget<c1.Home>('pages/home'),
  {{/multipage}}},
);
