// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';
import 'package:website/components/logo.dart';

import '../../../constants/theme.dart';

class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield footer([
      div(classes: 'footer-navigation', [
        div([
          Logo(),
          span(classes: 'created-by', [
            text('Created by '),
            a(href: 'https://schultek.dev', classes: 'animated-underline', [text('@schultek')])
          ]),
        ]),
        div([
          h5([text('Navigation')]),
          ul([
            li([
              a(href: 'https://github.com/schultek/jaspr', classes: 'animated-underline', [text('Github')])
            ]),
            li([
              a(href: 'https://docs.page/schultek/jaspr', classes: 'animated-underline', [text('Docs')])
            ]),
            li([
              a(href: 'https://jasprpad.schultek.de', classes: 'animated-underline', [text('Playground')])
            ]),
            li([
              a(href: 'https://github.com/sponsors/schultek/', classes: 'animated-underline', [text('Sponsor')])
            ]),
          ]),
        ]),
        div([
          h5([text('Community')]),
          ul([
            li([
              a(href: 'https://discord.gg/XGXrGEk4c6', classes: 'animated-underline', [text('Discord')])
            ]),
            li([
              a(
                  href: 'https://docs.page/schultek/jaspr/going_further/contributing',
                  classes: 'animated-underline',
                  [text('Contribute')])
            ]),
          ]),
        ]),
        div([
          h5([text('Legal')]),
          ul([
            li([
              a(href: '/terms', classes: 'animated-underline', [text('Terms')])
            ]),
            li([
              a(href: '/privacy', classes: 'animated-underline', [text('Privacy Policy')])
            ]),
          ]),
        ]),
      ]),
      div(classes: 'footer-banner', [
        text('Copyright © 2025 Jaspr | '),
        a(href: '', classes: 'animated-underline', [text('MIT License')])
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('footer', [
      css('&').box(
        margin: EdgeInsets.only(top: 10.rem),
        border: Border.only(top: BorderSide(color: Colors.whiteSmoke, width: 2.px)),
      ),
      css('.created-by', [
        css('&')
            .box(display: Display.inlineBlock, margin: EdgeInsets.only(top: 0.4.rem))
            .text(fontSize: 0.7.rem, color: textDim),
        css('a').text(decoration: TextDecoration.none, fontWeight: FontWeight.w500, color: textDark),
      ]),
      css('.footer-navigation', [
        css('&')
            .box(
              padding: EdgeInsets.only(top: 4.rem, left: 2.rem, right: 2.rem, bottom: 2.5.rem),
              maxWidth: 60.rem,
            )
            .flexbox(
              direction: FlexDirection.row,
              justifyContent: JustifyContent.spaceBetween,
              alignItems: AlignItems.start,
            ),
        css('h5').box(margin: EdgeInsets.only(bottom: 1.rem)),
        css('ul').list(style: ListStyle.none).box(padding: EdgeInsets.zero).text(fontSize: 0.9.rem, lineHeight: 2.rem),
        css('a').text(color: textDim),
      ]),
      css('.footer-banner')
          .box(
            padding: EdgeInsets.symmetric(vertical: 1.rem, horizontal: 2.rem),
            border: Border.only(top: BorderSide(color: Colors.whiteSmoke, width: 2.px)),
          )
          .text(fontSize: 0.8.rem, color: textDim),
    ]),
  ];
}
