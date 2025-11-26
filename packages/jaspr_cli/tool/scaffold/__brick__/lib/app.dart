import 'package:jaspr/dom.dart';
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
  const App({super.key});{{/multipage}}{{^multipage}}
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
  }{{/multipage}}{{/server}}{{^server}}
class App extends StatelessComponent {
  const App({super.key});{{/server}}

  @override
  Component build(BuildContext context) {
    // This method is rerun every time the component is rebuilt.
    
    // Renders a <div class="main"> html element with children.
    return div(classes: 'main', [{{#routing}}{{#multipage}}
      const Header(),{{/multipage}}
      Router(routes: [{{#multipage}}
        Route(path: '/', title: 'Home', builder: (context, state) => const Home()),
        Route(path: '/about', title: 'About', builder: (context, state) => const About()),{{/multipage}}{{^multipage}}
        ShellRoute(
          builder: (context, state, child) => .fragment([
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
  static List<StyleRule> get styles => [
    css('.main', [
      // The '&' refers to the parent selector of a nested style rules.
      css('&').styles(
        display: .flex,
        height: 100.vh,
        flexDirection: .{{#routing}}column{{/routing}}{{^routing}}row{{/routing}},
        flexWrap: .wrap,
      ),
      css('section').styles(
        display: .flex,
        flexDirection: .column,
        justifyContent: .center,
        alignItems: .center,
        flex: Flex(grow: 1{{^routing}}, shrink: 0, basis: 400.px{{/routing}}),
      ),
    ]),
  ];{{/server}}
}
