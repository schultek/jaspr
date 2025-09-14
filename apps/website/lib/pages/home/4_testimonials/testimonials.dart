import 'package:jaspr/jaspr.dart';

import '../../../constants/theme.dart';
import 'components/testimonial_card.dart';

class Testimonials extends StatelessComponent {
  const Testimonials({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'testimonials', [
      h2([text('Trusted by '), br(), text('Dart Experts')]),
      div(classes: 'testimonials-grid', [
        TestimonialCard(
          quote:
              'Jaspr is an amazing usage of Dart\'s web stack and a compliment to Flutter web. It\'s a great place to start if you want to use HTML and CSS with Dart.',
          name: 'Kevin Moore',
          position: 'Product Manager for Dart and Flutter at Google',
          picture: 'https://avatars.githubusercontent.com/u/17034?v=4',
          link: 'https://kevmoo.com/',
        ),
        TestimonialCard(
          quote:
              'Jaspr is a great way to build websites with Dart, and with its Serverpod integration you also get access to a full ORM to talk with your database.',
          name: 'Viktor Lidholt',
          position: 'Founder of Serverpod',
          picture: 'https://avatars.githubusercontent.com/u/1539812?v=4',
          link: 'https://serverpod.dev/',
        ),
        TestimonialCard(
          quote:
              'I chose Jaspr to build a landing page for my business because Flutter has poor SEO performance. What impressed me the most is the ability to do everything in Dart instead of JavaScript. The support for hydration, server-side rendering, and built-in Tailwind integration blew me away. I\'ve been using Jaspr since version 0.10.0, and it keeps getting better with every release. The community Kilian built around it is super passionate, and I can\'t wait for it to become the de-facto standard for building web experiences with Dart.',
          name: 'Dinko Marinac',
          position: 'Flutter Freelancer and Consultant',
          picture: 'https://avatars.githubusercontent.com/u/1454449?v=4',
          link: 'https://www.linkedin.com/in/dinko-marinac/',
        ),
        TestimonialCard(
          quote:
              'I\'ve been using Jaspr with Tailwind CSS to build sites like course.temiajiboye.com, temiajiboye.com, and flutteryeg.com, and I\'ve been really impressed. The SSR support and component-based approach makes it feel like Flutter for the web, but with the flexibility of Dart. It\'s smooth, efficient, and just makes sense. If you\'re into Dart and want to build modern web apps, definitely give Jaspr a try!',
          name: 'Temi Ajiboye',
          position: 'Mobile Developer',
          picture: 'https://pbs.twimg.com/profile_images/1638555966105894916/jhdtN6oQ_400x400.jpg',
          link: 'http://temiajiboye.com',
        ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('#testimonials', [
      css('&').styles(
        display: Display.flex,
        padding: Padding.only(top: sectionPadding),
        flexDirection: FlexDirection.column,
        alignItems: AlignItems.center,
        textAlign: TextAlign.center,
      ),
      css('.testimonials-grid', [
        css('&').styles(
          maxWidth: maxContentWidth,
          padding: Padding.symmetric(horizontal: contentPadding),
          margin: Margin.only(top: 3.rem, bottom: 4.rem),
          gap: Gap.all(1.5.rem),
          raw: {'column-count': '3'},
        ),
        css('& > *').styles(raw: {'break-inside': 'avoid'}),
      ]),
    ]),
    css.media(MediaQuery.screen(maxWidth: 1200.px), [
      css('#testimonials .testimonials-grid', [
        css('&').styles(raw: {'column-count': '2'}),
      ]),
    ]),
    css.media(MediaQuery.screen(maxWidth: 750.px), [
      css('#testimonials .testimonials-grid', [
        css('&').styles(raw: {'column-count': '1'}),
      ]),
    ]),
  ];
}
