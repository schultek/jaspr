import 'package:jaspr/jaspr.dart';

import '../components/counter.dart';
import '../components/header.dart';

class Home extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Header();

    yield section([
      h1([text('Welcome')]),
      p([text('You successfully create a new Jaspr site.')]),
      div(styles: Styles.box(height: 100.px), []),
      Counter(),
    ]);
  }
}
