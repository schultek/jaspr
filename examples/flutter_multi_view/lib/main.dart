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
        width: 100.percent,
        minHeight: 100.vh,
        padding: Padding.zero,
        margin: Margin.zero,
        fontFamily: const FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]),
      ),
      css('h1').styles(
        margin: Margin.unset,
        fontSize: 4.rem,
      ),
    ],
    body: App(),
  ));
}
