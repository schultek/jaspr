import 'package:dart_web/dart_web.dart';

import 'about.dart' deferred as about;
import 'button.dart';
import 'home.dart' deferred as home;

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(
      routes: [
        Route.lazy('/about', about.loadLibrary, (context) => about.About()),
        Route.lazy('/', home.loadLibrary, (context) => home.Home()),
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
