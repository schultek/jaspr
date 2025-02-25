import 'package:dart_quotes/data/firebase.dart';
import 'package:jaspr/jaspr.dart';

@Import.onWeb('../interop/confetti.dart', show: [#JSConfetti])
import 'quote_like_button.imports.dart';

@client
class QuoteLikeButton extends StatelessComponent {
  const QuoteLikeButton({required this.id, required this.initialCount});

  final String id;
  final int initialCount;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield StreamBuilder(
      stream: FirebaseService.instance.getQuoteById(id),
      builder: (context, snapshot) sync* {
        int count = snapshot.data?.likes.length ?? initialCount;
        bool? hasLiked = snapshot.data?.likes.contains(FirebaseService.instance.getUserId());

        yield button(
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
  static final styles = [
    css('.quote-like-btn', [
      css('&').styles(
        border: Border.none,
        outline: Outline(style: OutlineStyle.none),
        backgroundColor: Colors.transparent,
        fontSize: 18.px,
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
