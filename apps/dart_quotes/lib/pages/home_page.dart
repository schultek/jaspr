import 'package:jaspr/server.dart';

import '../data/firebase.dart';

class HomePage extends StatelessComponent {
  const HomePage({super.key});

  @override
  Component build(BuildContext context) {
    return fragment([
      header([
        img(src: 'images/quote.jpg', alt: "Quote symbol", width: 100),
        h1([text('Dart Quotes')]),
      ]),
      ul([
        AsyncBuilder(builder: (context) async {
          var quotes = await FirebaseService.instance.loadQuotes();
          quotes.sort((a, b) => b.likes.length.compareTo(a.likes.length));

          return fragment([
            for (var quote in quotes)
              li([
                a(href: '/quote/${quote.id}', [
                  p([text(quote.quote)]),
                  span([text(quote.author)]),
                ]),
              ]),
          ]);
        }),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('header').styles(
          display: Display.flex,
          padding: Padding.only(top: 10.rem),
          flexDirection: FlexDirection.column,
          alignItems: AlignItems.center,
        ),
        css('ul').styles(padding: Padding.zero, listStyle: ListStyle.none),
        css('li', [
          css('&').styles(
            margin: Margin.symmetric(vertical: 1.em, horizontal: (-10).px),
            radius: BorderRadius.circular(10.px),
          ),
          css('&:hover').styles(
            backgroundColor: Color.rgba(0, 0, 0, 0.1),
          ),
          css('a').styles(
            display: Display.block,
            padding: Padding.all(10.px),
            color: Colors.black,
            textDecoration: TextDecoration(style: TextDecorationStyle.unset),
          ),
          css('p').styles(
            margin: Margin.zero,
            fontSize: 20.px,
          ),
          css('span').styles(
            fontSize: 16.px,
            fontStyle: FontStyle.italic,
          ),
        ])
      ];
}
