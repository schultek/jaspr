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
    yield button(classes: 'menu-toggle', attributes: {'aria-label': 'Menu Toggle'}, onClick: onClick, [Icon(child != null ? 'x' : 'menu')]);
    if (child != null) {
      yield div(classes: 'menu-overlay', [child!]);
    }
  }

  @css
  static final List<StyleRule> styles = [
    css('.menu-toggle')
        .flexbox(alignItems: AlignItems.center)
        .box(
            display: Display.none,
            radius: BorderRadius.circular(8.px),
            border: Border.unset,
            outline: Outline.unset,
            padding: EdgeInsets.all(.7.rem))
        .text(color: textBlack, fontSize: 1.5.rem)
        .background(color: Colors.transparent),
    css('.menu-toggle:hover').background(color: hoverOverlayColor),
    css('.menu-overlay', [
      css('&')
          .box(
            position: Position.fixed(
                top: Unit.zero, left: Unit.zero, right: Unit.zero, bottom: Unit.zero, zIndex: ZIndex(100)),
            padding: EdgeInsets.only(top: 7.rem),
          )
          .background(color: backgroundFaded)
          .flexbox(
            direction: FlexDirection.columnReverse,
            justifyContent: JustifyContent.start,
            alignItems: AlignItems.center,
            gap: Gap(row: 4.rem),
          )
          .raw({'backdrop-filter': 'blur(5px)'}),
      css('nav', [
        css('&')
            .flexbox(direction: FlexDirection.column, gap: Gap(row: 2.rem), alignItems: AlignItems.center)
            .flexItem(flex: Flex(grow: 0)),
        css('a').text(fontSize: 2.rem),
      ]),
      css('.header-actions').flexbox(direction: FlexDirection.row),
    ]),
    css.media(MediaQuery.screen(maxWidth: HeaderState.mobileBreakpoint.px), [
      css('header', [
        css('.menu-toggle').box(display: Display.flex, position: Position.relative(zIndex: ZIndex(101))),
      ]),
    ]),
  ];
}
