// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:server_components/counter.dart' as prefix0;
import 'package:server_components/root.dart' as prefix1;
import 'package:server_components/root2.dart' as prefix2;
import 'package:server_components/root3.dart' as prefix3;

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
    prefix0.Counter: ClientTarget<prefix0.Counter>('counter'),
    prefix1.Root: ClientTarget<prefix1.Root>('root', params: _prefix1Root),
    prefix2.Root2: ClientTarget<prefix2.Root2>('root2', params: _prefix2Root2),
    prefix3.Root3: ClientTarget<prefix3.Root3>('root3', params: _prefix3Root3),
  },
);

Map<String, dynamic> _prefix1Root(prefix1.Root c) => {'child': c.child};
Map<String, dynamic> _prefix2Root2(prefix2.Root2 c) => {'child': c.child};
Map<String, dynamic> _prefix3Root3(prefix3.Root3 c) => {'child': c.child};
