// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';

import 'components/hello.dart' as c0;
import 'components/app.dart' as c1;

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
    c0.Hello: ClientTarget<c0.Hello>('components/hello'),
    c1.App: ClientTarget<c1.App>('components/app'),
  },
);
