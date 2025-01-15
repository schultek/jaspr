import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

import 'github_button.dart';
import 'link_button.dart';
import 'theme_toggle.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield header([
      div(classes: "logo", [
        img(src: 'images/logo.svg', height: 42),
        span([text('Jaspr')]),
      ]),
      nav([
        a(href: "https://docs.page/schultek/jaspr", [text("Docs")]),
        a(href: "https://jasprpad.schultek.de", [text("Playground")]),
        a(href: "https://github.com/sponsors/schultek/", [text("Sponsor")]),
      ]),
      div([
        ThemeToggle(),
        div(classes: 'discord-button', [
          LinkButton.icon(icon: 'custom-discord', to: 'https://discord.gg/XGXrGEk4c6'),
        ]),
        GithubButton(),
      ])
    ]);
  }

  @css
  static final styles = [
    css('header', [
      css('&')
          .box(
            position: Position.absolute(left: Unit.zero, right: Unit.zero),
            padding: EdgeInsets.symmetric(horizontal: 1.rem, vertical: 0.5.rem),
          )
          .flexbox(gap: Gap(column: 2.rem)),
      css('& > *').flexbox(alignItems: AlignItems.center),
      css('.logo')
          .flexbox(alignItems: AlignItems.center, gap: Gap(column: 0.5.rem))
          .text(fontSize: 1.6.rem, fontWeight: FontWeight.w600),
      css('nav', [
        css('&').flexItem(flex: Flex(grow: 1)).flexbox(justifyContent: JustifyContent.end, gap: Gap(column: 2.rem)),
        css('& a').text(
          fontSize: 1.rem,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
          color: Colors.black,
        ),
        css('& a:hover').text(color: primaryMid),
      ]),
      css('.discord-button a')
          //.box(padding: EdgeInsets.symmetric(horizontal: 0.7.rem, vertical: Unit.zero))
          .text(color: Colors.black),
    ]),
  ];
}
