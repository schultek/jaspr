// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';

import 'components/like_button.dart' as c0;
import 'pages/home.dart' as c1;

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
    c1.Home: ClientTarget<c1.Home>('pages/home', params: _params1Home),
  },
);

Map<String, dynamic> _params0LikeButton(c0.LikeButton c) => {'id': c.id};
Map<String, dynamic> _params1Home(c1.Home c) => {'sessions': c.sessions.map((i) => i.toJson()).toList()};
