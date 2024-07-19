import 'package:jaspr/server.dart';
import 'package:jaspr_serverpod/jaspr_serverpod.dart';

import '../../src/services/quotes_service.dart';

class HomePage extends StatelessComponent {
  const HomePage({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield header([
      img(src: 'images/quote.jpg', alt: "Quote symbol", width: 100),
      h1([text('Dart Quotes')]),
    ]);

    yield ul([
      AsyncBuilder(builder: (context) async* {
        var quotes = await QuotesService.loadQuotes(context.session);
        quotes.sort((a, b) => b.likes.length.compareTo(a.likes.length));

        for (var quote in quotes) {
          yield li([
            a(href: '/quote/${quote.id}', [
              p([text(quote.quote)]),
              span([text(quote.author)]),
            ]),
          ]);
        }
      }),
    ]);
  }

  @css
  static final styles = [
    css('header')
        .box(padding: EdgeInsets.only(top: 10.rem))
        .flexbox(direction: FlexDirection.column, alignItems: AlignItems.center),
    css('ul').box(padding: EdgeInsets.zero).raw({'list-style': 'none'}),
    css('li', [
      css('&').box(
        margin: EdgeInsets.symmetric(vertical: 1.em, horizontal: (-10).px),
        radius: BorderRadius.circular(10.px),
      ),
      css('&:hover').background(color: Color.rgba(0, 0, 0, 0.1)),
      css('a')
          .box(display: Display.block, padding: EdgeInsets.all(10.px))
          .text(color: Colors.black, decoration: TextDecoration(style: TextDecorationStyle.unset)),
      css('p').box(margin: EdgeInsets.zero).text(fontSize: 20.px),
      css('span').text(fontSize: 16.px, fontStyle: FontStyle.italic),
    ])
  ];
}
