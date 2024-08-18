// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'components/like_button.dart' as prefix0;
import 'components/pages_nav.dart' as prefix1;
import 'components/session_card.dart' as prefix2;
import 'components/session_list.dart' as prefix3;
import 'components/tag.dart' as prefix4;
import 'pages/favorites.dart' as prefix5;
import 'pages/schedule.dart' as prefix6;
import 'pages/session.dart' as prefix7;

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
    prefix5.FavoritesPage: ClientTarget<prefix5.FavoritesPage>('pages/favorites'),
  },
  styles: () => [
    ...prefix0.LikeButton.styles,
    ...prefix1.PagesNav.styles,
    ...prefix2.SessionCard.styles,
    ...prefix3.SessionList.styles,
    ...prefix4.Tag.styles,
    ...prefix6.SchedulePage.styles,
    ...prefix7.SessionPage.styles,
  ],
);

Map<String, dynamic> _prefix0LikeButton(prefix0.LikeButton c) => {'session': SessionCodex(c.session).encode()};
