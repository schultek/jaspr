import 'package:jaspr/jaspr.dart';

import '0_hero/hero.dart';
import '1_casestudy/casestudy_teaser.dart';
import '2_meet/meet.dart';
import '3_devex/devex.dart';
import '4_features/features.dart';
import '5_content/content_teaser.dart';
import '6_showcase/showcase.dart';
import '7_testimonials/testimonials.dart';
import '8_community/community.dart';

class Home extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return .fragment([
      Hero(),
      CaseStudyTeaser(),
      Meet(),
      DevExp(),
      Features(),
      ContentTeaser(),
      Showcase(),
      Testimonials(),
      Community(),
    ]);
  }
}
