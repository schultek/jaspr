import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../data/firebase.dart';

class HomePage extends StatelessComponent {
  const HomePage({super.key});

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      header([
        img(src: 'images/quote.jpg', alt: "Quote symbol", width: 100),
        h1([.text('Dart Quotes')]),
      ]),
      ul([
        AsyncBuilder(
          builder: (context) async {
            var quotes = await FirebaseService.instance.loadQuotes();
            quotes.sort((qa, qb) => qb.likes.length.compareTo(qa.likes.length));

            return .fragment([
              for (var quote in quotes)
                li([
                  a(href: '/quote/${quote.id}', [
                    p([.text(quote.quote)]),
                    span([.text(quote.author)]),
                  ]),
                ]),
            ]);
          },
        ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('header').styles(
      display: .flex,
      padding: .only(top: 10.rem),
      flexDirection: .column,
      alignItems: .center,
    ),
    css('ul').styles(padding: .zero, listStyle: .none),
    css('li', [
      css('&').styles(
        margin: .symmetric(vertical: 1.em, horizontal: (-10).px),
        radius: .circular(10.px),
      ),
      css('&:hover').styles(backgroundColor: .rgba(0, 0, 0, 0.1)),
      css('a').styles(
        display: .block,
        padding: .all(10.px),
        color: Colors.black,
        textDecoration: .new(style: .unset),
      ),
      css('p').styles(margin: .zero, fontSize: 20.px),
      css('span').styles(fontSize: 16.px, fontStyle: .italic),
    ]),
  ];
}
