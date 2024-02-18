import 'package:jaspr/server.dart';

import 'components/app.dart';
import 'jaspr_options.dart';

/// The server entrypoint for the jaspr app.
void main() {
  Jaspr.initializeApp(options: defaultJasprOptions);

  runApp(Document(
    title: 'Element embedding',
    meta: {
      'description': 'A Flutter Web Element embedding demo.',
      // iOS meta tags & icons
      'apple-mobile-web-app-capable': 'yes',
      'apple-mobile-web-app-status-bar-style': 'black',
      'apple-mobile-web-app-title': 'Flutter Element embedding',
    },
    head: [
      link(rel: 'apple-touch-icon', href: 'icons/Icon-192.png'),
      link(rel: 'preload', as: 'image', href: 'icons/unsplash-x9WGMWwp1NM.png'),

      // Favicon
      link(rel: 'icon', href: 'icons/favicon.png', type: 'image/png'),

      link(rel: 'manifest', href: 'manifest.json'),
      link(rel: 'stylesheet', href: 'css/style.css', type: 'text/css'),
    ],
    body: App(),
  ));
}
