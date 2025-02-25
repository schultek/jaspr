import 'package:jaspr/jaspr.dart';{{#routing}}
import 'package:jaspr_router/jaspr_router.dart';{{/routing}}
{{#routing}}
import 'components/header.dart';{{/routing}}
import 'pages/about.dart';
import 'pages/home.dart';

// The main component of your application.{{#server}}
//{{#multipage}}
// By using multi-page routing, this component will only be built on the server during pre-rendering and
// **not** executed on the client. Instead only the nested [Home] and [About] components will be mounted on the client.
class App extends StatelessComponent {
  const App({super.key});{{/multipage}}{{^multipage}}{{#hydration}}
// By using the @client annotation this component will be automatically compiled to javascript and mounted
// on the client. Therefore:
// - this file and any imported file must be compilable for both server and client environments.
// - this component and any child components will be built once on the server during pre-rendering and then
//   again on the client during normal rendering.
@client
class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {

  @override
  void initState() {
    super.initState();
    // Run code depending on the rendering environment.
    if (kIsWeb) {
      print("Hello client");
      // When using @client components there is no default `main()` function on the client where you would normally
      // run any client-side initialization logic. Instead you can put it here, considering this component is only
      // mounted once at the root of your client-side component tree.
    } else {
      print("Hello server");
    }
  }{{/hydration}}{{^hydration}}
// This component is used on both the server (`lib/main.dart`) and the client (`web/main.dart`). Therefore:
// - this file and any imported file must be compilable for both server and client environments.
// - this component and any child components will be built once on the server during pre-rendering and then
//   again on the client during normal rendering.
class App extends StatelessComponent {
  const App({super.key});{{/hydration}}{{/multipage}}{{/server}}{{^server}}
class App extends StatelessComponent {
  const App({super.key});{{/server}}

  @override
  Iterable<Component> build(BuildContext context) sync* {
    // This method is rerun every time the component is rebuilt.
    //
    // Each build method can return multiple child components as an [Iterable]. The recommended approach
    // is using the [sync* / yield] syntax for a streamlined control flow, but its also possible to simply
    // create and return a [List] here.

    // Renders a <div class="main"> html element with children.
    yield div(classes: 'main', [{{#routing}}{{#multipage}}
      const Header(),{{/multipage}}
      Router(routes: [{{#multipage}}
        Route(path: '/', title: 'Home', builder: (context, state) => const Home()),
        Route(path: '/about', title: 'About', builder: (context, state) => const About()),{{/multipage}}{{^multipage}}
        ShellRoute(
          builder: (context, state, child) => Fragment(children: [
            const Header(),
            child,
          ]),
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

  // Defines the css styles for elements of this component.
  //
  // By using the @css annotation, these will be rendered automatically to css inside the <head> of your page.
  // Must be a variable or getter of type [List<StyleRule>].
  @css
  static final styles = [
    css('.main', [
      // The '&' refers to the parent selector of a nested style rules.
      css('&').styles(
        display: Display.flex,
        height: 100.vh,
        flexDirection: FlexDirection.{{#routing}}column{{/routing}}{{^routing}}row{{/routing}},
        flexWrap: FlexWrap.wrap,
      ),
      css('section').styles(
        display: Display.flex,
        flexDirection: FlexDirection.column,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
        flex: Flex(grow: 1{{^routing}}, shrink: 0, basis: FlexBasis(400.px){{/routing}}),
      ),
    ]),
  ];{{/server}}
}
