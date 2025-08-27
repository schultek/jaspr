// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:dart_quotes/components/quote_like_button.dart' as prefix0;
import 'package:dart_quotes/pages/home_page.dart' as prefix1;
import 'package:dart_quotes/pages/quote_page.dart' as prefix2;
import 'package:dart_quotes/app.dart' as prefix3;

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
        prefix0.QuoteLikeButton: ClientTarget<prefix0.QuoteLikeButton>(
          'components/quote_like_button',
          params: _prefix0QuoteLikeButton,
        ),
      },
      styles: () => [
        ...prefix0.QuoteLikeButton.styles,
        ...prefix1.HomePage.styles,
        ...prefix2.QuotePage.styles,
        ...prefix3.App.styles,
      ],
    );

Map<String, dynamic> _prefix0QuoteLikeButton(prefix0.QuoteLikeButton c) => {
      'id': c.id,
      'initialCount': c.initialCount,
    };
