// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'components/hello.dart' as prefix0;
import 'components/counter.dart' as prefix1;

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
final defaultJasprOptions = JasprOptions(clients: {
  prefix0.Hello: ClientTarget<prefix0.Hello>('components/hello', params: _params0Hello),
  prefix1.Counter: ClientTarget<prefix1.Counter>('components/counter'),
}, styles: []);

Map<String, dynamic> _params0Hello(prefix0.Hello c) => {'name': c.name};
