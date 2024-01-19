// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';

import 'components/hello.dart' as c0;
import 'components/counter.dart' as c1;

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
    c0.Hello: ClientTarget<c0.Hello>('components/hello', params: _params0Hello),
    c1.Counter: ClientTarget<c1.Counter>('components/counter'),
  },
);

Map<String, dynamic> _params0Hello(c0.Hello c) => {'name': c.name};
