import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'pages/about.dart';
import 'pages/home.dart';

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

  static get styles => [
        css('.main', [
          css('&').flexbox(direction: FlexDirection.column).box(height: 100.vh),
          css('section').flexItem(flex: Flex(grow: 1)).flexbox(
                direction: FlexDirection.column,
                justifyContent: JustifyContent.center,
                alignItems: AlignItems.center,
              ),
        ]),
      ];
}
