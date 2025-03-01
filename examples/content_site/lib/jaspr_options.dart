// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:content_site/components/counter.dart' as prefix0;
import 'package:content_site/main.dart' as prefix1;
import 'package:jaspr_content/src/content_app.dart' as prefix2;

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
  },
  styles: () => [
    ...prefix0.CounterState.styles,
    ...prefix1.Badge.styles,
    ...prefix2.ContentApp.styles,
  ],
);
