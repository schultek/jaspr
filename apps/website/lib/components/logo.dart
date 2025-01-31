import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

class Logo extends StatelessComponent {
  const Logo({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: "logo", [
      img(src: 'images/logo.svg', height: 40),
      span([text('Jaspr')]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.logo')
        .flexbox(alignItems: AlignItems.center, gap: Gap(column: 0.5.rem))
        .text(fontSize: 1.8.rem, fontWeight: FontWeight.w600, color: textBlack),
  ];
}
