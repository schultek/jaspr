import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../constants/theme.dart';
import '../logo.dart';

class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    return footer([
      div(classes: 'footer-navigation', [
        div(classes: 'footer-logo', [
          div([
            Logo(),
            span(classes: 'created-by', [
              .text('Created by '),
              a(href: 'https://schultek.dev', classes: 'animated-underline', [
                .text('@schultek'),
              ]),
            ]),
          ]),
          a(
            href: "https://github.com/schultek/jaspr/tree/main/apps/website",
            target: .blank,
            [
              span(classes: 'on-dark', [JasprBadge.light()]),
              span(classes: 'on-light', [JasprBadge.dark()]),
            ],
          ),
        ]),
        div([
          h5([.text('Navigation')]),
          ul([
            li([
              a(href: '/', classes: 'animated-underline', [.text('Home')]),
            ]),
            li([
              a(href: 'https://docs.jaspr.site', classes: 'animated-underline', [.text('Docs')]),
            ]),
            li([
              a(href: 'https://playground.jaspr.site', classes: 'animated-underline', [.text('Playground')]),
            ]),
            li([
              a(href: 'https://github.com/schultek/jaspr', classes: 'animated-underline', [.text('Github')]),
            ]),
          ]),
        ]),
        div([
          h5([.text('Community')]),
          ul([
            li([
              a(href: 'https://discord.gg/XGXrGEk4c6', target: .blank, classes: 'animated-underline', [
                .text('Discord'),
              ]),
            ]),
            li([
              a(
                href: 'https://docs.jaspr.site/going_further/contributing',
                target: .blank,
                classes: 'animated-underline',
                [.text('Contribute')],
              ),
            ]),
            li([
              a(href: 'https://github.com/sponsors/schultek/', target: .blank, classes: 'animated-underline', [
                .text('Sponsor'),
              ]),
            ]),
          ]),
        ]),
        div([
          h5([.text('Legal')]),
          ul([
            li([
              a(href: '/imprint', classes: 'animated-underline', [.text('Imprint')]),
            ]),
            li([
              a(href: '/privacy', classes: 'animated-underline', [.text('Privacy Policy')]),
            ]),
          ]),
        ]),
      ]),
      div(classes: 'footer-banner', [
        .text('Copyright © 2025 Jaspr | '),
        a(href: 'https://github.com/schultek/jaspr/blob/main/LICENSE', classes: 'animated-underline', [
          RawText('MIT&nbsp;License'),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('footer', [
      css('&').styles(
        border: .only(
          top: .new(color: borderColor, width: 2.px),
        ),
      ),
      css('.created-by', [
        css('&').styles(
          display: .inlineBlock,
          margin: .only(top: 0.4.rem),
          color: textDim,
          fontSize: 0.7.rem,
        ),
        css('a').styles(color: textDark, fontWeight: .w500, textDecoration: .none),
      ]),
      css('.footer-navigation', [
        css('&').styles(
          display: .flex,
          maxWidth: maxContentWidth,
          padding: .only(top: 4.rem, left: 2.rem, right: 4.rem, bottom: 2.5.rem),
          flexDirection: .row,
          justifyContent: .spaceBetween,
          alignItems: .start,
          gap: .all(2.rem),
        ),
        css('.footer-logo', [
          css('&').styles(
            display: .flex,
            flexDirection: .column,
            justifyContent: .spaceBetween,
            alignSelf: .stretch,
            gap: .all(1.rem),
          ),
        ]),
        css('h5').styles(margin: .only(bottom: 1.rem)),
        css('ul').styles(
          padding: .zero,
          listStyle: .none,
          fontSize: 0.9.rem,
          lineHeight: 2.rem,
        ),
        css('ul a').styles(color: textDim),
      ]),
      css('.footer-banner').styles(
        padding: .symmetric(vertical: 1.rem, horizontal: 2.rem),
        border: .only(
          top: .new(color: borderColor, width: 2.px),
        ),
        color: textDim,
        fontSize: 0.8.rem,
      ),
    ]),
    css.media(.all(maxWidth: 600.px), [
      css('footer', [css('.footer-navigation').styles(display: .flex, flexDirection: .column)]),
    ]),
  ];
}
