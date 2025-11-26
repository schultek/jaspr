import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../components/quote_like_button.dart';
import '../data/firebase.dart';

class QuotePage extends AsyncStatelessComponent {
  const QuotePage({required this.id, super.key});

  final String id;

  @override
  Future<Component> build(BuildContext context) async {
    final navChild = nav([
      a(href: "/", [.text('Home')]),
    ]);

    var quote = await FirebaseService.instance.getQuoteById(id).single;
    if (quote == null) {
      return .fragment([
        navChild,
        div(classes: "center", [.text("Not Found")]),
      ]);
    }

    return .fragment([
      navChild,
      Document.head(
        title: quote.quote,
        meta: {"description": '"${quote.quote}" - ${quote.author}'},
        children: [
          script(src: "https://cdn.jsdelivr.net/npm/js-confetti@latest/dist/js-confetti.browser.js", defer: true),
        ],
      ),
      div(classes: "center", [
        div(classes: "quote-container", [
          img(classes: "quotes-start", src: 'images/quote.jpg', alt: "Starting quote symbol", width: 100),
          h1([.text(quote.quote)]),
          p([.text(quote.author)]),
          QuoteLikeButton(id: id, initialCount: quote.likes.length),
          img(classes: "quotes-end", src: 'images/quote.jpg', alt: "Ending quote symbol", width: 100),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('nav').styles(padding: .all(20.px), textAlign: .center),
    css('.center').styles(
      display: .flex,
      height: 100.vh,
      justifyContent: .center,
      alignItems: .center,
    ),
    css('.quote-container', [
      css('&').styles(position: .relative(), textAlign: .center),
      css('.quotes-start').styles(
        position: .absolute(top: (-100).px, left: (-10).px),
        transform: .rotate(180.deg),
      ),
      css('.quotes-end').styles(
        position: .absolute(right: (-10).px, bottom: (-50).px),
      ),
      css('h1').styles(fontSize: 40.px),
      css('p').styles(fontWeight: .normal, fontStyle: .italic),
    ]),
  ];
}
