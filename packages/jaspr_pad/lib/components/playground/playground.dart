import 'package:jaspr/jaspr.dart';

import 'footer.dart';
import 'header.dart';
import 'main.dart';

class Playground extends StatelessComponent {
  const Playground({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield PlaygroundHeader();
    yield MainSection();
    yield PlaygroundFooter();
  }
}
