import 'package:jaspr/jaspr.dart';

import 'pages/details.dart';
import 'pages/home.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(
      onGenerateRoute: (path, context) {
        if (path == '/') {
          return Route.lazy(path, (context) => Home(), () => Future.value());
        } else {
          var segments = path.split('/');
          if (segments.length == 3 && segments[1] == 'book') {
            return Route.lazy(path, (context) => Details(segments.last), () => Future.value());
          }
        }
      },
    );
  }
}
