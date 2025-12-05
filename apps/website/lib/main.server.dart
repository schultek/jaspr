import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'app.dart';

import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    Document(
      title: 'Jaspr | Dart Web Framework',
      lang: 'en',
      head: [link(rel: 'icon', type: 'image/x-icon', href: 'favicon.ico')],
      styles: [
        css('html.light .on-dark').styles(display: .none),
        css('html.dark .on-light').styles(display: .none),
      ],
      body: App(),
    ),
  );
}
