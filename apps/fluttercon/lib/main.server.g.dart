// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:fluttercon/components/like_button.dart' as $like_button;
import 'package:fluttercon/components/pages_nav.dart' as $pages_nav;
import 'package:fluttercon/components/session_card.dart' as $session_card;
import 'package:fluttercon/components/session_list.dart' as $session_list;
import 'package:fluttercon/components/tag.dart' as $tag;
import 'package:fluttercon/models/session.dart' as $session;
import 'package:fluttercon/pages/favorites.dart' as $favorites;
import 'package:fluttercon/pages/schedule.dart' as $schedule;
import 'package:fluttercon/pages/session.dart' as $pages_session;

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
    $like_button.LikeButton: ClientTarget<$like_button.LikeButton>(
      'like_button',
      params: _$like_buttonLikeButton,
    ),
    $favorites.FavoritesPage: ClientTarget<$favorites.FavoritesPage>(
      'favorites',
    ),
  },
  styles: () => [
    ...$like_button.LikeButton.styles,
    ...$pages_nav.PagesNav.styles,
    ...$session_card.SessionCard.styles,
    ...$session_list.SessionList.styles,
    ...$tag.Tag.styles,
    ...$schedule.SchedulePage.styles,
    ...$pages_session.SessionPage.styles,
  ],
);

Map<String, Object?> _$like_buttonLikeButton($like_button.LikeButton c) => {
  'session': $session.SessionCodex(c.session).encode(),
};
