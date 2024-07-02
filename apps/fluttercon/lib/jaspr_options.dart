// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';

import 'components/like_button.dart' as c0;
import 'pages/favorites.dart' as c1;

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
const defaultJasprOptions = JasprOptions(
  targets: {
    c0.LikeButton: ClientTarget<c0.LikeButton>('components/like_button', params: _params0LikeButton),
    c1.FavoritesPage: ClientTarget<c1.FavoritesPage>('pages/favorites'),
  },
);

Map<String, dynamic> _params0LikeButton(c0.LikeButton c) => {'session': c.session.toJson()};
