import 'package:dart_quotes/components/quote_like_button.dart';
import 'package:dart_quotes/pages/home_page.dart';
import 'package:dart_quotes/pages/quote_page.dart';
import 'package:jaspr/server.dart';

import 'app.dart';
import 'jaspr_options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultJasprOptions,
  );

  runApp(Document(
    title: 'Dart Quotes',
    styles: [
      const StyleRule.import('https://fonts.googleapis.com/css?family=Roboto'),
      css('html, body')
          .text(fontFamily: const FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]))
          .box(width: 100.percent, minHeight: 100.vh)
          .box(margin: EdgeInsets.zero, padding: EdgeInsets.zero)
          .background(color: Color.hex('#F7F7F7')),
      css('h1').text(fontSize: 4.rem).box(margin: EdgeInsets.unset),
      ...App.styles,
      ...HomePage.styles,
      ...QuotePage.styles,
      ...QuoteLikeButton.styles,
    ],
    head: [
      script(src: "https://kit.fontawesome.com/fd48cbc616.js", []),
      script(src: "https://cdn.jsdelivr.net/npm/js-confetti@latest/dist/js-confetti.browser.js", []),
    ],
    body: App(),
  ));
}
