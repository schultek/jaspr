import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/counter.dart';

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    return section([
      img(src: 'images/logo.svg', width: 80),
      h1([.text('Welcome')]),
      p([.text('You successfully create a new Jaspr site.')]),
      div(styles: Styles(height: 100.px), []),
      const Counter(),
    ]);
  }
}
