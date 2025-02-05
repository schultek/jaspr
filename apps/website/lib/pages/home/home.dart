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
    yield Hero();
    yield Meet();
    yield DevExp();
    yield Features();
    yield Testimonials();
    yield Community();
  }
}
