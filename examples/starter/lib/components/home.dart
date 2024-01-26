import 'package:jaspr/jaspr.dart';

import 'header.dart';

class Home extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Header();

    yield section([
      h1([text('Welcome')]),
      p([text('You successfully create a new Jaspr site.')])
    ]);
  }
}

final homeStyles = [
  StyleRule(
    selector: Selector('section'),
    styles: Styles.flexbox(
      direction: FlexDirection.column,
      justifyContent: JustifyContent.center,
      alignItems: AlignItems.center,
    ),
  ),
];
