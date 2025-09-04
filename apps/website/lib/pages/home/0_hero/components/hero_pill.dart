import 'package:jaspr/jaspr.dart';
import 'package:website/components/gradient_border.dart';
import 'package:website/components/icon.dart';

import '../../../../constants/theme.dart';

class HeroPill extends StatelessComponent {
  const HeroPill({super.key});

  @override
  Component build(BuildContext context) {
    return a(
        classes: 'hero-pill',
        href: "https://marketplace.visualstudio.com/items?itemName=schultek.jaspr-code",
        target: Target.blank,
        [
          GradientBorder(
            radius: 17,
            fixed: true,
            child: div(classes: 'pill-content', [
              text("Check out the official Jaspr VSCode Extension!"),
              Icon('arrow-right'),
            ]),
          ),
        ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('.hero-pill', [
          css('&').styles(
            margin: Margin.only(bottom: 1.rem),
            radius: BorderRadius.circular(20.px),
            raw: {
              'background': 'linear-gradient(175deg, ${primaryMid.value}33 0%, ${primaryMid.value}11 80%)',
            },
          ),
          css('.pill-content').styles(
            display: Display.flex,
            padding: Padding.symmetric(vertical: 0.5.rem, horizontal: 0.8.rem),
            alignItems: AlignItems.center,
            gap: Gap(column: 0.5.rem),
            color: textBlack,
            fontSize: 0.8.rem,
            fontWeight: FontWeight.w700,
            raw: {'text-wrap': 'balance'},
          ),
        ]),
      ];
}
