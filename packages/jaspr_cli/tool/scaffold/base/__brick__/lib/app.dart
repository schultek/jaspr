import 'package:jaspr/jaspr.dart';{{#routing}}
import 'package:jaspr_router/jaspr_router.dart';{{/routing}}
{{#routing}}
import 'components/header.dart';{{/routing}}
import 'pages/about.dart';
import 'pages/home.dart';

// A simple [StatelessComponent] with a [build] method.{{#hydration}}{{^multipage}}
@client{{/multipage}}{{/hydration}}
class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'main', [{{#routing}}{{#multipage}}
      const Header(),{{/multipage}}
      Router(routes: [{{#multipage}}
        Route(path: '/', title: 'Home', builder: (context, state) => const Home()),
        Route(path: '/about', title: 'About', builder: (context, state) => const About()),{{/multipage}}{{^multipage}}
        ShellRoute(
          builder: (context, state, child) => Builder(builder: (context) sync* {
            yield const Header();
            yield child;
          }),
          routes: [
            Route(path: '/', title: 'Home', builder: (context, state) => const Home()),
            Route(path: '/about', title: 'About', builder: (context, state) => const About()),
          ],
        ),{{/multipage}}
      ]),{{/routing}}{{^routing}}
      const Home(),
      const About(),{{/routing}}
    ]);
  }{{#server}}

  static get styles => [
    css('.main', [
      css('&').box(height: 100.vh).flexbox(direction: FlexDirection.{{#routing}}column{{/routing}}{{^routing}}row{{/routing}}, wrap: FlexWrap.wrap),
      css('section').flexItem(flex: Flex(grow: 1{{^routing}}, shrink: 0, basis: FlexBasis(400.px){{/routing}})).flexbox(
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
