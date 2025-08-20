import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

class Logo extends StatelessComponent {
  const Logo({super.key});

  @override
  Component build(BuildContext context) {
    return a(href: '/', classes: "logo", [
      img(src: 'images/logo.svg', alt: 'logo', height: 40),
      span([text('Jaspr')]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('.logo').styles(
          display: Display.flex,
          userSelect: UserSelect.none,
          alignItems: AlignItems.center,
          gap: Gap(column: 0.5.rem),
          color: textBlack,
          fontSize: 1.8.rem,
          fontWeight: FontWeight.w600,
        ),
      ];
}
