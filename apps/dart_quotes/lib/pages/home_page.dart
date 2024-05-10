import 'package:dart_quotes/data/firebase.dart';
import 'package:jaspr/server.dart';

class HomePage extends StatelessComponent {
  const HomePage({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield header([
      img(src: 'images/quote.jpg', width: 100),
      h1([text('Dart Quotes')]),
    ]);

    yield ul([
      AsyncBuilder(builder: (context) async* {
        var quotes = await loadQuotes();

        for (var quote in quotes) {
          yield div(classes: "quote", [
            a(href: '/quote/${quote.id}', [
              p([text(quote.quote)]),
              span([text(quote.author)]),
            ]),
          ]);
        }
      }),
    ]);
  }

  static get styles => [
        css('header')
            .box(padding: EdgeInsets.only(top: 10.rem))
            .flexbox(direction: FlexDirection.column, alignItems: AlignItems.center),
        css('ul').box(padding: EdgeInsets.zero),
        css('.quote', [
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
