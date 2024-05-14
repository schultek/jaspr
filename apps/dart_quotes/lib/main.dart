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
    lang: 'en',
    styles: [
      // Include text font
      StyleRule.fontFace(fontFamily: "Roboto", url: "/fonts/Roboto-Regular.ttf"),
      StyleRule.fontFace(fontFamily: "Roboto", fontStyle: FontStyle.italic, url: "/fonts/Roboto-Italic.ttf"),

      // Include icon font
      StyleRule.fontFace(fontFamily: "icomoon", url: "/fonts/icomoon.ttf"),
      css('[class^="icon-"], [class*=" icon-"]').text(fontFamily: FontFamily('icomoon')),
      css('.icon-heart-o:before').raw({'content': r'"\e900"'}),
      css('.icon-heart:before').raw({'content': r'"\e901"'}),

      // Root styles
      css('html, body')
          .text(fontFamily: const FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]))
          .box(width: 100.percent, minHeight: 100.vh)
          .box(margin: EdgeInsets.zero, padding: EdgeInsets.zero)
          .background(color: Color.hex('#F7F7F7')),
      css('h1').text(fontSize: 4.rem).box(margin: EdgeInsets.unset),

      // Page styles
      ...App.styles,
      ...HomePage.styles,
      ...QuotePage.styles,
      ...QuoteLikeButton.styles,
    ],
    body: App(),
  ));
}
