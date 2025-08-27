import 'package:jaspr/server.dart';

import '../components/quote_like_button.dart';
import '../data/firebase.dart';

class QuotePage extends AsyncStatelessComponent {
  const QuotePage({required this.id, super.key});

  final String id;

  @override
  Stream<Component> build(BuildContext context) async* {
    yield nav([
      a(href: "/", [text('Home')]),
    ]);

    var quote = await FirebaseService.instance.getQuoteById(id).single;
    if (quote == null) {
      yield div(classes: "center", [text("Not Found")]);
      return;
    }

    yield Document.head(
      title: quote.quote,
      meta: {"description": '"${quote.quote}" - ${quote.author}'},
      children: [
        script(src: "https://cdn.jsdelivr.net/npm/js-confetti@latest/dist/js-confetti.browser.js", defer: true),
      ],
    );

    yield div(classes: "center", [
      div(classes: "quote-container", [
        img(classes: "quotes-start", src: 'images/quote.jpg', alt: "Starting quote symbol", width: 100),
        h1([text(quote.quote)]),
        p([text(quote.author)]),
        QuoteLikeButton(id: id, initialCount: quote.likes.length),
        img(classes: "quotes-end", src: 'images/quote.jpg', alt: "Ending quote symbol", width: 100),
      ])
    ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('nav').styles(
          padding: Padding.all(20.px),
          textAlign: TextAlign.center,
        ),
        css('.center').styles(
          display: Display.flex,
          height: 100.vh,
          justifyContent: JustifyContent.center,
          alignItems: AlignItems.center,
        ),
        css('.quote-container', [
          css('&').styles(
            position: Position.relative(),
            textAlign: TextAlign.center,
          ),
          css('.quotes-start').styles(
            position: Position.absolute(top: (-100).px, left: (-10).px),
            transform: Transform.rotate(180.deg),
          ),
          css('.quotes-end').styles(
            position: Position.absolute(right: (-10).px, bottom: (-50).px),
          ),
          css('h1').styles(
            fontSize: 40.px,
          ),
          css('p').styles(
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.italic,
          ),
        ]),
      ];
}
