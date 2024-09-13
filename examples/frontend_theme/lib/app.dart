import 'package:jaspr/jaspr.dart';

import 'constants/theme.dart';
import 'pages/home.dart';

@client
class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'main', [
      const Home(),
    ]);
  }

  @css
  static final styles = [
    AppTheme.styles,
    css('.main', [
      css('&').box(height: 100.vh).flexbox(direction: FlexDirection.row, wrap: FlexWrap.wrap),
      css('section').flexItem(flex: Flex(grow: 1, shrink: 0, basis: FlexBasis(400.px))).flexbox(
        direction: FlexDirection.column,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
      ),
    ]),
  ];
}
