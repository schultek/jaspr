import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../../constants/theme.dart';
import '../../utils/events.dart';
import '../github_button.dart';
import '../icon.dart';
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
  static const mobileBreakpoint = 950;

  final contentKey = GlobalKey();

  bool menuOpen = false;

  StreamSubscription? sub;
  StreamSubscription? hashSub;

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
      hashSub = web.EventStreamProviders.hashChangeEvent.forTarget(web.window).listen((e) {
        _closeMenu();
      });
    }
  }

  @override
  void dispose() {
    sub?.cancel();
    hashSub?.cancel();
    super.dispose();
  }

  void _closeMenu() {
    if (menuOpen) {
      setState(() {
        menuOpen = false;
      });
    }
  }

  @override
  Component build(BuildContext context) {
    Component content = .fragment(key: contentKey, [
      nav([
        // 1. Home (dropdown)
        div(classes: 'nav-item has-dropdown', [
          a(
            href: '/',
            classes: 'nav-trigger',
            [
              .text("Home"),
              Icon('caret-down', size: 0.65.em),
            ],
          ),
          div(classes: 'nav-dropdown', [
            a(href: '/#hero', [.text("Overview")]),
            a(href: '/#meet', [.text("Meet Jaspr")]),
            a(href: '/#devex', [.text("Developer Experience")]),
            a(href: '/#features', [.text("Features")]),
            a(href: '/#community', [.text("Community & Sponsoring")]),
          ]),
        ]),

        // 2. Ecosystem (dropdown)
        div(classes: 'nav-item has-dropdown', [
          span(classes: 'nav-trigger', [
            .text("Ecosystem"),
            Icon('caret-down', size: 0.65.em),
          ]),
          div(classes: 'nav-dropdown', [
            a(href: '/jaspr-content', [.text("Jaspr Content")]),
            a(href: '/showcase', [.text("Showcase")]),
            a(
              href: 'https://pub.dev/packages?q=topic%3Ajaspr',
              target: .blank,
              attributes: {'rel': 'noopener noreferrer'},
              [
                .text("Jaspr Packages"),
                Icon('external-link', size: 0.75.em),
              ],
            ),
          ]),
        ]),

        // 3. Support (dropdown)
        div(classes: 'nav-item has-dropdown', [
          span(classes: 'nav-trigger', [
            .text("Support"),
            Icon('caret-down', size: 0.65.em),
          ]),
          div(classes: 'nav-dropdown', [
            a(href: '/consulting', [.text("Consulting")]),
            a(
              href: 'https://github.com/sponsors/schultek/',
              target: .blank,
              attributes: {'rel': 'noopener noreferrer'},
              [
                .text("Sponsor"),
                Icon('external-link', size: 0.75.em),
              ],
            ),
            a(
              href: 'https://discord.gg/XGXrGEk4c6',
              target: .blank,
              attributes: {'rel': 'noopener noreferrer'},
              [
                .text("Discord"),
                Icon('external-link', size: 0.75.em),
              ],
            ),
          ]),
        ]),

        // 4. Playground & Docs
        div(classes: 'nav-links-row', [
          a(
            href: "https://playground.jaspr.site",
            target: .blank,
            attributes: {'rel': 'noopener noreferrer'},
            classes: 'nav-link',
            [
              .text("Playground"),
              Icon('external-link', size: 0.75.em),
            ],
          ),
          a(
            href: "https://docs.jaspr.site",
            target: .blank,
            attributes: {'rel': 'noopener noreferrer'},
            classes: 'nav-link',
            [
              .text("Docs"),
              Icon('external-link', size: 0.75.em),
            ],
          ),
        ]),
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
          alignItems: .center,
          gap: .column(2.rem),
          flex: .grow(1),
          color: textBlack,
        ),
        css('& a, .nav-link').styles(
          color: textBlack,
          fontSize: 1.rem,
          fontWeight: .w500,
          textDecoration: .none,
          display: .inlineFlex,
          alignItems: .center,
          gap: .column(0.35.rem),
        ),
        css('& a:hover, .nav-link:hover').styles(color: primaryMid),
        css('.nav-links-row').styles(display: .contents),
      ]),
      css('.nav-item.has-dropdown', [
        css('&').styles(
          position: .relative(),
          display: .flex,
          alignItems: .center,
        ),
        css('&::after').styles(
          raw: {
            'content': '""',
            'position': 'absolute',
            'top': '100%',
            'left': '0',
            'right': '0',
            'height': '0.8rem',
          },
        ),
        css('.nav-trigger', [
          css('&').styles(
            display: .inlineFlex,
            alignItems: .center,
            gap: .column(0.35.rem),
            color: textBlack,
            fontSize: 1.rem,
            fontWeight: .w500,
            cursor: .pointer,
            textDecoration: .none,
          ),
          css('&:hover').styles(color: primaryMid),
        ]),
        css('.nav-dropdown', [
          css('&').styles(
            display: .none,
            position: .absolute(top: 100.percent, right: .zero),
            padding: .all(0.5.rem),
            margin: .only(top: 0.6.rem),
            radius: .circular(12.px),
            border: .all(color: borderColor, width: 1.px),
            backgroundColor: surface,
            shadow: .new(offsetX: .zero, offsetY: 8.px, blur: 24.px, color: shadowColor2),
            flexDirection: .column,
            gap: .row(0.2.rem),
            zIndex: .new(100),
            raw: {
              'min-width': '13.5rem',
            },
          ),
          css('a', [
            css('&').styles(
              display: .flex,
              justifyContent: .spaceBetween,
              alignItems: .center,
              padding: .symmetric(horizontal: 0.8.rem, vertical: 0.55.rem),
              radius: .circular(8.px),
              fontSize: 0.9.rem,
              fontWeight: .w500,
              color: textBlack,
              textDecoration: .none,
              whiteSpace: .noWrap,
              raw: {
                'transition': 'background-color 150ms ease, color 150ms ease',
              },
            ),
            css('&:hover').styles(
              backgroundColor: surfaceLow,
              color: primaryMid,
            ),
          ]),
        ]),
        css('&:hover .nav-dropdown, &:focus-within .nav-dropdown').styles(
          display: .flex,
        ),
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
