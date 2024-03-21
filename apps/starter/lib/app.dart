import 'package:jaspr/jaspr.dart';

import 'components/header.dart';
import 'pages/about.dart';
import 'pages/home.dart';

// A simple [StatelessComponent] with a [build] method.
@client
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'main', [
      Home(),
      About(),
    ]);
  }

  static get styles => [
        css('.main', [
          css('&').flexbox(direction: FlexDirection.row, wrap: FlexWrap.wrap).box(minHeight: 100.vh),
          css('section').flexItem(flex: Flex(grow: 1, shrink: 0, basis: FlexBasis(400.px))).flexbox(
                direction: FlexDirection.column,
                justifyContent: JustifyContent.center,
                alignItems: AlignItems.center,
              ),
        ]),
        ...Header.styles,
        ...Home.styles,
        ...About.styles,
      ];
}
