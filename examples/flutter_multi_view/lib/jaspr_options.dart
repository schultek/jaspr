// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:flutter_multi_view/components/counter.dart' as prefix0;
import 'package:flutter_multi_view/app.dart' as prefix1;
import 'package:flutter_multi_view/styles.dart' as prefix2;

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
    prefix1.App: ClientTarget<prefix1.App>('app'),
  },
  styles: () => [
    ...prefix0.CounterState.styles,
    ...prefix1.AppState.styles,
    ...prefix2.styles,
  ],
);
