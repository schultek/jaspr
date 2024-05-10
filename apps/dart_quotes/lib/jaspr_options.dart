// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';

import 'components/quote_like_button.dart' as c0;

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
    c0.QuoteLikeButton:
        ClientTarget<c0.QuoteLikeButton>('components/quote_like_button', params: _params0QuoteLikeButton),
  },
);

Map<String, dynamic> _params0QuoteLikeButton(c0.QuoteLikeButton c) => {'id': c.id, 'count': c.count};
