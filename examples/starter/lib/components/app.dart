import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'about.dart';
import 'home.dart';

// A simple [StatelessComponent] with a [build] method.
@client
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'main', [
      Router(routes: [
        Route(path: '/', title: 'Home', builder: (context, state) => Home()),
        Route(path: '/about', title: 'About', builder: (context, state) => About()),
      ])
    ]);
  }

  static final styles = [
    StyleRule(
      selector: Selector('.main'),
      styles: Styles.combine([
        Styles.flexbox(direction: FlexDirection.column),
        Styles.box(height: 100.vh),
      ]),
    ),
    StyleRule(
      selector: Selector('section'),
      styles: Styles.combine([
        Styles.flexItem(flex: Flex(grow: 1)),
        Styles.flexbox(
          direction: FlexDirection.column,
          justifyContent: JustifyContent.center,
          alignItems: AlignItems.center,
        ),
      ]),
    ),
  ];
}
