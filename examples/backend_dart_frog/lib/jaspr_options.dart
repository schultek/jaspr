// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'components/counter.dart' as prefix0;
import 'components/hello.dart' as prefix1;

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
final defaultJasprOptions = JasprOptions(
  clients: {
    prefix0.Counter: ClientTarget<prefix0.Counter>('components/counter'),
    prefix1.Hello: ClientTarget<prefix1.Hello>('components/hello', params: _prefix1Hello),
  },
  styles: [],
);

Map<String, dynamic> _prefix1Hello(prefix1.Hello c) => {'name': c.name};
