// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:fluttercon/components/like_button.dart'
    deferred as _like_button;
import 'package:fluttercon/models/session.dart' as _session;
import 'package:fluttercon/pages/favorites.dart' deferred as _favorites;
import 'package:shared_preferences_web/shared_preferences_web.dart'
    as _shared_preferences_web;

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
  initialize: () {
    final Registrar registrar = webPluginRegistrar;
    _shared_preferences_web.SharedPreferencesPlugin.registerWith(registrar);
    registrar.registerMessageHandler();
  },
  clients: {
    'like_button': ClientLoader(
      (p) => _like_button.LikeButton(
        session: _session.SessionCodex.decode(p['session'] as String),
      ),
      loader: _like_button.loadLibrary,
    ),
    'favorites': ClientLoader(
      (p) => _favorites.FavoritesPage(),
      loader: _favorites.loadLibrary,
    ),
  },
);
