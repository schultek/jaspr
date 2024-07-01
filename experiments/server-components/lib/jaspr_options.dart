// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';

import 'root.dart' as c0;
import 'counter.dart' as c1;
import 'app.dart' as c2;

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
    c0.Root: ClientTarget<c0.Root>('root', params: _params0Root),
    c1.Counter: ClientTarget<c1.Counter>('counter'),
    c2.App: ClientTarget<c2.App>('app', params: _params2App),
  },
);

Map<String, dynamic> _params0Root(c0.Root c) => {'child': c.child};
Map<String, dynamic> _params2App(c2.App c) => {'name': c.name, 'child': c.child};
