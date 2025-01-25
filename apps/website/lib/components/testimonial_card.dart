import 'package:highlight/languages/tex.dart';
import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

import 'icon.dart';

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
        img(src: picture, alt: name),
        p([
          span([text(name)]),
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
            border: Border.all(BorderSide.solid(width: 2.px, color: Color.hex('#EEE'))),
            padding: EdgeInsets.all(1.rem),
            shadow: BoxShadow(offsetX: 1.px, offsetY: 1.px, blur: 3.px, spread: (-1).px, color: Color.hex('#0001')),
          )
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.stretch)
          .text(align: TextAlign.start, decoration: TextDecoration.none),
      css('p').box(margin: EdgeInsets.only(top: 0.4.em, bottom: Unit.zero)).combine(bodySmall),
    ]),
  ];
}
