import 'package:jaspr/jaspr.dart';

import 'components/header.dart';
import 'pages/home/home.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Header();
    yield main_([
      Home(),
    ]);
  }

  @css
  static final styles = [
    css('main', []),
  ];
}
