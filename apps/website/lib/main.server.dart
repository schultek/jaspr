import 'package:jaspr/server.dart';

import 'app.dart';

import 'main.server.g.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    Document(
      title: 'Jaspr | Dart Web Framework',
      lang: 'en',
      head: [link(rel: 'icon', type: 'image/x-icon', href: 'favicon.ico')],
      styles: [
        css('html.light .on-dark').styles(display: Display.none),
        css('html.dark .on-light').styles(display: Display.none),
      ],
      body: App(),
    ),
  );
}
