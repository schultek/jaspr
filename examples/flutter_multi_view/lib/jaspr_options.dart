// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:flutter_multi_view/components/counter.dart' as prefix0;
import 'package:flutter_multi_view/pages/home.dart' as prefix1;
import 'package:flutter_multi_view/app.dart' as prefix2;
import 'package:flutter_multi_view/styles.dart' as prefix3;

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
    prefix2.App: ClientTarget<prefix2.App>('app'),
  },
  styles: () => [
    ...prefix0.CounterState.styles,
    ...prefix1.HomeState.styles,
    ...prefix2.App.styles,
    ...prefix3.styles,
  ],
);
