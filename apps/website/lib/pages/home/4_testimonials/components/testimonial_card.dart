import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../../constants/theme.dart';

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
  Component build(BuildContext context) {
    return div(classes: 'testimonial-card', [
      p([RawText('&ldquo;'), .text(quote), RawText('&rdquo;')]),
      a(href: link, [
        img(src: picture, height: 40, width: 40, alt: name),
        p([
          span([.text(name)]),
          br(),
          span([.text(position)]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.testimonial-card', [
      css('&').styles(
        display: .flex,
        padding: .all(1.rem),
        margin: .only(bottom: 1.5.rem),
        border: .all(width: 2.px, color: borderColor),
        radius: .circular(12.px),
        shadow: .new(offsetX: 1.px, offsetY: 1.px, blur: 3.px, spread: (-1).px, color: shadowColor1),
        flexDirection: .column,
        alignItems: .stretch,
        textAlign: .start,
        textDecoration: .none,
      ),
      css('p')
          .styles(
            margin: .only(top: 0.4.em, bottom: .zero),
          )
          .combine(bodyMedium),
      css('a', [
        css('&').styles(
          display: .flex,
          margin: .only(top: 1.2.rem),
          flexDirection: .row,
          alignItems: .center,
        ),
        css('img').styles(
          margin: .only(right: 0.8.rem),
          radius: .circular(100.percent),
          raw: {'object-fit': 'cover'},
        ),
        css('p').styles(margin: .zero).combine(bodySmall),
        css('p span:first-child').styles(color: textBlack, fontWeight: .w600),
      ]),
    ]),
  ];
}
