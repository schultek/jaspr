// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'components/quote_like_button.dart' as prefix0;

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
  prefix0.QuoteLikeButton:
      ClientTarget<prefix0.QuoteLikeButton>('components/quote_like_button', params: _params0QuoteLikeButton),
}, styles: []);

Map<String, dynamic> _params0QuoteLikeButton(prefix0.QuoteLikeButton c) => {'id': c.id, 'initialCount': c.initialCount};
