import 'package:jaspr/jaspr.dart';

import 'sections/0_hero.dart';
import 'sections/1_meet.dart';
import 'sections/2_devexp.dart';
import 'sections/3_features.dart';

class Home extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Hero();
    yield Meet();
    yield DevExp();
    yield Features();
  }
}
