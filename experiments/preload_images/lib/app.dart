import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/preload_images.dart';
import 'pages/home.dart' deferred as home;
import 'pages/image.dart' deferred as image;

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield PreloadImages(child: Router(onGenerateRoute: (uri, context) {
      if (uri.path == '/') {
        return Route.lazy(uri.path, (context) => [home.Home()], home.loadLibrary);
      } else {
        var segments = uri.path.split('/');
        if (segments.length == 3 && segments[1] == 'image') {
          return Route.lazy(uri.path, (context) => [image.Image(segments.last)], image.loadLibrary);
        }
      }
      return null;
    }));
  }
}
