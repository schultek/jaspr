import 'package:jaspr/jaspr.dart';

import '0_hero/hero.dart';
import '1_meet/meet.dart';
import '2_devex/devex.dart';
import '3_features/features.dart';
import '4_testimonials/testimonials.dart';
import '5_community/community.dart';

class Home extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Document.head(
      title: 'Jaspr',
      meta: {
        'description': 'The Web Framework for Dart Developers.',
        'keywords': 'jaspr, dart, web, flutter',
        "author": "Kilian Schulte",
      },
      children: [
        meta(attributes: {'property': 'og:title'}, content: 'Jaspr | Dart Web Framework'),
        meta(attributes: {'property': 'og:description'}, content: 'Jaspr is a free and open source framework for building websites in Dart.'),
        meta(attributes: {'property': 'og:image'}, content: 'https://jaspr.site/images/og_image.png'),
      ]
    );
    yield Hero();
    yield Meet();
    yield DevExp();
    yield Features();
    yield Testimonials();
    yield Community();
  }
}
