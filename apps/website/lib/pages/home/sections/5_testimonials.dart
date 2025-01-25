// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';

import '../../../components/testimonial_card.dart';

class Testimonials extends StatelessComponent {
  const Testimonials({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section(id: 'testimonials', [
      h2([text('Trusted by '), br(), text('Dart Experts')]),
      div(classes: 'testimonials-grid', [
        TestimonialCard(
          quote: 'Jaspr is great',
          name: 'John Doe',
          position: 'Flutter Developer',
          picture: 'https://via.placeholder.com/150',
          link: 'https://example.com',
        ),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('#testimonials', [
      css('&')
          .box(padding: EdgeInsets.only(top: 10.rem))
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.center)
          .text(align: TextAlign.center),
      css('.testimonials-grid', [
        css('&')
            .box(
          maxWidth: 60.5.rem,
          margin: EdgeInsets.only(top: 3.rem, bottom: 4.rem),
          padding: EdgeInsets.symmetric(horizontal: 2.rem),
        )
            .raw({'column-count': '3', 'gap': '1.5rem'}),
        css('& > *').raw({'break-inside': 'avoid'}),
      ]),
    ]),
  ];
}
