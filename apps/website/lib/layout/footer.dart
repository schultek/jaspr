// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';
import 'package:website/components/logo.dart';

import '../constants/theme.dart';

class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    return footer([
      div(classes: 'footer-navigation', [
        div([
          Logo(),
          span(classes: 'created-by', [
            text('Created by '),
            a(href: 'https://schultek.dev', classes: 'animated-underline', [text('@schultek')]),
          ]),
        ]),
        div([
          h5([text('Navigation')]),
          ul([
            li([
              a(href: '/', classes: 'animated-underline', [text('Home')]),
            ]),
            li([
              a(href: 'https://docs.jaspr.site', classes: 'animated-underline', [text('Docs')]),
            ]),
            li([
              a(href: 'https://playground.jaspr.site', classes: 'animated-underline', [text('Playground')]),
            ]),
            li([
              a(href: 'https://github.com/schultek/jaspr', classes: 'animated-underline', [text('Github')]),
            ]),
          ]),
        ]),
        div([
          h5([text('Community')]),
          ul([
            li([
              a(href: 'https://discord.gg/XGXrGEk4c6', target: Target.blank, classes: 'animated-underline', [
                text('Discord'),
              ]),
            ]),
            li([
              a(
                href: 'https://docs.jaspr.site/going_further/contributing',
                target: Target.blank,
                classes: 'animated-underline',
                [text('Contribute')],
              ),
            ]),
            li([
              a(href: 'https://github.com/sponsors/schultek/', target: Target.blank, classes: 'animated-underline', [
                text('Sponsor'),
              ]),
            ]),
          ]),
        ]),
        div([
          h5([text('Legal')]),
          ul([
            li([
              a(href: '/imprint', classes: 'animated-underline', [text('Imprint')]),
            ]),
            li([
              a(href: '/privacy', classes: 'animated-underline', [text('Privacy Policy')]),
            ]),
          ]),
        ]),
      ]),
      div(classes: 'footer-banner', [
        text('Copyright © 2025 Jaspr | '),
        a(href: 'https://github.com/schultek/jaspr/blob/main/LICENSE', classes: 'animated-underline', [
          raw('MIT&nbsp;License'),
        ]),
        raw(' | Built&nbsp;with&nbsp;Jaspr&nbsp;(obviously)'),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('footer', [
      css('&').styles(
        border: Border.only(
          top: BorderSide(color: borderColor, width: 2.px),
        ),
      ),
      css('.created-by', [
        css('&').styles(
          display: Display.inlineBlock,
          margin: Margin.only(top: 0.4.rem),
          color: textDim,
          fontSize: 0.7.rem,
        ),
        css('a').styles(color: textDark, fontWeight: FontWeight.w500, textDecoration: TextDecoration.none),
      ]),
      css('.footer-navigation', [
        css('&').styles(
          display: Display.flex,
          maxWidth: maxContentWidth,
          padding: Padding.only(top: 4.rem, left: 2.rem, right: 4.rem, bottom: 2.5.rem),
          flexDirection: FlexDirection.row,
          justifyContent: JustifyContent.spaceBetween,
          alignItems: AlignItems.start,
          gap: Gap.all(2.rem),
        ),
        css('h5').styles(margin: Margin.only(bottom: 1.rem)),
        css('ul').styles(padding: Padding.zero, listStyle: ListStyle.none, fontSize: 0.9.rem, lineHeight: 2.rem),
        css('ul a').styles(color: textDim),
      ]),
      css('.footer-banner').styles(
        padding: Padding.symmetric(vertical: 1.rem, horizontal: 2.rem),
        border: Border.only(
          top: BorderSide(color: borderColor, width: 2.px),
        ),
        color: textDim,
        fontSize: 0.8.rem,
      ),
    ]),
    css.media(MediaQuery.all(maxWidth: 600.px), [
      css('footer', [css('.footer-navigation').styles(display: Display.flex, flexDirection: FlexDirection.column)]),
    ]),
  ];
}
