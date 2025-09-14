import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';

class Banner extends StatelessComponent {
  const Banner({super.key});

  @override
  Component build(BuildContext context) {
    return div(
      id: 'site-banner',
      attributes: {'role': 'alert'},
      [
        p([
          text('Jaspr 0.21.0 is out! This release is all about improving component syntax and reducing complexity. '),
          a(classes: 'animated-underline', href: 'https://docs.jaspr.site/releases/v/0.21.0', target: Target.blank, [
            text('Lean more'),
          ]),
        ]),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('#site-banner', [
      css('&').styles(
        display: Display.flex,
        zIndex: ZIndex(10),
        width: 100.percent,
        padding: Padding.all(0.75.rem),
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
        gap: Gap(column: 0.5.rem),
        color: Colors.white,
        textAlign: TextAlign.center,
        raw: {'background': 'linear-gradient(139deg, ${primaryDark.value}, ${primaryMid.value})'},
      ),
      css('p').styles(
        margin: Margin.zero,
        flex: Flex(grow: 1),
        color: Colors.white,
        raw: {'overflow-wrap': 'anywhere', 'word-break': 'normal', 'text-wrap': 'balance'},
      ),
      css('a', [
        css('&').styles(color: primaryLight.withLightness(0.2, replace: false), whiteSpace: WhiteSpace.noWrap),
        css('&:hover').styles(color: primaryLight.withLightness(0, replace: false)),
        css('&:active').styles(color: primaryLight),
      ]),
    ]),
  ];
}
