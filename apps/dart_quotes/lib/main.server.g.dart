// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:dart_quotes/components/quote_like_button.dart'
    as _quote_like_button;
import 'package:dart_quotes/pages/home_page.dart' as _home_page;
import 'package:dart_quotes/pages/quote_page.dart' as _quote_page;
import 'package:dart_quotes/app.dart' as _app;

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
    _quote_like_button.QuoteLikeButton:
        ClientTarget<_quote_like_button.QuoteLikeButton>(
          'quote_like_button',
          params: __quote_like_buttonQuoteLikeButton,
        ),
  },
  styles: () => [
    ..._quote_like_button.QuoteLikeButton.styles,
    ..._home_page.HomePage.styles,
    ..._quote_page.QuotePage.styles,
    ..._app.App.styles,
  ],
);

Map<String, Object?> __quote_like_buttonQuoteLikeButton(
  _quote_like_button.QuoteLikeButton c,
) => {'id': c.id, 'initialCount': c.initialCount};
