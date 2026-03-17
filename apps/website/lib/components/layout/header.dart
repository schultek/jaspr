import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../../constants/theme.dart';
import '../../utils/events.dart';
import '../github_button.dart';
import '../link_button.dart';
import '../logo.dart';
import '../menu_button.dart';
import '../theme_toggle.dart';

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
    Component content = .fragment(key: contentKey, [
      nav([
        if (component.showHome) a(href: '/', classes: 'animated-underline', [.text("Home")]),
        a(href: "https://docs.jaspr.site", classes: 'animated-underline', [.text("Docs")]),
        a(href: "https://playground.jaspr.site", classes: 'animated-underline', [.text("Playground")]),
        a(href: "https://github.com/sponsors/schultek/", classes: 'animated-underline', [.text("Sponsor")]),
      ]),
      div(classes: 'header-actions', [
        ThemeToggle(),
        div(classes: 'discord-button', [
          LinkButton.icon(
            icon: 'custom-discord',
            to: 'https://discord.gg/XGXrGEk4c6',
            target: .blank,
            ariaLabel: 'Join Discord',
          ),
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
        display: .flex,
        position: .absolute(left: .zero, right: .zero),
        zIndex: .new(1),
        padding: .symmetric(horizontal: 2.rem, vertical: 2.rem),
        gap: .column(2.rem),
      ),
      css('& > *').styles(display: .flex, alignItems: .center),
      css('nav', [
        css('&').styles(
          display: .flex,
          justifyContent: .end,
          gap: .column(2.rem),
          flex: .grow(1),
          color: textBlack,
        ),
        css('& a').styles(
          color: textBlack,
          fontSize: 1.rem,
          fontWeight: .w500,
          textDecoration: .none,
        ),
        css('& a:hover').styles(color: primaryMid),
      ]),
    ]),
    css.media(.screen(maxWidth: mobileBreakpoint.px), [
      css('header', [
        css('&').styles(display: .flex, justifyContent: .spaceBetween),
        css('& > nav').styles(display: .none),
        css('& > .header-actions').styles(display: .none),
      ]),
    ]),
  ];
}
