import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'app.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    Document(
      title: 'flutter_multi_view',
      head: [
        link(rel: 'manifest', href: 'manifest.json'),
        script(src: "flutter_bootstrap.js", async: true),
      ],
      styles: [
        css.import('https://fonts.googleapis.com/css?family=Roboto'),
        css('html, body').styles(
          width: 100.percent,
          minHeight: 100.vh,
          padding: .zero,
          margin: .zero,
          fontFamily: const .list([FontFamily('Roboto'), FontFamilies.sansSerif]),
        ),
        css('h1').styles(margin: .unset, fontSize: 4.rem),
      ],
      body: App(),
    ),
  );
}
