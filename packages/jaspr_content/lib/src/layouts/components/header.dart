import 'package:jaspr/server.dart';

import '../../../components/sidebar_toggle_button.dart';

/// A header component with a logo, title, and additional items.
class Header extends StatelessComponent {
  const Header({
    required this.logo,
    required this.title,
    this.items = const [],
    super.key,
  });

  final String logo;
  final String title;
  final List<Component> items;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Document.head(children: [
      Style(styles: _styles),
    ]);

    yield header(classes: 'header', [
      SidebarToggleButton(),
      a(classes: 'header-title', href: '/', [
        img(src: logo, alt: 'Logo'),
        span([text(title)]),
      ]),
      div(classes: 'header-items', items),
    ]);
  }

  static List<StyleRule> get _styles => [
        css('.header', [
          css('&').styles(
            height: 4.rem,
            display: Display.flex,
            alignItems: AlignItems.center,
            gap: Gap(column: 1.rem),
            maxWidth: 90.rem,
            padding: Padding.symmetric(horizontal: 1.rem, vertical: .25.rem),
            margin: Margin.symmetric(horizontal: Unit.auto),
            border: Border.only(bottom: BorderSide(color: Color('#0000000d'), width: 1.px)),
          ),
          css.media(MediaQuery.all(minWidth: 768.px), [
            css('&').styles(padding: Padding.symmetric(horizontal: 2.5.rem)),
          ]),
          css('.header-title', [
            css('&').styles(
              flex: Flex(grow: 1),
              display: Display.inlineFlex,
              alignItems: AlignItems.center,
              gap: Gap(column: .75.rem),
            ),
            css('img').styles(
              height: 1.5.rem,
              width: Unit.auto,
            ),
            css('span').styles(
              fontWeight: FontWeight.w700,
            ),
          ]),
          css('.header-items', [
            css('&').styles(
              display: Display.flex,
              gap: Gap(column: 0.25.rem),
            ),
          ]),
        ]),
      ];
}
