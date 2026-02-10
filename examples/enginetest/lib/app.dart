import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'pages/about.dart';
import 'pages/home.dart';

// The main component of your application.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    // This method is rerun every time the component is rebuilt.
    
    // Renders a <div class="main"> html element with children.
    return div(classes: 'main', [
      const Home(),
      const About(),
    ]);
  }
}
