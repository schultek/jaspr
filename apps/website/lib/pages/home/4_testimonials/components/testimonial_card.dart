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
      p([text('"'), text(quote), text('"')]),
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
      css('&')
          .box(
            radius: BorderRadius.circular(12.px),
            border: Border.all(BorderSide.solid(width: 2.px, color: borderColor)),
            padding: EdgeInsets.all(1.rem),
            margin: EdgeInsets.only(bottom: 1.5.rem),
            shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 3.px, spread: (-1).px, color: shadowColor1),
          )
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.stretch)
          .text(align: TextAlign.start, decoration: TextDecoration.none),
      css('p').box(margin: EdgeInsets.only(top: 0.4.em, bottom: Unit.zero)).combine(bodyMedium),
      css('a', [
        css('&')
            .box(display: Display.block, margin: EdgeInsets.only(top: 1.2.rem))
            .flexbox(direction: FlexDirection.row, alignItems: AlignItems.center),
        css('img')
            .box(radius: BorderRadius.circular(100.percent), margin: EdgeInsets.only(right: 0.8.rem))
            .raw({'object-fit': 'cover'}),
            css('p').box(margin: EdgeInsets.zero).combine(bodySmall),
            css('p span:first-child').text(fontWeight: FontWeight.w600, color: textBlack),
      ]),
    ]),
  ];
}
