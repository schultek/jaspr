import 'package:jaspr/jaspr.dart';

import '../models/session.dart';
import '../services/favorites.dart';

@client
class LikeButton extends StatelessComponent {
  const LikeButton({required this.session, super.key});

  final Session session;

  @override
  Component build(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoritesService.instance,
      builder: (context) {
        final isFavorite = FavoritesService.instance.favorites.containsKey(session.id);

        return button(
          classes: 'like-button${isFavorite ? ' active' : ''}',
          events: {
            'click': (e) {
              e.preventDefault();
              FavoritesService.instance.toggle(session);
            },
          },
          [
            span(classes: "icon-heart${isFavorite ? '' : '-o'}", []),
          ],
        );
      },
    );
  }

  @css
  static List<StyleRule> get styles => [
        css('.like-button', [
          css('&').styles(
            border: Border.none,
            outline: Outline(style: OutlineStyle.none),
            fontSize: 1.5.em,
            backgroundColor: Colors.transparent,
          ),
          css('&:hover span').styles(transform: Transform.scale(1.2)),
          css('&.active span').styles(color: Colors.red),
          css('span').styles(
            display: Display.inlineBlock,
            transition: Transition('transform', duration: 300, curve: Curve.ease),
          ),
        ]),
      ];
}
