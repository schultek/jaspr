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
        classes: 'menu-toggle${child != null ? ' is-open' : ''}',
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
      cursor: .pointer,
    ),
    css('.menu-toggle:hover').styles(backgroundColor: hoverOverlayColor),
    css('.menu-overlay', [
      css('&').styles(
        display: .flex,
        position: .fixed(top: .zero, left: .zero, right: .zero, bottom: .zero),
        zIndex: .new(100),
        padding: .only(top: 5.5.rem, bottom: 3.5.rem, left: 1.5.rem, right: 1.5.rem),
        overflow: .only(y: .auto),
        flexDirection: .column,
        justifyContent: .start,
        alignItems: .center,
        gap: .row(1.5.rem),
        boxSizing: .borderBox,
        backgroundColor: backgroundFaded,
        raw: {
          'backdrop-filter': 'blur(16px)',
          '-webkit-backdrop-filter': 'blur(16px)',
        },
      ),
      css('nav', [
        css('&').styles(
          display: .flex,
          flexDirection: .column,
          alignItems: .stretch,
          width: 100.percent,
          maxWidth: 24.rem,
          gap: .row(1.25.rem),
          flex: .grow(0),
          boxSizing: .borderBox,
        ),
        css('.nav-item.has-dropdown', [
          css('&').styles(
            display: .flex,
            flexDirection: .column,
            alignItems: .stretch,
            width: 100.percent,
            gap: .row(0.35.rem),
            boxSizing: .borderBox,
          ),
          css('.nav-trigger', [
            css('&').styles(
              fontSize: 0.75.rem,
              fontWeight: .w700,
              textTransform: .upperCase,
              color: textDim,
              display: .flex,
              justifyContent: .start,
              alignItems: .center,
              padding: .only(left: 0.75.rem, bottom: 0.2.rem),
              margin: .zero,
              textDecoration: .none,
              cursor: .defaultCursor,
              raw: {
                'letter-spacing': '0.08em',
              },
            ),
            css('.icon-custom-caret-down, .icon-caret-down').styles(display: .none),
          ]),
          css('.nav-dropdown', [
            css('&').styles(
              display: .flex,
              flexDirection: .column,
              position: .initial,
              padding: .all(0.35.rem),
              margin: .zero,
              width: 100.percent,
              boxSizing: .borderBox,
              border: .all(color: borderColor, width: 1.px),
              backgroundColor: surface,
              radius: .circular(14.px),
              shadow: .none,
              gap: .row(0.15.rem),
              raw: {'transform': 'none', 'min-width': 'auto'},
            ),
            css('a', [
              css('&').styles(
                display: .flex,
                justifyContent: .spaceBetween,
                alignItems: .center,
                padding: .symmetric(horizontal: 0.9.rem, vertical: 0.65.rem),
                radius: .circular(9.px),
                fontSize: 0.95.rem,
                fontWeight: .w500,
                color: textBlack,
                textDecoration: .none,
                boxSizing: .borderBox,
                raw: {
                  'transition': 'background-color 150ms ease, color 150ms ease',
                },
              ),
              css('&:hover, &:active').styles(
                backgroundColor: surfaceLow,
                color: primaryMid,
              ),
              css('.icon-external-link').styles(
                color: textDim,
                fontSize: 0.85.em,
              ),
            ]),
          ]),
        ]),
        css('.nav-links-row', [
          css('&').styles(
            display: .grid,
            width: 100.percent,
            gap: .all(0.6.rem),
            boxSizing: .borderBox,
            raw: {'grid-template-columns': '1fr 1fr'},
          ),
          css('.nav-link', [
            css('&').styles(
              display: .flex,
              justifyContent: .spaceBetween,
              alignItems: .center,
              padding: .symmetric(horizontal: 1.rem, vertical: 0.75.rem),
              radius: .circular(12.px),
              border: .all(color: borderColor, width: 1.px),
              backgroundColor: surface,
              fontSize: 0.95.rem,
              fontWeight: .w600,
              color: textBlack,
              textDecoration: .none,
              boxSizing: .borderBox,
              raw: {
                'transition': 'background-color 150ms ease, color 150ms ease, border-color 150ms ease',
              },
            ),
            css('&:hover, &:active').styles(
              backgroundColor: surfaceLow,
              color: primaryMid,
              border: .all(color: borderColor2, width: 1.px),
            ),
            css('.icon-external-link').styles(
              color: textDim,
              fontSize: 0.85.em,
            ),
          ]),
        ]),
      ]),
      css('.header-actions', [
        css('&').styles(
          display: .flex,
          flexDirection: .row,
          justifyContent: .center,
          alignItems: .center,
          gap: .column(1.2.rem),
          padding: .only(top: 1.2.rem),
          width: 100.percent,
          maxWidth: 24.rem,
          boxSizing: .borderBox,
          border: .only(top: BorderSide(color: borderColor, width: 1.px)),
        ),
      ]),
    ]),
    css.media(MediaQuery.screen(maxWidth: HeaderState.mobileBreakpoint.px), [
      css('header', [
        css('.menu-toggle').styles(
          display: .flex,
          position: .relative(),
          zIndex: .new(101),
        ),
        css('.menu-toggle.is-open').styles(
          position: .fixed(top: 1.8.rem, right: 2.rem),
        ),
      ]),
    ]),
  ];
}
