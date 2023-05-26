import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/preload_images.dart';
import 'pages/home.dart' deferred as home;
import 'pages/image.dart' deferred as image;

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield PreloadImages(
      child: Router(routes: [
        Route.lazy(
          path: '/',
          builder: (_, __) => home.Home(),
          load: home.loadLibrary,
        ),
        Route.lazy(
          path: '/image/:imageId',
          builder: (_, state) => image.Image(state.params['imageId']!),
          load: image.loadLibrary,
        ),
      ]),
    );
  }
}
