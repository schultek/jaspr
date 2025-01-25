// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

import '../../../components/github_button.dart';
import '../../../components/link_button.dart';
import '../../../components/logo.dart';
import '../../../components/theme_toggle.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield header([
      Logo(),
      nav([
        a(href: "https://docs.page/schultek/jaspr", classes: 'animated-underline', [text("Docs")]),
        a(href: "https://jasprpad.schultek.de", classes: 'animated-underline', [text("Playground")]),
        a(href: "https://github.com/sponsors/schultek/", classes: 'animated-underline', [text("Sponsor")]),
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
            padding: EdgeInsets.symmetric(horizontal: 2.rem, vertical: 2.rem),
          )
          .flexbox(gap: Gap(column: 2.rem)),
      css('& > *').flexbox(alignItems: AlignItems.center),
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
    ]),
  ];
}
