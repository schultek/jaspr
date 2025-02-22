import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

class TestimonialCard extends StatelessComponent {
  const TestimonialCard({
    required this.quote,
    required this.name,
    required this.position,
    required this.picture,
    required this.link,
    super.key,
  });

  final String quote;
  final String name;
  final String position;
  final String picture;
  final String link;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'testimonial-card', [
      p([raw('&ldquo;'), text(quote), raw('&rdquo;')]),
      a(href: link, [
        img(src: picture, height: 40, width: 40, alt: name),
        p([
          span([text(name)]),
          br(),
          span([text(position)]),
        ]),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.testimonial-card', [
      css('&').styles(
        radius: BorderRadius.circular(12.px),
        border: Border(width: 2.px, color: borderColor),
        padding: Padding.all(1.rem),
        margin: Margin.only(bottom: 1.5.rem),
        shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 3.px, spread: (-1).px, color: shadowColor1),
        display: Display.flex,
        flexDirection: FlexDirection.column,
        alignItems: AlignItems.stretch,
        textAlign: TextAlign.start,
        textDecoration: TextDecoration.none,
      ),
      css('p').styles(margin: Margin.only(top: 0.4.em, bottom: Unit.zero)).combine(bodyMedium),
      css('a', [
        css('&').styles(
          display: Display.flex,
          margin: Margin.only(top: 1.2.rem),
          flexDirection: FlexDirection.row,
          alignItems: AlignItems.center,
        ),
        css('img').styles(
          radius: BorderRadius.circular(100.percent),
          margin: Margin.only(right: 0.8.rem),
          raw: {'object-fit': 'cover'},
        ),
        css('p').styles(margin: Margin.zero).combine(bodySmall),
        css('p span:first-child').styles(
          fontWeight: FontWeight.w600,
          color: textBlack,
        ),
      ]),
    ]),
  ];
}
