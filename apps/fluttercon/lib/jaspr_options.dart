// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'components/like_button.dart' as prefix0;
import 'pages/favorites.dart' as prefix1;

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
final defaultJasprOptions = JasprOptions(clients: {
  prefix0.LikeButton: ClientTarget<prefix0.LikeButton>('components/like_button', params: _params0LikeButton),
  prefix1.FavoritesPage: ClientTarget<prefix1.FavoritesPage>('pages/favorites'),
}, styles: []);

Map<String, dynamic> _params0LikeButton(prefix0.LikeButton c) => {'session': c.session.toJson()};
