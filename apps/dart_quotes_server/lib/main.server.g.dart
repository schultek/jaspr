// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:dart_quotes_server/web/components/quote_like_button.dart'
    as $quote_like_button;
import 'package:dart_quotes_server/web/pages/home_page.dart' as $home_page;
import 'package:dart_quotes_server/web/pages/quote_page.dart' as $quote_page;
import 'package:dart_quotes_server/web/app.dart' as $app;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.g.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    $quote_like_button.QuoteLikeButton:
        ClientTarget<$quote_like_button.QuoteLikeButton>(
          'quote_like_button',
          params: _$quote_like_buttonQuoteLikeButton,
        ),
  },
  styles: () => [
    ...$quote_like_button.QuoteLikeButtonState.styles,
    ...$home_page.HomePage.styles,
    ...$quote_page.QuotePage.styles,
    ...$app.App.styles,
  ],
);

Map<String, Object?> _$quote_like_buttonQuoteLikeButton(
  $quote_like_button.QuoteLikeButton c,
) => {'id': c.id, 'initialCount': c.initialCount};
