import 'dart:async';

import 'package:dart_quotes/data/firebase.dart';
import 'package:jaspr/jaspr.dart';

@Import.onWeb('package:dart_quotes/data/confetti.dart', show: [#showConfetti])
import 'quote_like_button.imports.dart';

@client
class QuoteLikeButton extends StatefulComponent {
  const QuoteLikeButton({required this.id, required this.count});

  final String id;
  final int count;

  @override
  State<QuoteLikeButton> createState() => _QuoteLikesState();

  static List<StyleRule> get styles => _QuoteLikesState.styles;
}

class _QuoteLikesState extends State<QuoteLikeButton> {
  int count = 0;
  bool? hasLiked;

  StreamSubscription? _snapshotSubscription;

  @override
  void initState() {
    super.initState();
    count = component.count;

    if (kIsWeb) {
      _snapshotSubscription = FirebaseService.instance.getQuoteStream(component.id).listen((quote) {
        setState(() {
          hasLiked = quote.likes.contains(FirebaseService.instance.getUserId());
          count = quote.likes.length;
        });
      });
    }
  }

  @override
  void dispose() {
    _snapshotSubscription?.cancel();
    super.dispose();
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button(
      classes: "quote-like-btn${hasLiked == true ? ' active' : ''}",
      onClick: () {
        FirebaseService.instance.toggleLikeOnQuote(component.id, !hasLiked!);
        if (!hasLiked!) {
          showConfetti(emojis: ['🎯', '💙']);
        }
      },
      [
        i(classes: "fa-${hasLiked ?? false ? 'solid' : 'regular'} fa-heart", []),
        text(' $count'),
      ],
    );
  }

  static List<StyleRule> get styles => [
        css('.quote-like-btn', [
          css('&')
              .box(border: Border.all(BorderSide.none()), outline: Outline(style: OutlineStyle.none))
              .background(color: Colors.transparent)
              .text(fontSize: 18.px),
          css('&:hover i').box(transform: Transform.scale(1.2)),
          css('&.active i').text(color: Colors.blue),
          css('i').raw({'transition': 'transform 300ms ease'}),
        ])
      ];
}
