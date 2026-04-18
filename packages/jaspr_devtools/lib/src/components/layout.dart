import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../styles/theme.dart';

class MainLayout extends StatelessComponent {
  const MainLayout({required this.child, super.key});

  final Component child;

  @override
  Component build(BuildContext context) {
    return div(classes: 'layout', [
      div(classes: 'body', [
        // aside(classes: 'siderail', [
        //   nav([
        //     ul([
        //       li([
        //         a(href: '/', classes: 'nav-item active', [
        //           i(classes: 'icon icon-components', []),
        //           span([.text('TREE')]),
        //         ]),
        //       ]),
        //     ]),
        //   ]),
        // ]),
        main_(classes: 'content', [child]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.layout', [
      css('&').styles(
        display: .flex,
        height: 100.vh,
        overflow: .hidden,
        flexDirection: .column,
        color: ThemeColors.onSurface,
        backgroundColor: ThemeColors.background,
      ),
      css('.header', [
        css('&').styles(
          display: .flex,
          height: 48.px,
          padding: .symmetric(horizontal: ThemeSpacing.s4),
          alignItems: .center,
          flex: .shrink(0),
          backgroundColor: ThemeColors.surfaceContainerHigh,
        ),
        css('.logo').styles(
          color: ThemeColors.primary,
          fontFamily: .list([FontFamily('Space Grotesk'), FontFamilies.sansSerif]),
          fontSize: 1.rem,
          fontWeight: FontWeight.bold,
          textTransform: .upperCase,
          letterSpacing: 0.05.rem,
        ),
      ]),
      css('.body', [
        css('&').styles(
          display: .flex,
          overflow: .hidden,
          flex: Flex(grow: 1, shrink: 1, basis: .auto),
        ),
        css('.siderail', [
          css('&').styles(
            display: .flex,
            width: 64.px,
            padding: .symmetric(vertical: ThemeSpacing.s4),
            flexDirection: .column,
            alignItems: .center,
            flex: .shrink(0),
            backgroundColor: ThemeColors.surfaceContainerLow,
          ),
          css('nav, ul').styles(width: .percent(100), padding: .zero, margin: .zero, listStyle: .none),
          css('.nav-item', [
            css('&').styles(
              display: .flex,
              padding: .symmetric(vertical: ThemeSpacing.s3),
              transition: .new('all', duration: 200.ms),
              flexDirection: .column,
              alignItems: .center,
              gap: .all(ThemeSpacing.s1),
              color: ThemeColors.onSurfaceVariant,
              fontSize: 0.65.rem,
              textDecoration: .none,
            ),
            css('&:hover').styles(
              color: ThemeColors.primary,
              backgroundColor: ThemeColors.surfaceContainerHighest,
            ),
            css('&.active').styles(
              border: Border.only(
                left: BorderSide(width: 2.px, color: ThemeColors.primary),
              ),
              color: ThemeColors.primary,
              backgroundColor: ThemeColors.surfaceContainer,
            ),
          ]),
          css('.icon', [
            css('&').styles(
              width: 24.px,
              height: 24.px,
              backgroundColor: .currentColor,
              raw: {
                'mask-repeat': 'no-repeat',
                'mask-position': 'center',
                'mask-size': 'contain',
              },
            ),
            css('&-components').styles(
              raw: {
                'mask-image':
                    'url("data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 24 24\'%3E%3Cpath d=\'M12 2L4.5 20.29l.71.71L12 18l6.79 3 .71-.71z\'/%3E%3C/svg%3E")',
              },
            ),
          ]),
        ]),
        css('.content', [
          css('&').styles(
            display: .flex,
            position: .relative(),
            overflow: .hidden,
            flexDirection: .column,
            flex: Flex(grow: 1, shrink: 1, basis: .auto),
          ),
        ]),
      ]),
    ]),
  ];
}
