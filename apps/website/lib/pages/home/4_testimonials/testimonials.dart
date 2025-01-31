import 'package:jaspr/jaspr.dart';
import 'package:website/constants/theme.dart';

import 'components/testimonial_card.dart';

class Testimonials extends StatelessComponent {
  const Testimonials({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section(id: 'testimonials', [
      h2([text('Trusted by '), br(), text('Dart Experts')]),
      div(classes: 'testimonials-grid', [
        TestimonialCard(
          quote: 'I chose Jaspr to build a landing page for my business because Flutter has poor SEO performance. What impressed me the most is the ability to do everything in Dart instead of JavaScript. The support for hydration, server-side rendering, and built-in Tailwind integration blew me away. I\'ve been using Jaspr since version 0.10.0, and it keeps getting better with every release. The community Kilian built around it is super passionate, and I can\'t wait for it to become the de-facto standard for building web experiences with Dart.',
          name: 'Dinko Marinac',
          position: 'Flutter Freelancer and Consultant',
          picture: 'https://avatars.githubusercontent.com/u/1454449?v=4',
          link: 'https://www.linkedin.com/in/dinko-marinac/',
        ),
        // Three more dummy testimonials from imaginary people with dummy quotes
        TestimonialCard(
          quote: 'Jaspr is great for building websites with Dart. I love the simplicity of the framework and how it allows me to use my existing Flutter knowledge to build websites. The built-in Tailwind CSS support is a game-changer, and the hydration and server-side rendering features are a huge plus. I\'ve been using Jaspr for a few months now and can\'t wait to see where it goes in the future.',
          name: 'John Doe',
          position: 'Flutter Developer',
          picture: 'https://placehold.co/400',
          link: 'https://example.com',
        ),
        TestimonialCard(
          quote: 'I\'ve been using Jaspr for a few weeks now and I\'m loving it. I can\'t wait to see what the future holds for Jaspr and the Dart ecosystem.',
          name: 'Jane Doe',
          position: 'Web Developer',
          picture: 'https://placehold.co/400',
          link: 'https://example.com',
        ),
        TestimonialCard(
          quote: 'Jaspr is the best web framework for Dart developers. I love how easy it is to build websites with Dart and how it allows me to use my existing Flutter knowledge. The built-in Tailwind CSS support is fantastic, and the hydration and server-side rendering features are a huge plus. ',
          name: 'John Smith',
          position: 'Flutter Developer',
          picture: 'https://placehold.co/400',
          link: 'https://example.com',
        ),
        



      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('#testimonials', [
      css('&')
          .box(padding: EdgeInsets.only(top: sectionPadding))
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.center)
          .text(align: TextAlign.center),
      css('.testimonials-grid', [
        css('&')
            .box(
          maxWidth: maxContentWidth,
          margin: EdgeInsets.only(top: 3.rem, bottom: 4.rem),
          padding: EdgeInsets.symmetric(horizontal: contentPadding),
        )
            .raw({'column-count': '3', 'gap': '1.5rem'}),
        css('& > *').raw({'break-inside': 'avoid'}),
      ]),
    ]),
    css.media(MediaQuery.screen(maxWidth: 1200.px), [
      css('#testimonials .testimonials-grid', [
        css('&').raw({'column-count': '2'}),
      ]),
    ]),
    css.media(MediaQuery.screen(maxWidth: 750.px), [
      css('#testimonials .testimonials-grid', [
        css('&').raw({'column-count': '1'}),
      ]),
    ]),
  ];
}
