import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';
import 'icon.dart';
import 'layout/header.dart';

class MenuButton extends StatelessComponent {
  const MenuButton({required this.onClick, required this.child, super.key});

  final void Function() onClick;
  final Component? child;

  @override
  Component build(BuildContext context) {
    return .fragment([
      button(
        classes: 'menu-toggle',
        attributes: {'aria-label': 'Menu Toggle'},
        onClick: onClick,
        [Icon(child != null ? 'x' : 'menu')],
      ),
      if (child != null) div(classes: 'menu-overlay', [child!]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.menu-toggle').styles(
      display: .none,
      padding: .all(.7.rem),
      border: .unset,
      radius: .circular(8.px),
      outline: .unset,
      alignItems: .center,
      color: textBlack,
      fontSize: 1.5.rem,
      backgroundColor: Colors.transparent,
    ),
    css('.menu-toggle:hover').styles(backgroundColor: hoverOverlayColor),
    css('.menu-overlay', [
      css('&').styles(
        display: .flex,
        position: .fixed(top: .zero, left: .zero, right: .zero, bottom: .zero),
        zIndex: .new(100),
        padding: .only(top: 7.rem),
        flexDirection: .columnReverse,
        justifyContent: .start,
        alignItems: .center,
        gap: .row(4.rem),
        backgroundColor: backgroundFaded,
        raw: {'backdrop-filter': 'blur(5px)', '-webkit-backdrop-filter': 'blur(5px)'},
      ),
      css('nav', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .center,
          gap: .row(2.rem),
          flex: .grow(0),
        ),
        css('a').styles(fontSize: 2.rem),
      ]),
      css('.header-actions').styles(display: .flex, flexDirection: .row),
    ]),
    css.media(MediaQuery.screen(maxWidth: HeaderState.mobileBreakpoint.px), [
      css('header', [
        css('.menu-toggle').styles(
          display: .flex,
          position: .relative(),
          zIndex: .new(101),
        ),
      ]),
    ]),
  ];
}
