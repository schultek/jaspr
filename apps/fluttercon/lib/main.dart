import 'package:jaspr/server.dart';

import 'app.dart';
import 'jaspr_options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultJasprOptions,
  );

  runApp(Document(
    title: 'Fluttercon Berlin 2024',
    styles: [
      css.import('fonts/fonts.css'),
      css('html, body').styles(
        fontFamily: const FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]),
        width: 100.percent,
        minHeight: 100.vh,
        margin: Margin.zero,
        padding: Padding.zero,
      ),
    ],
    body: App(),
  ));
}
