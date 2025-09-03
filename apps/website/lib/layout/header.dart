import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;
import 'package:website/utils/events.dart';

import '../components/github_button.dart';
import '../components/link_button.dart';
import '../components/logo.dart';
import '../components/menu_button.dart';
import '../components/theme_toggle.dart';
import '../constants/theme.dart';

@client
class Header extends StatefulComponent {
  const Header({this.showHome = false, super.key});

  final bool showHome;

  @override
  State createState() => HeaderState();
}

class HeaderState extends State<Header> {
  static const mobileBreakpoint = 750;

  final contentKey = GlobalKey();
  bool menuOpen = false;

  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      captureVisit();
      sub = web.EventStreamProviders.resizeEvent.forTarget(web.window).listen((e) {
        if (menuOpen && web.window.innerWidth > mobileBreakpoint) {
          setState(() {
            menuOpen = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    var content = fragment(key: contentKey, [
      nav([
        if (component.showHome) a(href: '/', classes: 'animated-underline', [text("Home")]),
        a(href: "https://docs.jaspr.site", classes: 'animated-underline', [text("Docs")]),
        a(href: "https://playground.jaspr.site", classes: 'animated-underline', [text("Playground")]),
        a(href: "https://github.com/sponsors/schultek/", classes: 'animated-underline', [text("Sponsor")]),
      ]),
      div(classes: 'header-actions', [
        ThemeToggle(),
        div(classes: 'discord-button', [
          LinkButton.icon(
              icon: 'custom-discord',
              to: 'https://discord.gg/XGXrGEk4c6',
              target: Target.blank,
              ariaLabel: 'Join Discord'),
        ]),
        GitHubButton(),
      ]),
    ]);

    return header([
      Logo(),
      if (!menuOpen) content,
      MenuButton(
        onClick: () {
          setState(() {
            menuOpen = !menuOpen;
          });
        },
        child: menuOpen ? content : null,
      ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('header', [
          css('&').styles(
            display: Display.flex,
            position: Position.absolute(left: Unit.zero, right: Unit.zero),
            zIndex: ZIndex(1),
            padding: Padding.symmetric(horizontal: 2.rem, vertical: 2.rem),
            gap: Gap(column: 2.rem),
          ),
          css('& > *').styles(
            display: Display.flex,
            alignItems: AlignItems.center,
          ),
          css('nav', [
            css('&').styles(
              display: Display.flex,
              justifyContent: JustifyContent.end,
              gap: Gap(column: 2.rem),
              flex: Flex(grow: 1),
              color: textBlack,
            ),
            css('& a').styles(
              color: textBlack,
              fontSize: 1.rem,
              fontWeight: FontWeight.w500,
              textDecoration: TextDecoration.none,
            ),
            css('& a:hover').styles(
              color: primaryMid,
            ),
          ]),
        ]),
        css.media(MediaQuery.screen(maxWidth: mobileBreakpoint.px), [
          css('header', [
            css('&').styles(
              display: Display.flex,
              justifyContent: JustifyContent.spaceBetween,
            ),
            css('& > nav').styles(display: Display.none),
            css('& > .header-actions').styles(display: Display.none),
          ]),
        ]),
      ];
}
