import 'package:jaspr/jaspr.dart';

import 'pages/home.dart';

// A simple [StatelessComponent] with a [build] method.
@client
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'main', [
      const Home(),
    ]);
  }

  @css
  static final styles = [
    css('.main', [
      css('&').flexbox(direction: FlexDirection.row, wrap: FlexWrap.wrap),
      css('section').flexItem(flex: Flex(grow: 1, shrink: 0, basis: FlexBasis(400.px))).flexbox(
            direction: FlexDirection.column,
            justifyContent: JustifyContent.center,
            alignItems: AlignItems.center,
          ),
    ]),
  ];
}
