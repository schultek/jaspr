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
      css('html, body').styles(
        fontFamily: const FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]),
        width: 100.percent,
        minHeight: 100.vh,
        margin: Margin.zero,
        padding: Padding.zero,
      ),
      css('h1').styles(
        fontSize: 4.rem,
        margin: Margin.unset,
      ),
    ],
    body: App(),
  ));
}
