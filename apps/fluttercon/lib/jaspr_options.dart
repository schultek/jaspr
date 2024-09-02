// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:fluttercon/components/like_button.dart' as prefix0;
import 'package:fluttercon/components/pages_nav.dart' as prefix1;
import 'package:fluttercon/components/session_card.dart' as prefix2;
import 'package:fluttercon/components/session_list.dart' as prefix3;
import 'package:fluttercon/components/tag.dart' as prefix4;
import 'package:fluttercon/models/session.dart' as prefix5;
import 'package:fluttercon/pages/favorites.dart' as prefix6;
import 'package:fluttercon/pages/schedule.dart' as prefix7;
import 'package:fluttercon/pages/session.dart' as prefix8;

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
    prefix0.LikeButton: ClientTarget<prefix0.LikeButton>('components/like_button', params: _prefix0LikeButton),
    prefix6.FavoritesPage: ClientTarget<prefix6.FavoritesPage>('pages/favorites'),
  },
  styles: () => [
    ...prefix0.LikeButton.styles,
    ...prefix1.PagesNav.styles,
    ...prefix2.SessionCard.styles,
    ...prefix3.SessionList.styles,
    ...prefix4.Tag.styles,
    ...prefix7.SchedulePage.styles,
    ...prefix8.SessionPage.styles,
  ],
);

Map<String, dynamic> _prefix0LikeButton(prefix0.LikeButton c) => {'session': prefix5.SessionCodex(c.session).encode()};
