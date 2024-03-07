import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/header.dart';
import 'pages/about.dart';
import 'pages/home.dart';

// A simple [StatelessComponent] with a [build] method.{{#hydration}}
@client{{/hydration}}
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'main', [{{#routing}}
      Router(routes: [
        ShellRoute(
          builder: (context, state, child) => Builder(builder: (context) sync* {
            yield Header();
            yield child;
          }),
          routes: [
            Route(path: '/', title: 'Home', builder: (context, state) => Home()),
            Route(path: '/about', title: 'About', builder: (context, state) => About()),
          ],
        ),
      ]),{{/routing}}{{^routing}}
      Home(),
      About(),{{/routing}}
    ]);
  }{{#server}}

  static get styles => [
    css('.main', [
      css('&').box(height: 100.vh).flexbox(direction: FlexDirection.{{#routing}}column{{/routing}}{{^routing}}row{{/routing}}),
      css('section').flexItem(flex: Flex(grow: 1)).flexbox(
        direction: FlexDirection.column,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
      ),
    ]),{{#routing}}
    ...Header.styles,{{/routing}}
    ...Home.styles,
    ...About.styles,
  ];{{/server}}
}
