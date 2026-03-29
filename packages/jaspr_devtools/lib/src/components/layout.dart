import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../styles/theme.dart';

class MainLayout extends StatelessComponent {
  const MainLayout({required this.child, super.key});

  final Component child;

  @override
  Component build(BuildContext context) {
    return div(classes: 'layout', [
      header(classes: 'header', [
        span(classes: 'logo', [.text('Jaspr DevTools')]),
      ]),
      div(classes: 'body', [
        aside(classes: 'siderail', [
          nav([
            ul([
              li([
                a(href: '/', classes: 'nav-item active', [
                  i(classes: 'icon icon-components', []),
                  span([.text('TREE')]),
                ]),
              ]),
            ]),
          ]),
        ]),
        main_(classes: 'content', [child]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.layout', [
      css('&').styles(
        display: .flex,
        flexDirection: .column,
        height: 100.vh,
        backgroundColor: ThemeColors.background,
        color: ThemeColors.onSurface,
        overflow: .hidden,
      ),
      css('.header', [
        css('&').styles(
          height: 48.px,
          display: .flex,
          alignItems: .center,
          padding: .symmetric(horizontal: ThemeSpacing.s4),
          backgroundColor: ThemeColors.surfaceContainerHigh,
          flex: .shrink(0),
        ),
        css('.logo').styles(
          fontFamily: .list([FontFamily('Space Grotesk'), FontFamilies.sansSerif]),
          fontSize: 1.rem,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.05.rem,
          textTransform: .upperCase,
          color: ThemeColors.primary,
        ),
      ]),
      css('.body', [
        css('&').styles(
          display: .flex,
          flex: Flex(grow: 1, shrink: 1, basis: .auto),
          overflow: .hidden,
        ),
        css('.siderail', [
          css('&').styles(
            width: 64.px,
            backgroundColor: ThemeColors.surfaceContainerLow,
            display: .flex,
            flexDirection: .column,
            alignItems: .center,
            padding: .symmetric(vertical: ThemeSpacing.s4),
            flex: .shrink(0),
          ),
          css('nav, ul').styles(margin: .zero, padding: .zero, listStyle: .none, width: .percent(100)),
          css('.nav-item', [
            css('&').styles(
              display: .flex,
              flexDirection: .column,
              alignItems: .center,
              padding: .symmetric(vertical: ThemeSpacing.s3),
              color: ThemeColors.onSurfaceVariant,
              textDecoration: .none,
              fontSize: 0.65.rem,
              gap: .all(ThemeSpacing.s1),
              transition: .new('all', duration: 200.ms),
            ),
            css('&:hover').styles(
              backgroundColor: ThemeColors.surfaceContainerHighest,
              color: ThemeColors.primary,
            ),
            css('&.active').styles(
              color: ThemeColors.primary,
              backgroundColor: ThemeColors.surfaceContainer,
              border: Border.only(
                left: BorderSide(width: 2.px, color: ThemeColors.primary),
              ),
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
            flex: Flex(grow: 1, shrink: 1, basis: .auto),
            position: .relative(),
            display: .flex,
            flexDirection: .column,
            overflow: .hidden,
          ),
        ]),
      ]),
    ]),
  ];
}
