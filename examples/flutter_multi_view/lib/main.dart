import 'package:jaspr/server.dart';

import 'app.dart';
import 'jaspr_options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultJasprOptions,
  );

  runApp(Document(
    title: 'flutter_multi_view',
    head: [
      link(rel: 'manifest', href: 'manifest.json'),
      script(src: "flutter_bootstrap.js", async: true, []),
    ],
    styles: [
      css.import('https://fonts.googleapis.com/css?family=Roboto'),
      css('html, body')
          .text(fontFamily: const FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]))
          .box(width: 100.percent, minHeight: 100.vh)
          .box(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
      css('h1').text(fontSize: 4.rem).box(margin: EdgeInsets.unset),
    ],
    body: App(),
  ));
}
