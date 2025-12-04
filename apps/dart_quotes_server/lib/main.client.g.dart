// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:dart_quotes_server/web/components/quote_like_button.dart'
    deferred as _quote_like_button;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'quote_like_button': ClientLoader(
      (p) => _quote_like_button.QuoteLikeButton(
        id: p['id'],
        initialCount: p['initialCount'],
      ),
      loader: _quote_like_button.loadLibrary,
    ),
  },
);
