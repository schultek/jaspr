import 'package:jaspr/jaspr.dart';
import 'package:website/pages/home/sections/7_footer.dart';

import 'sections/1_hero.dart';
import 'sections/2_meet.dart';
import 'sections/3_devexp.dart';
import 'sections/4_features.dart';
import 'sections/5_testimonials.dart';
import 'sections/6_community.dart';

class Home extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Hero();
    yield Meet();
    yield DevExp();
    yield Features();
    yield Testimonials();
    yield Community();
    yield Footer();
  }
}
