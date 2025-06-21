import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';
import '../layout/header.dart';
import 'icon.dart';

class MenuButton extends StatelessComponent {
  const MenuButton({required this.onClick, required this.child, super.key});

  final void Function() onClick;
  final Component? child;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button(
        classes: 'menu-toggle',
        attributes: {'aria-label': 'Menu Toggle'},
        onClick: onClick,
        [Icon(child != null ? 'x' : 'menu')]);
    if (child != null) {
      yield div(classes: 'menu-overlay', [child!]);
    }
  }

  @css
  static List<StyleRule> get styles => [
        css('.menu-toggle').styles(
          display: Display.none,
          padding: Padding.all(.7.rem),
          border: Border.unset,
          radius: BorderRadius.circular(8.px),
          outline: Outline.unset,
          alignItems: AlignItems.center,
          color: textBlack,
          fontSize: 1.5.rem,
          backgroundColor: Colors.transparent,
        ),
        css('.menu-toggle:hover').styles(
          backgroundColor: hoverOverlayColor,
        ),
        css('.menu-overlay', [
          css('&').styles(
            display: Display.flex,
            position: Position.fixed(top: Unit.zero, left: Unit.zero, right: Unit.zero, bottom: Unit.zero),
            zIndex: ZIndex(100),
            padding: Padding.only(top: 7.rem),
            flexDirection: FlexDirection.columnReverse,
            justifyContent: JustifyContent.start,
            alignItems: AlignItems.center,
            gap: Gap(row: 4.rem),
            backgroundColor: backgroundFaded,
            raw: {'backdrop-filter': 'blur(5px)', '-webkit-backdrop-filter': 'blur(5px)'},
          ),
          css('nav', [
            css('&').styles(
              display: Display.flex,
              flexDirection: FlexDirection.column,
              alignItems: AlignItems.center,
              gap: Gap(row: 2.rem),
              flex: Flex(grow: 0),
            ),
            css('a').styles(fontSize: 2.rem),
          ]),
          css('.header-actions').styles(
            display: Display.flex,
            flexDirection: FlexDirection.row,
          ),
        ]),
        css.media(MediaQuery.screen(maxWidth: HeaderState.mobileBreakpoint.px), [
          css('header', [
            css('.menu-toggle').styles(
              display: Display.flex,
              position: Position.relative(),
              zIndex: ZIndex(101),
            ),
          ]),
        ]),
      ];
}
