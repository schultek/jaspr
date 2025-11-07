// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:server_components/counter.dart' as prefix0;
import 'package:server_components/main.dart' as prefix1;
import 'package:server_components/minicounter.dart' as prefix2;

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
JasprOptions get defaultJasprOptions => JasprOptions(
  clients: {
    prefix0.Counter: ClientTarget<prefix0.Counter>(
      'counter',
      params: _prefix0Counter,
    ),

    prefix2.MiniCounter: ClientTarget<prefix2.MiniCounter>('minicounter'),
  },
  styles: () => [...prefix1.styles],
);

Map<String, dynamic> _prefix0Counter(prefix0.Counter c) => {
  'step': c.step,
  'child': c.child,
};
