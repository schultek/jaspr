import 'package:dart_web/dart_web.dart';

import 'components/button.dart';
import 'pages/about.dart' deferred as about;
import 'pages/home.dart' deferred as home;

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(
      routes: [
        Route.lazy('/about', (context) => about.About(), about.loadLibrary),
        Route.lazy('/', (context) => home.Home(), home.loadLibrary),
      ],
      onUnknownRoute: (String path, BuildContext context) {
        return DomComponent(
          tag: 'span',
          child: Button(
            label: 'UNKNOWN PAGE',
            onPressed: () {
              Router.of(context).back();
            },
          ),
        );
      },
    );
  }
}
