import 'package:fluttercon/services/favorites.dart';
import 'package:jaspr/jaspr.dart';

import '../models/session.dart';

@client
class LikeButton extends StatelessComponent {
  const LikeButton({required this.session, super.key});

  final Session session;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ListenableBuilder(
      listenable: FavoritesService.instance,
      builder: (context) sync* {
        final isFavorite = FavoritesService.instance.favorites.containsKey(session.id);

        yield button(
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
  static final styles = [
    css('.like-button', [
      css('&').styles(
        border: Border.none,
        outline: Outline(style: OutlineStyle.none),
        backgroundColor: Colors.transparent,
        fontSize: 1.5.em,
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
