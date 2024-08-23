// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:flutter_embedding_demo/components/app.dart' as prefix0;
import 'package:jaspr/jaspr.dart';

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
    prefix0.App: ClientTarget<prefix0.App>('components/app'),
  },
);
