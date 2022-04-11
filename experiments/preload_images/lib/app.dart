import 'package:jaspr/jaspr.dart';

import 'components/preload_images.dart';
import 'pages/home.dart' deferred as home;
import 'pages/image.dart' deferred as image;

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield PreloadImages(child: Router(onGenerateRoute: (path, context) {
      if (path == '/') {
        return Route.lazy(path, (context) => [home.Home()], home.loadLibrary);
      } else {
        var segments = path.split('/');
        if (segments.length == 3 && segments[1] == 'image') {
          return Route.lazy(path, (context) => [image.Image(segments.last)], image.loadLibrary);
        }
      }
      return null;
    }));
  }
}
