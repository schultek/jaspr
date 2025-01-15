import 'package:jaspr/jaspr.dart';
import 'package:website/pages/home/sections/0_hero.dart';

import 'sections/1_meet.dart';

class Home extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Hero();
    yield Meet();
  }
}
