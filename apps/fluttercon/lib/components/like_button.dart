import 'dart:convert';

import 'package:fluttercon/services/favorites.dart';
import 'package:jaspr/jaspr.dart';


@client
class LikeButton extends StatelessComponent {
  const LikeButton({required this.id, super.key});

  final String id;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ListenableBuilder(
      listenable: FavoritesService.instance,
      builder: (context) sync* {
        final isFavorite = FavoritesService.instance.favorites.contains(id);

        yield button(
          events: {
            'click': (e) {
              e.preventDefault();
              FavoritesService.instance.toggle(id);
            },
          },
          styles: Styles.text(color: isFavorite ? Colors.red : null),
          [text('<3')],
        );
      },
    );
  }
}
