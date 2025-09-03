import 'package:jaspr/jaspr.dart';

import '../data/firebase.dart';
@Import.onWeb('../interop/confetti.dart', show: [#JSConfetti])
import 'quote_like_button.imports.dart';

@client
class QuoteLikeButton extends StatelessComponent {
  const QuoteLikeButton({required this.id, required this.initialCount});

  final String id;
  final int initialCount;

  @override
  Component build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService.instance.getQuoteById(id),
      builder: (context, snapshot) {
        int count = snapshot.data?.likes.length ?? initialCount;
        bool? hasLiked = snapshot.data?.likes.contains(FirebaseService.instance.getUserId());

        return button(
          classes: "quote-like-btn${hasLiked == true ? ' active' : ''}",
          onClick: () {
            if (hasLiked == null) return;
            FirebaseService.instance.toggleLikeOnQuote(id, !hasLiked);
            if (!hasLiked) {
              JSConfetti.instance.show(emojis: ['🎯', '💙']);
            }
          },
          [
            span(classes: "icon-heart${hasLiked ?? false ? '' : '-o'}", []),
            text(' $count'),
          ],
        );
      },
    );
  }

  @css
  static List<StyleRule> get styles => [
        css('.quote-like-btn', [
          css('&').styles(
            border: Border.none,
            outline: Outline(style: OutlineStyle.none),
            fontSize: 18.px,
            backgroundColor: Colors.transparent,
          ),
          css('&:hover span').styles(
            transform: Transform.scale(1.2),
          ),
          css('&.active span').styles(
            color: Colors.blue,
          ),
          css('span').styles(
            transition: Transition('transform', duration: 300, curve: Curve.ease),
          ),
        ])
      ];
}
