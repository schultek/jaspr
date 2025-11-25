// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:fluttercon/components/like_button.dart'
    deferred as $like_button;
import 'package:fluttercon/models/session.dart' as $session;
import 'package:fluttercon/pages/favorites.dart' deferred as $favorites;
import 'package:shared_preferences_web/shared_preferences_web.dart'
    as $shared_preferences_web;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.g.dart';
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
  initialize: () {
    final Registrar registrar = webPluginRegistrar;
    $shared_preferences_web.SharedPreferencesPlugin.registerWith(registrar);
    registrar.registerMessageHandler();
  },
  clients: {
    'like_button': ClientLoader(
      (p) => $like_button.LikeButton(
        session: $session.SessionCodex.decode(p['session']),
      ),
      loader: $like_button.loadLibrary,
    ),
    'favorites': ClientLoader(
      (p) => $favorites.FavoritesPage(),
      loader: $favorites.loadLibrary,
    ),
  },
);
