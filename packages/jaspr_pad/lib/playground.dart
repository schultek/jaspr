import 'package:jaspr/jaspr.dart';

import 'components/playground/header.dart';
import 'components/playground/main.dart';

class Playground extends StatelessComponent {
  const Playground({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield PlaygroundHeader();
    yield MainSection();
    //yield PlaygroundFooter();
  }
}
