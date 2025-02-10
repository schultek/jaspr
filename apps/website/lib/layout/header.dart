import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;
import 'package:website/utils/events.dart';

import '../components/menu_button.dart';
import '../constants/theme.dart';
import '../components/github_button.dart';
import '../components/link_button.dart';
import '../components/logo.dart';
import '../components/theme_toggle.dart';

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
  Iterable<Component> build(BuildContext context) sync* {
    var content = Fragment(key: contentKey, children: [
      nav([
        if (component.showHome) a(href: '/', classes: 'animated-underline', [text("Home")]),
        a(href: "https://docs.jaspr.site", classes: 'animated-underline', [text("Docs")]),
        a(href: "https://playground.jaspr.site", classes: 'animated-underline', [text("Playground")]),
        a(href: "https://github.com/sponsors/schultek/", classes: 'animated-underline', [text("Sponsor")]),
      ]),
      div(classes: 'header-actions', [
        ThemeToggle(),
        div(classes: 'discord-button', [
          LinkButton.icon(icon: 'custom-discord', to: 'https://discord.gg/XGXrGEk4c6', target: Target.blank, ariaLabel: 'Join Discord'),
        ]),
        GithubButton(),
      ]),
    ]);

    yield header([
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
  static final styles = [
    css('header', [
      css('&')
          .box(
            position: Position.absolute(left: Unit.zero, right: Unit.zero, zIndex: ZIndex(1)),
            padding: EdgeInsets.symmetric(horizontal: 2.rem, vertical: 2.rem),
          )
          .flexbox(gap: Gap(column: 2.rem)),
      css('& > *').flexbox(alignItems: AlignItems.center),
      css('nav', [
        css('&')
            .flexItem(flex: Flex(grow: 1))
            .flexbox(justifyContent: JustifyContent.end, gap: Gap(column: 2.rem))
            .text(color: textBlack),
        css('& a').text(
          fontSize: 1.rem,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
          color: textBlack,
        ),
        css('& a:hover').text(color: primaryMid),
      ]),
    ]),
    css.media(MediaQuery.screen(maxWidth: mobileBreakpoint.px), [
      css('header', [
        css('&').flexbox(justifyContent: JustifyContent.spaceBetween),
        css('& > nav').box(display: Display.none),
        css('& > .header-actions').box(display: Display.none),
      ]),
    ]),
  ];
}
