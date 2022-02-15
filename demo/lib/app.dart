import 'package:jaspr/jaspr.dart';

import 'pages/details.dart' deferred as details;
import 'pages/home.dart' deferred as home;

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(
      onGenerateRoute: (path, context) {
        if (path == '/') {
          return Route.lazy(path, (context) => home.Home(), home.loadLibrary);
        } else {
          var segments = path.split('/');
          if (segments.length == 3 && segments[1] == 'book') {
            return Route.lazy(path, (context) => details.Details(segments.last), details.loadLibrary);
          }
        }
      },
    );
  }
}
