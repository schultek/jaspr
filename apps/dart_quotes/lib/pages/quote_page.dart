import 'package:jaspr/server.dart';

import '../components/quote_like_button.dart';
import '../data/firebase.dart';

class QuotePage extends AsyncStatelessComponent {
  const QuotePage({required this.id, super.key});

  final String id;

  @override
  Stream<Component> build(BuildContext context) async* {
    yield nav([
      a(href: "/", [text('Home')])
    ]);

    var quote = await FirebaseService.instance.getQuoteById(id).single;
    if (quote == null) {
      yield div(classes: "center", [text("Not Found")]);
      return;
    }

    yield div(classes: "center", [
      div(classes: "quote-container", [
        img(classes: "quotes-start", src: 'images/quote.jpg', width: 100),
        h1([text(quote.quote)]),
        h4([text(quote.author)]),
        QuoteLikeButton(id: id, initialCount: quote.likes.length),
        img(classes: "quotes-end", src: 'images/quote.jpg', width: 100),
      ])
    ]);
  }

  static get styles => [
        css('nav').text(align: TextAlign.center).box(padding: EdgeInsets.all(20.px)),
        css('.center').box(height: 100.vh).flexbox(
              justifyContent: JustifyContent.center,
              alignItems: AlignItems.center,
            ),
        css('.quote-container').box(position: Position.relative()).text(align: TextAlign.center),
        css('.quotes-start')
            .box(position: Position.absolute(top: (-100).px, left: (-10).px), transform: Transform.rotate(180.deg)),
        css('.quotes-end').box(position: Position.absolute(right: (-10).px, bottom: (-50).px)),
        css('h1').text(fontSize: 40.px),
        css('h4').text(fontStyle: FontStyle.italic),
      ];
}
