import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_serverpod/jaspr_serverpod.dart';
import 'package:serverpod/server.dart';

import '../../web/app.dart';
import '../../web/components/quote_like_button.dart';
import '../../web/pages/home_page.dart';
import '../../web/pages/quote_page.dart';

class RootRoute extends JasprRoute {
  @override
  Future<Component> build(Session session, HttpRequest request) async {
    print("RENDER ${await session.auth.authenticatedUserId}");
    return Document(
      title: 'Dart Quotes',
      lang: 'en',
      meta: {
        "description": "A collection of cool Dart quotes. Built for FullStackFlutter Conference.",
      },
      styles: [
        // Include text font
        StyleRule.fontFace(fontFamily: "Roboto", url: "/fonts/Roboto-Regular.woff"),
        StyleRule.fontFace(fontFamily: "Roboto", fontStyle: FontStyle.italic, url: "/fonts/Roboto-Italic.woff"),

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
        ...QuoteLikeButtonState.styles,
      ],
      body: App(),
    );
  }
}
