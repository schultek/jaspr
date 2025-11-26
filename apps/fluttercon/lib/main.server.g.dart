// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:fluttercon/components/like_button.dart' as _like_button;
import 'package:fluttercon/components/pages_nav.dart' as _pages_nav;
import 'package:fluttercon/components/session_card.dart' as _session_card;
import 'package:fluttercon/components/session_list.dart' as _session_list;
import 'package:fluttercon/components/tag.dart' as _tag;
import 'package:fluttercon/models/session.dart' as _session;
import 'package:fluttercon/pages/favorites.dart' as _favorites;
import 'package:fluttercon/pages/schedule.dart' as _schedule;
import 'package:fluttercon/pages/session.dart' as _pages_session;

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
    _like_button.LikeButton: ClientTarget<_like_button.LikeButton>(
      'like_button',
      params: __like_buttonLikeButton,
    ),
    _favorites.FavoritesPage: ClientTarget<_favorites.FavoritesPage>(
      'favorites',
    ),
  },
  styles: () => [
    ..._like_button.LikeButton.styles,
    ..._pages_nav.PagesNav.styles,
    ..._session_card.SessionCard.styles,
    ..._session_list.SessionList.styles,
    ..._tag.Tag.styles,
    ..._schedule.SchedulePage.styles,
    ..._pages_session.SessionPage.styles,
  ],
);

Map<String, Object?> __like_buttonLikeButton(_like_button.LikeButton c) => {
  'session': _session.SessionCodex(c.session).encode(),
};
