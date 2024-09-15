// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:dart_quotes_server/web/components/quote_like_button.dart' as prefix0;

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
    prefix0.QuoteLikeButton:
        ClientTarget<prefix0.QuoteLikeButton>('web/components/quote_like_button', params: _prefix0QuoteLikeButton),
  },
  styles: () => [],
);

Map<String, dynamic> _prefix0QuoteLikeButton(prefix0.QuoteLikeButton c) => {'id': c.id, 'initialCount': c.initialCount};
